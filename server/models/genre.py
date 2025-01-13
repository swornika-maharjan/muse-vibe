from sqlalchemy import Column,TEXT
from sqlalchemy import TEXT, VARCHAR, Column
from models.base import Base
from sqlalchemy.orm import relationship

class Genre(Base):
    __tablename__ = "genres"

    id = Column(TEXT, primary_key=True)
    name = Column(TEXT, unique=True)

    songs = relationship('Song', secondary='song_genre_association', back_populates='genres')
    liked_by_users = relationship('User', secondary='user_genre_association', back_populates='liked_genres')