# MarketPulse — 해외 기업 뉴스 크롤링 & 감정 분석

MarketPulse는 FastAPI 백엔드로 NewsAPI에서 해외 기업 뉴스를 주기적으로 수집하고 MySQL에 저장합니다. 기사 본문은 `newspaper3k`로 추출하며, `sentiment.py`(FinBERT)로 감정 분석을 수행합니다. 또한 옵션으로 영어 본문을 한국어로 요약해 `summary_ko`에 저장하는 파이프라인을 제공합니다 (OpenAI 또는 로컬 모델 사용).

---

핵심 파일

- `server.py`: 뉴스 수집, 스케줄러, 구독 API, 요약 통합
- `sentiment.py`: FinBERT 기반 감정 분석
- `auth_server/`: 인증 관련 FastAPI 서비스 (JWT)
- `db.txt`: DB 스키마 및 마이그레이션 참고 SQL
- `market_pulse/`: Flutter 클라이언트 (앱)

---

빠른 시작 (Windows, PowerShell)

1. 저장소 클론

```powershell
git clone https://github.com/yourusername/MarketPulse.git
cd MarketPulse
```

2. 가상환경 생성 및 활성화

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
```

3. 의존성 설치

```powershell
pip install -r requirements.txt
```

4. 환경 변수 설정

```powershell
copy .env.example .env
# 편집: .env 에 NEWS_API_KEY, OPENAI_API_KEY 채우기
```

5. MySQL 데이터베이스 준비(db.txt 복사)

```sql
CREATE DATABASE news_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

6. 서버 실행

```powershell
uvicorn server:app
```

7. Flutter 클라이언트 실행

```powershell
cd market_pulse
flutter pub get
flutter run
```

---

요약 파이프라인(선택 사항)

- `.env`에 `OPENAI_API_KEY`를 설정하면 `server.py`의 크롤러가 추출한 영어 본문을 OpenAI로 요약해 `summary_ko`에 저장합니다. 키가 없으면 요약 단계는 건너뜁니다.

---

추가 참고

- 구독 관련: `POST /subscribe`, `POST /unsubscribe`, `GET /subscriptions` 엔드포인트를 통해 사용자가 관심 기업을 관리하면 스케줄러는 구독 기업만 우선 크롤링합니다.

문제가 발생하면 `uvicorn` 로그와 `.env` 설정, DB 접속 정보를 보여주시면 도와드리겠습니다.
