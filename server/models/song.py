from sqlalchemy import TEXT, VARCHAR, Column
from models.base import Base
from sqlalchemy.orm import relationship


class Song(Base):
    __tablename__ = 'songs'

    id = Column(TEXT, primary_key=True)
    song_url = Column(TEXT)
    thumbnail_url = Column(TEXT)
    artist = Column(TEXT)
    song_name = Column(VARCHAR(100))
    hex_code = Column(VARCHAR(6))
    genres = relationship('Genre', secondary='song_genre_association', back_populates='songs')