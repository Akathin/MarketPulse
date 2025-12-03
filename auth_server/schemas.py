from pydantic import BaseModel, Field, validator
from typing import Optional


class Token(BaseModel):
    """토큰 응답 모델"""
    access_token: str
    token_type: str


class TokenData(BaseModel):
    """토큰 데이터 모델"""
    user_id: Optional[str] = None


class UserLogin(BaseModel):
    """사용자 로그인 요청 모델"""
    user_id: str
    password: str


class UserCreate(BaseModel):
    """사용자 회원가입 요청 모델"""
    user_id: str = Field(..., min_length=3, max_length=50)
    password: str = Field(..., min_length=8)
    password_confirm: str = Field(..., min_length=8)

    @validator('password_confirm')
    def passwords_match(cls, v, values, **kwargs):
        if 'password' in values and v != values['password']:
            raise ValueError('비밀번호가 일치하지 않습니다')
        return v


class UserIdCheck(BaseModel):
    """사용자 ID 중복 확인 요청 모델"""
    user_id: str = Field(..., min_length=3, max_length=50)


class ResetPasswordOnlyRequest(BaseModel):
    """비밀번호 재설정"""
    user_id: str
    new_password: str