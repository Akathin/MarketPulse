from sqlalchemy import Column, Integer, String, DateTime
import datetime
from database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String(50), unique=True, index=True, nullable=False)
    username = Column(String(50), nullable=False)
    user_pw = Column(String(255), nullable=False)
    phone_number = Column(String(15), unique=True, nullable=False)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)


class News(Base):
    __tablename__ = "news"

    id = Column(Integer, primary_key=True, index=True)
    company = Column(String(255), index=True)
    title = Column(String(500))
    url = Column(String(500), unique=True, index=True)
    description = Column(String)
    published_at = Column(DateTime)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)