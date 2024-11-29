from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import pg8000

DATABASE_URL = 'postgresql+pg8000://postgres:1234@localhost:5433/fluttermusicapp'


engine= create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit= False, autoflush= False, bind=engine)

def get_db():   
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()