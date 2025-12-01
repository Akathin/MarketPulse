import os
from dotenv import load_dotenv
from dateutil import parser
from fastapi import FastAPI
from pydantic import BaseModel
from apscheduler.schedulers.background import BackgroundScheduler
import openai
import time
from sqlalchemy import create_engine, Column, Integer, String, DateTime, select, Text
from sqlalchemy.orm import declarative_base, sessionmaker
import requests
import datetime
from newspaper import Article
from sentiment import analyze_sentiment

# ----------------------
# MySQL 세팅
# ----------------------
DB_USER = "root"          # MySQL 유저
DB_PASS = "1234"      # MySQL 비번
DB_HOST = "localhost"     # MySQL 호스트
DB_NAME = "news_db"       # DB 이름

DATABASE_URL = f"mysql+pymysql://{DB_USER}:{DB_PASS}@{DB_HOST}/{DB_NAME}?charset=utf8mb4"
engine = create_engine(DATABASE_URL, pool_pre_ping=True)
Base = declarative_base()
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

class News(Base):
    __tablename__ = "news"
    id = Column(Integer, primary_key=True, index=True)
    company = Column(String, index=True)
    title = Column(String)
    url = Column(String, unique=True, index=True)
    description = Column(String)
    content = Column(String)
    sentiment = Column(String)
    published_at = Column(DateTime)
    summary_ko = Column(Text)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)


class Subscription(Base):
    __tablename__ = "subscriptions"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String, index=True)
    company = Column(String, index=True)


Base.metadata.create_all(bind=engine)

# ----------------------
# FastAPI 앱
# ----------------------
app = FastAPI()

load_dotenv()
NEWS_API_KEY = os.getenv("NEWS_API_KEY")
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
if OPENAI_API_KEY:
    openai.api_key = OPENAI_API_KEY

# 해외 기업 리스트 (폴백)
COMPANIES = ["Apple", "Tesla", "Amazon", "Google", "Microsoft", "NVIDIA", "Meta"]


class SubscriptionRequest(BaseModel):
    user_id: str
    company: str

#기사 본문 추출 함수
def extract_full_text(url: str) -> str:
    try:
        article = Article(url)
        article.download()
        article.parse()
        return article.text
    except Exception:
        return None


def summarize_article(text: str) -> str:
    """Summarize English article text into detailed Korean summary using OpenAI.
    Returns None if no API key or if summarization fails.
    """
    if not text:
        return None
    if not OPENAI_API_KEY:
        return None

    # simple chunking by characters; tune chunk_size for your model/token limits
    chunk_size = 3000
    parts = [text[i:i+chunk_size] for i in range(0, len(text), chunk_size)]
    summaries = []
    system_prompt = "당신은 영어 뉴스 기사를 한국어로 요약하는 전문가입니다. 자세하게 핵심만 요약하세요."

    for part in parts:
        user_prompt = (
            "다음 영어 본문을 읽고 한국어로 자세히 요약하세요. 핵심 포인트를 마지막에 3개로 정리하세요.\n\n" + part
        )
        for attempt in range(3):
            try:
                resp = openai.ChatCompletion.create(
                    model="gpt-3.5-turbo",
                    messages=[
                        {"role": "system", "content": system_prompt},
                        {"role": "user", "content": user_prompt},
                    ],
                    max_tokens=800,
                    temperature=0.2,
                )
                chunk_summary = resp["choices"][0]["message"]["content"].strip()
                summaries.append(chunk_summary)
                break
            except Exception:
                time.sleep(2 ** attempt)
                continue

    if not summaries:
        return None

    if len(summaries) == 1:
        return summaries[0]

    combined = "\n\n".join(summaries)
    synth_prompt = (
        "여러 개의 부분 요약을 하나의 일관된 한국어 요약으로 합치고, 불필요한 중복을 제거하세요. 마지막에 핵심 키포인트 3개를 번호로 정리하세요.\n\n" + combined
    )

    for attempt in range(3):
        try:
            resp = openai.ChatCompletion.create(
                model="gpt-3.5-turbo",
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": synth_prompt},
                ],
                max_tokens=1000,
                temperature=0.2,
            )
            final_summary = resp["choices"][0]["message"]["content"].strip()
            return final_summary
        except Exception:
            time.sleep(2 ** attempt)
            continue

    return "\n\n".join(summaries)

