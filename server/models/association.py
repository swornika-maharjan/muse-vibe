from sqlalchemy import Table, Column, TEXT, ForeignKey
from models.base import Base

# Song-Genre Association
song_genre_association = Table(
    'song_genre_association',
    Base.metadata,
    Column('song_id', TEXT, ForeignKey('songs.id'), primary_key=True),
    Column('genre_id', TEXT, ForeignKey('genres.id'), primary_key=True)
)

# User-Genre Association
user_genre_association = Table(
    'user_genre_association',
    Base.metadata,
    Column('user_id', TEXT, ForeignKey('users.id'), primary_key=True),
    Column('genre_id', TEXT, ForeignKey('genres.id'), primary_key=True)
)