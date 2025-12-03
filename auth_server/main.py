import os
from dotenv import load_dotenv
from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from datetime import timedelta, datetime
from jose import JWTError, jwt
from typing import Dict

from auth_server.models import Base, User
from auth_server.schemas import (
    Token, TokenData, UserCreate, UserIdCheck,
    ResetPasswordOnlyRequest,
)
from auth_server.security import (
    verify_password, get_password_hash, create_access_token,
    SECRET_KEY, ALGORITHM, ACCESS_TOKEN_EXPIRE_MINUTES
)

load_dotenv()

from auth_server.models import Base, User

print("DEBUG User columns =>", User.__table__.columns) #debug line

# ----------------------
# MySQL 세팅
# ----------------------
DB_USER = os.getenv("DB_USER", "root")
DB_PASS = os.getenv("DB_PASS", "1234")
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_NAME = os.getenv("DB_NAME", "news_db")

DATABASE_URL = f"mysql+pymysql://{DB_USER}:{DB_PASS}@{DB_HOST}/{DB_NAME}?charset=utf8mb4"
engine = create_engine(DATABASE_URL, pool_pre_ping=True)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base.metadata.create_all(bind=engine)

# ----------------------
# FastAPI 앱
# ----------------------
app = FastAPI(title="MarketPulse Auth Service", version="1.0.0")

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 프로덕션에서는 특정 origin만 허용
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="api/auth/login")

# ----------------------
# 로그인 시도 추적
# ----------------------
login_attempts: Dict[str, Dict] = {}
LOCKOUT_DURATION = 30
MAX_ATTEMPTS = 5


# ----------------------
# DB 의존성
# ----------------------
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# ----------------------
# 인증 함수들
# ----------------------
def check_login_attempts(user_id: str) -> None:
    """로그인 시도 횟수 확인"""
    current_time = datetime.now()

    if user_id in login_attempts:
        user_data = login_attempts[user_id]

        if user_data.get("lockout_until"):
            if current_time < user_data["lockout_until"]:
                remaining_time = (user_data["lockout_until"] - current_time).seconds
                raise HTTPException(
                    status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                    detail=f"너무 많은 로그인 시도. {remaining_time}초 후에 다시 시도해주세요.",
                    headers={"Retry-After": str(remaining_time)}
                )
            else:
                login_attempts[user_id] = {"attempts": 0, "lockout_until": None}

        if user_data["attempts"] >= MAX_ATTEMPTS:
            login_attempts[user_id]["lockout_until"] = current_time + timedelta(seconds=LOCKOUT_DURATION)
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail=f"너무 많은 로그인 시도. {LOCKOUT_DURATION}초 후에 다시 시도해주세요.",
                headers={"Retry-After": str(LOCKOUT_DURATION)}
            )
    else:
        login_attempts[user_id] = {"attempts": 0, "lockout_until": None}


def record_login_attempt(user_id: str, success: bool) -> None:
    """로그인 시도 기록"""
    if success:
        if user_id in login_attempts:
            del login_attempts[user_id]
    else:
        if user_id not in login_attempts:
            login_attempts[user_id] = {"attempts": 0, "lockout_until": None}
        login_attempts[user_id]["attempts"] += 1


def authenticate_user(db: Session, user_id: str, password: str):
    """사용자 인증"""
    user = db.query(User).filter(User.user_id == user_id).first()
    if not user or not verify_password(password, user.user_pw):
        return None
    return user


async def get_current_user(
        token: str = Depends(oauth2_scheme),
        db: Session = Depends(get_db)
) -> User:
    """현재 인증된 사용자 가져오기"""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="인증 정보가 유효하지 않습니다",
        headers={"WWW-Authenticate": "Bearer"},
    )

    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: str = payload.get("sub")
        if user_id is None:
            raise credentials_exception
        token_data = TokenData(user_id=user_id)
    except JWTError:
        raise credentials_exception

    user = db.query(User).filter(User.user_id == token_data.user_id).first()
    if user is None:
        raise credentials_exception

    return user


# ----------------------
# API 엔드포인트
# ----------------------
@app.get("/", tags=["Root"])
def read_root():
    """API 루트"""
    return {
        "service": "MarketPulse Auth Service",
        "version": "1.0.0",
        "status": "running"
    }


@app.post("/api/auth/register", response_model=Token, tags=["Authentication"])
async def register(user_create: UserCreate, db: Session = Depends(get_db)):
    """회원가입"""

    # user_id 중복 체크
    if db.query(User).filter(User.user_id == user_create.user_id).first():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="이미 등록된 사용자 ID입니다",
        )

    # 비밀번호 해시 후 저장
    hashed_password = get_password_hash(user_create.password)
    db_user = User(
        user_id=user_create.user_id,
        user_pw=hashed_password,
    )

    db.add(db_user)
    db.commit()
    db.refresh(db_user)

    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        subject=db_user.user_id,
        expires_delta=access_token_expires,
    )

    return {"access_token": access_token, "token_type": "bearer"}




@app.post("/api/auth/login", response_model=Token, tags=["Authentication"])
async def login(
        form_data: OAuth2PasswordRequestForm = Depends(),
        db: Session = Depends(get_db)
):
    """로그인"""
    user_id = form_data.username
    check_login_attempts(user_id)

    user = authenticate_user(db, user_id, form_data.password)

    if not user:
        record_login_attempt(user_id, False)
        attempts_left = MAX_ATTEMPTS - login_attempts[user_id]["attempts"]

        if attempts_left > 0:
            detail_message = f"사용자 ID 또는 비밀번호가 올바르지 않습니다. (남은 시도: {attempts_left}회)"
        else:
            detail_message = f"로그인 시도 횟수를 초과했습니다. {LOCKOUT_DURATION}초 후에 다시 시도해주세요."

        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=detail_message,
            headers={"WWW-Authenticate": "Bearer"},
        )

    record_login_attempt(user_id, True)

    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        subject=user.user_id,
        expires_delta=access_token_expires
    )

    return {"access_token": access_token, "token_type": "bearer"}


@app.get("/api/auth/me", response_model=TokenData, tags=["Authentication"])
async def read_users_me(current_user: User = Depends(get_current_user)):
    """현재 로그인한 사용자 정보"""
    return TokenData(user_id=current_user.user_id)


@app.post("/api/auth/verify", tags=["Authentication"])
async def verify_token(token: str, db: Session = Depends(get_db)):
    """토큰 검증 (다른 서비스에서 사용)"""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: str = payload.get("sub")
        if user_id is None:
            raise HTTPException(status_code=401, detail="Invalid token")

        user = db.query(User).filter(User.user_id == user_id).first()
        if user is None:
            raise HTTPException(status_code=401, detail="User not found")

        return {
            "valid": True,
            "user_id": user_id,
            "username": user.username
        }
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")


@app.post("/api/auth/check-userid", tags=["Authentication"])
async def check_user_id(user_id_check: UserIdCheck, db: Session = Depends(get_db)):
    """사용자 ID 중복 확인"""
    db_user = db.query(User).filter(User.user_id == user_id_check.user_id).first()

    if db_user:
        return {"available": False, "message": "이미 사용 중인 사용자 ID입니다."}

    return {"available": True, "message": "사용 가능한 사용자 ID입니다."}






if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8001)
