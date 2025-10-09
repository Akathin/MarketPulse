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
    username: str = Field(..., min_length=2, max_length=50)
    password: str = Field(..., min_length=8)
    password_confirm: str = Field(..., min_length=8)
    phone_number: str = Field(..., min_length=10, max_length=15)

    @validator('password_confirm')
    def passwords_match(cls, v, values, **kwargs):
        if 'password' in values and v != values['password']:
            raise ValueError('비밀번호가 일치하지 않습니다')
        return v


class UserIdCheck(BaseModel):
    """사용자 ID 중복 확인 요청 모델"""
    user_id: str = Field(..., min_length=3, max_length=50)


class FindUserId(BaseModel):
    """아이디 찾기 요청 모델"""
    username: str = Field(..., min_length=2, max_length=50, description="사용자 이름")
    phone_number: str = Field(..., min_length=10, max_length=15)


class VerifyResetUserRequest(BaseModel):
    """비밀번호 재설정 사용자 확인"""
    user_id: str
    phone_number: str


class ResetPasswordOnlyRequest(BaseModel):
    """비밀번호 재설정"""
    user_id: str
    new_password: str