import os
from dotenv import load_dotenv
from dateutil import parser
from fastapi import FastAPI
from apscheduler.schedulers.background import BackgroundScheduler
from sqlalchemy import create_engine, Column, Integer, String, DateTime, select
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
    published_at = Column(String)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)


Base.metadata.create_all(bind=engine)

# ----------------------
# FastAPI 앱
# ----------------------
app = FastAPI()

load_dotenv()
NEWS_API_KEY = os.getenv("NEWS_API_KEY")

# 해외 기업 리스트 (임시)
COMPANIES = ["Apple", "Tesla", "Amazon", "Google", "Microsoft", "NVIDIA", "Meta"]

#기사 본문 추출 함수
def extract_full_text(url: str) -> str:
    try:
        article = Article(url)
        article.download()
        article.parse()
        return article.text
    except Exception:
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

        # 감정 분석
        sentiment_result = analyze_sentiment(full_text) if full_text else "neutral"

        # publishedAt 파싱
        published_at = parser.isoparse(item["publishedAt"]).replace(tzinfo=None)

        news = News(
            company=company,
            title=item["title"],
            url=item["url"],
            description=item["description"],
            content=full_text,
            sentiment=sentiment_result,   # 추가
            published_at=published_at,
        )
        db.add(news)

    db.commit()
    db.close()
    print(f"[{datetime.datetime.now()}] {company} 뉴스 갱신 완료")

# ----------------------
# 스케줄러 (15분마다 모든 기업 뉴스 갱신)
# ----------------------
def update_all_news():
    for company in COMPANIES:
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
    return [
        {
            "company": n.company,
            "title": n.title,
            "url": n.url,
            "description": n.description,
            "publishedAt": n.published_at,
        }
        for n in news_list
    ]
@app.on_event("startup")
def startup_event():
    update_all_news()  # 서버 시작 시 한 번 뉴스 갱신