# ----------------------
# 뉴스 크롤링 함수 (NewsAPI)
# ----------------------
def fetch_news(company):
    url = "https://newsapi.org/v2/everything"
    params = {
        "q": company,
        "apiKey": NEWS_API_KEY,
        "language": "en",
        "sortBy": "publishedAt",
        "pageSize": 10,
    }
    res = requests.get(url, params=params)
    data = res.json()

    db = SessionLocal()
    for item in data.get("articles", []):
        # URL 중복 체크
        exists = db.execute(select(News).where(News.url == item["url"])).first()
        if exists:
            continue

        # 기사 전문 추출
        full_text = extract_full_text(item["url"])

        # 감정 분석
        sentiment_result = analyze_sentiment(full_text) if full_text else "neutral"

        # publishedAt 파싱
        published_at = parser.isoparse(item["publishedAt"]).replace(tzinfo=None)

        # 한국어 요약 (OpenAI 기반) - 환경변수 없으면 건너뜀
        summary_ko = None
        try:
            summary_ko = summarize_article(full_text) if full_text else None
        except Exception:
            summary_ko = None

        news = News(
            company=company,
            title=item["title"],
            url=item["url"],
            description=item["description"],
            content=full_text,
            sentiment=sentiment_result,   # 추가
            published_at=published_at,
            summary_ko=summary_ko,
        )
        db.add(news)

    db.commit()
    db.close()
    print(f"[{datetime.datetime.now()}] {company} 뉴스 갱신 완료")

# ----------------------
# 스케줄러 (15분마다 모든 기업 뉴스 갱신)
# ----------------------
def get_subscribed_companies():
    db = SessionLocal()
    try:
        stmt = select(Subscription.company).distinct()
        rows = db.execute(stmt).scalars().all()
        return rows
    finally:
        db.close()


def update_all_news():
    companies = get_subscribed_companies()
    # 폴백: 구독이 없으면 기존 하드코딩된 기업 리스트를 사용
    if not companies:
        companies = COMPANIES

    for company in companies:
        fetch_news(company)


scheduler = BackgroundScheduler()
scheduler.add_job(update_all_news, "interval", minutes=15)
scheduler.start()

# ----------------------
# API 엔드포인트
# ----------------------
@app.get("/news")
def get_news(company: str = None):
    db = SessionLocal()
    if company:
        query = select(News).where(News.company == company).order_by(News.id.desc())
    else:
        query = select(News).order_by(News.id.desc())
    news_list = db.execute(query).scalars().all()
    db.close()
    def _format(dt):
        try:
            return dt.isoformat() if dt else None
        except Exception:
            return str(dt)

    return [
        {
            "company": n.company,
            "title": n.title,
            "url": n.url,
            "description": n.description,
            "publishedAt": _format(n.published_at),
        }
        for n in news_list
    ]


@app.post("/subscribe")
def subscribe(req: SubscriptionRequest):
    """사용자가 특정 기업을 구독하도록 추가"""
    db = SessionLocal()
    try:
        exists = db.execute(select(Subscription).where(Subscription.user_id == req.user_id, Subscription.company == req.company)).first()
        if exists:
            return {"status": "exists", "message": "이미 구독중입니다."}

        sub = Subscription(user_id=req.user_id, company=req.company)
        db.add(sub)
        db.commit()
        return {"status": "ok", "message": f"{req.company} 구독 추가됨"}
    finally:
        db.close()


@app.post("/unsubscribe")
def unsubscribe(req: SubscriptionRequest):
    """사용자 구독 해제"""
    db = SessionLocal()
    try:
        stmt = select(Subscription).where(Subscription.user_id == req.user_id, Subscription.company == req.company)
        row = db.execute(stmt).scalars().first()
        if not row:
            return {"status": "not_found", "message": "구독 항목이 없습니다."}

        db.delete(row)
        db.commit()
        return {"status": "ok", "message": f"{req.company} 구독 해제됨"}
    finally:
        db.close()


@app.get("/subscriptions")
def list_subscriptions(user_id: str = None):
    """특정 사용자 또는 전체 구독 목록 반환"""
    db = SessionLocal()
    try:
        if user_id:
            stmt = select(Subscription).where(Subscription.user_id == user_id)
            rows = db.execute(stmt).scalars().all()
            return [{"company": r.company, "user_id": r.user_id} for r in rows]
        else:
            stmt = select(Subscription)
            rows = db.execute(stmt).scalars().all()
            return [{"company": r.company, "user_id": r.user_id} for r in rows]
    finally:
        db.close()
@app.on_event("startup")
def startup_event():
    update_all_news()  # 서버 시작 시 한 번 뉴스 갱신