from sqlalchemy import TEXT, VARCHAR, Column, LargeBinary
from models.base import Base
from sqlalchemy.orm import relationship

class User(Base):
    __tablename__ = 'users'

    id = Column(TEXT, primary_key=True)
    name = Column(VARCHAR(100))
    email = Column(VARCHAR(100))
    password = Column(LargeBinary)

    favorites = relationship('Favorite', back_populates='user')
    liked_genres = relationship('Genre', secondary='user_genre_association', back_populates='liked_by_users')