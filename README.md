<<<<<<< HEAD
# market_pulse

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
=======
# MarketPulse - 해외 기업 뉴스 크롤링 & 감정 분석

이 프로젝트는 FastAPI와 NewsAPI를 이용해 해외 기업 뉴스를 주기적으로 수집하고, MySQL에 저장하는 뉴스 크롤링 서버입니다. 또한 기사 본문을 추출해 별도의 감정 분석(sentiment analysis)에 활용할 수 있습니다.

---

## 🛠️ 기술 스택

- **Backend**: Python, FastAPI
- **DB**: MySQL
- **HTTP 요청**: Requests
- **ORM**: SQLAlchemy
- **스케줄러**: APScheduler
- **뉴스 본문 추출**: Newspaper3k
- **감정 분석**: 별도 `sentiment.py` 모듈

---

## 📦 적용 방법

```bash
1. GitHub 저장소 클론

git clone https://github.com/yourusername/MarketPulse.git
cd MarketPulse

2. 가상환경 생성 및 활성화

python -m venv .venv
# Windows
.venv\Scripts\activate
# macOS/Linux
source .venv/bin/activate

3. 필요 패키지 설치

pip install -r requirements.txt


4. .env 파일 생성 및 NewsAPI Key 설정

NEWS_API_KEY=your_newsapi_key_here

5. MySQL에서 데이터베이스 생성

CREATE DATABASE news_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

6. server.py에서 DB 접속 정보 확인

DB_USER = "root"
DB_PASS = "1234"
DB_HOST = "localhost"
DB_NAME = "news_db"

7. server.py 실행

uvicorn server:app
>>>>>>> 7738bbb914893151230f184ed14d401df06655c9
