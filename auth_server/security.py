import hashlib
from jose import jwt
from datetime import datetime, timedelta
from typing import Optional

# JWT 설정
SECRET_KEY = "your-secret-key-here-change-in-production"  # 실제 운영환경에서는 환경변수로 관리
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30


def _hash_password_sha256(password: str) -> str:
    """SHA-256으로 비밀번호 해싱 (학습/개발용 – 실제 서비스에는 적합하지 않음)."""
    return hashlib.sha256(password.encode("utf-8")).hexdigest()


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """비밀번호 검증"""
    return _hash_password_sha256(plain_password) == hashed_password


def get_password_hash(password: str) -> str:
    """비밀번호 해싱"""
    return _hash_password_sha256(password)


def create_access_token(subject: str, expires_delta: Optional[timedelta] = None) -> str:
    """JWT 액세스 토큰 생성"""
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)

    to_encode = {"exp": expire, "sub": subject}
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
