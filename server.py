import os
from fastapi.middleware.cors import CORSMiddleware
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
    company = Column(String(100), index=True)      # 길이 지정
    title = Column(String(500))                    # 뉴스 제목은 최대 500
    url = Column(String(500), unique=True, index=True)
    description = Column(String(1000))             # 설명은 최대 1000
    content = Column(Text)                         # 본문은 길어서 Text로 변경
    sentiment = Column(String(50))                 # 감정 분석 결과는 짧음
    published_at = Column(DateTime)
    summary_ko = Column(Text)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)


class Subscription(Base):
    __tablename__ = "subscriptions"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String(100), index=True)
    company = Column(String(100), index=True)


Base.metadata.create_all(bind=engine)

# ----------------------
# FastAPI 앱
# ----------------------
app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],     # 모든 origin 허용
    allow_credentials=True,
    allow_methods=["*"],     # GET, POST 등 모든 메서드 허용
    allow_headers=["*"],     # 모든 헤더 허용
)

load_dotenv()
NEWS_API_KEY = os.getenv("NEWS_API_KEY")
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
if OPENAI_API_KEY:
    openai.api_key = OPENAI_API_KEY

# 해외 기업 리스트 (폴백)
COMPANIES = ["Apple", "Tesla"] #, "Amazon", "Google", "Microsoft", "NVIDIA", "Meta"


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


from openai import OpenAI
client = OpenAI(api_key=OPENAI_API_KEY)

def summarize_article(text: str) -> str:
    if not text or not OPENAI_API_KEY:
        return None

    # 본문을 너무 길게 넣지 않도록 제한
    text = text[:8000]   # 너무 긴 전문은 잘라서 보내기

    system_msg = """
    당신은 영어 뉴스를 한국어로 '짧고 핵심만' 요약하는 전문가입니다.
    절대 본문을 번역하거나 길게 작성하지 마세요.
    3~5문장으로 간결하게 작성하세요.
    """

    user_msg = f"""
    아래 영어 기사 내용을 한국어로 3~5문장만 사용하여 '매우 간략하게' 요약하세요.
    본문 전체를 번역하지 말고 핵심 결론만 요약하세요.
    마지막에 bullet 형식으로 핵심포인트 3개만 적어주세요.

    기사 내용:
    {text}
    """

    try:
        resp = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "system", "content": system_msg},
                {"role": "user", "content": user_msg},
            ],
            temperature=0.2,
            max_tokens=350,  # 요약 분량 강하게 제한
        )
        return resp.choices[0].message.content.strip()

    except Exception as e:
        print("요약 오류:", e)
        return None

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

        # 감정 분석 (본문 없으면 중립)
        sentiment_result = analyze_sentiment(full_text) if full_text else "neutral"

        # publishedAt 파싱
        published_at = parser.isoparse(item["publishedAt"]).replace(tzinfo=None)

        # 요약에 사용할 텍스트 (본문 없으면 description 사용)
        summary_source = full_text if full_text else item["description"]

        # 한국어 요약 (본문 또는 description 기반)
        summary_ko = None
        if summary_source:
            try:
                summary_ko = summarize_article(summary_source)
            except Exception:
                summary_ko = None

        news = News(
            company=company,
            title=item["title"],
            url=item["url"],
            description=item["description"],
            content=full_text,
            sentiment=sentiment_result,
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
            "summary_ko": n.summary_ko,
            "sentiment": n.sentiment,
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