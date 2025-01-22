import uuid
from fastapi import APIRouter, Depends, File, Form, UploadFile
from sqlalchemy.orm import Session
from database import get_db
from middleware.auth_middleware import auth_middleware
import cloudinary
import cloudinary.uploader
from models.favourite import Favorite
from models.song import Song
from models.genre import Genre
from models.association import song_genre_association, user_genre_association
from sqlalchemy.orm import joinedload
from pydantic_schemas.favourite_song import FavoriteSong
from math import log



router = APIRouter()

cloudinary.config( 
    cloud_name = "dmam7tf8t", 
    api_key = "617259743767223",
    api_secret = "edpL9kvpgb_7c614J4-OI6gLZ9Y",
    secure=True
)

@router.post('/upload', status_code=201)
def upload_song(song: UploadFile = File(...), 
                thumbnail: UploadFile = File(...), 
                artist: str = Form(...), 
                song_name: str = Form(...), 
                hex_code: str = Form(...),
                genres: list[str] = Form(...),
                db: Session = Depends(get_db),
                auth_dict = Depends(auth_middleware)):
    song_id = str(uuid.uuid4())
    song_res = cloudinary.uploader.upload(song.file, resource_type='auto', folder=f'songs/{song_id}')
    thumbnail_res = cloudinary.uploader.upload(thumbnail.file, resource_type='image', folder=f'songs/{song_id}')
    
    new_song = Song(
        id=song_id,
        song_name=song_name,
        artist=artist,
        hex_code=hex_code,
        song_url=song_res['url'],
        thumbnail_url = thumbnail_res['url'],
    )

    genre_objs = []
    for genre_name in genres:
        # Check if the genre already exists in the database
        genre = db.query(Genre).filter(Genre.name == genre_name).first()
        if not genre:
            # Create a new genre if it doesn't exist
            genre = Genre(id=str(uuid.uuid4()), name=genre_name)
            db.add(genre)
        genre_objs.append(genre)
    
    # Associate genres with the song
    new_song.genres = genre_objs

    db.add(new_song)
    db.commit()
    db.refresh(new_song)
    return new_song

@router.get('/list')
def list_songs(db: Session=Depends(get_db), 
               auth_details=Depends(auth_middleware)):
    songs = db.query(Song).all()
    return songs

@router.post('/add-genre', status_code=201)
def add_genre(
    name: str = Form(...), 
    song_id: str = Form(None), 
    db: Session = Depends(get_db)
):
    # Check if genre already exists
    existing_genre = db.query(Genre).filter(Genre.name == name).first()
    if existing_genre:
        genre_id = existing_genre.id
    else:
        # Create a new genre if it doesn't exist
        genre_id = str(uuid.uuid4())
        new_genre = Genre(id=genre_id, name=name)
        db.add(new_genre)
        db.commit()

    # Associate genre with a song, if provided
    if song_id:
        song = db.query(Song).filter(Song.id == song_id).first()
        if song:
            association = song_genre_association.insert().values(song_id=song_id, genre_id=genre_id)
            db.execute(association)
            db.commit()
        else:
            return {"error": "Song not found."}

    return {"message": "Genre added successfully.", "genre_id": genre_id}

@router.post('/favorite')
def favorite_song(song: FavoriteSong, 
                  db: Session=Depends(get_db), 
                  auth_details=Depends(auth_middleware)):
    # song is already favorited by the user
    user_id = auth_details['uid']

    fav_song = db.query(Favorite).filter(Favorite.song_id == song.song_id, Favorite.user_id == user_id).first()

    if fav_song:
        db.delete(fav_song)
        db.commit()
        return {'message': False}
    else:
        new_fav = Favorite(id=str(uuid.uuid4()), song_id=song.song_id, user_id=user_id)
        db.add(new_fav)
        db.commit()
        return {'message': True}
    
@router.get('/list/favorites')
def list_fav_songs(db: Session=Depends(get_db), 
               auth_details=Depends(auth_middleware)):
    user_id = auth_details['uid']
    fav_songs = db.query(Favorite).filter(Favorite.user_id == user_id).options(
        joinedload(Favorite.song),
    ).all()
    
    return fav_songs


@router.get('/user/genres/check')
def check_user_genres(db: Session = Depends(get_db), 
                      auth_details = Depends(auth_middleware)):
    user_id = auth_details['uid']
    
    # Check if the user has any associated genres
    has_genres = db.query(user_genre_association).filter(user_genre_association.c.user_id == user_id).first()
    
    if has_genres:
        return {'has_genres': True}
    
    # Fetch all distinct genres from the Genre table
    all_genres = db.query(Genre).all()
    distinct_genres = [{'id': genre.id, 'name': genre.name} for genre in all_genres]

    return {
        'has_genres': False,
        'available_genres': distinct_genres
    }


@router.post('/user/genres/add', status_code=201)
def add_user_genres(genres: list[str], 
                    db: Session = Depends(get_db), 
                    auth_details = Depends(auth_middleware)):
    user_id = auth_details['uid']
    
    added_genres = []
    failed_genres = []

    for genre_name in genres:
        # Check if the genre exists
        genre = db.query(Genre).filter(Genre.name == genre_name).first()
        if not genre:
            failed_genres.append(genre_name)
            continue
        
        # Check if the association already exists
        existing_association = db.query(user_genre_association).filter(
            user_genre_association.c.user_id == user_id,
            user_genre_association.c.genre_id == genre.id
        ).first()
        
        if existing_association:
            continue  # Skip if the association already exists
        
        # Add the new association
        association = user_genre_association.insert().values(user_id=user_id, genre_id=genre.id)
        db.execute(association)
        db.commit()
        added_genres.append(genre_name)

    return {
        "message": "User-genre associations processed.",
        "added_genres": added_genres,
        "failed_genres": failed_genres
    }


@router.get('/recommend')
def recommendation_songs(db: Session = Depends(get_db), 
                          auth_details = Depends(auth_middleware)):
    user_id = auth_details['uid']

    # Fetch all user likes from the database
    favorites = db.query(Favorite).all()

    # Prepare the data as a list of dictionaries
    data = [{'user_id': fav.user_id, 'song_id': fav.song_id} for fav in favorites]

    # Extract unique users and songs
    users = list(set([entry['user_id'] for entry in data]))
    songs = list(set([entry['song_id'] for entry in data]))

    # Create a user-song interaction matrix
    interaction_matrix = {user: {song: 0 for song in songs} for user in users}
    for entry in data:
        interaction_matrix[entry['user_id']][entry['song_id']] = 1
        # if user_id not in interaction_matrix:
        if user_id not in interaction_matrix:
            interaction_matrix[user_id] = {song: 0 for song in songs}
        #     return 0

    # Compute cosine similarity between users manually
    def cosine_similarity_manual(user_a, user_b):
        a_vector = [interaction_matrix[user_a][song] for song in songs]
        b_vector = [interaction_matrix[user_b][song] for song in songs]
        dot_product = sum(a * b for a, b in zip(a_vector, b_vector))
        magnitude_a = sum(a * a for a in a_vector) ** 0.5
        magnitude_b = sum(b * b for b in b_vector) ** 0.5
        if magnitude_a == 0 or magnitude_b == 0:
            return 0
        return dot_product / (magnitude_a * magnitude_b)

    # Calculate similarity scores for all users relative to the current user
    user_similarity_scores = {other_user: cosine_similarity_manual(user_id, other_user) for other_user in users if other_user != user_id}

    # Filter similar users with similarity > 0.5
    similar_users = [other_user for other_user, score in user_similarity_scores.items() if score > 0.5]

    # Collect recommended songs based on similar users' likes
    recommended_song_ids = set()
    for sim_user in similar_users:
        sim_user_songs = [song for song, liked in interaction_matrix[sim_user].items() if liked == 1]
        recommended_song_ids.update(sim_user_songs)

    # Exclude songs the user already likes
    user_songs = [song for song, liked in interaction_matrix[user_id].items() if liked == 1]
    recommended_song_ids.difference_update(user_songs)

    # Check if collaborative recommendations are less than 2
    if len(recommended_song_ids) < 2:
        # Fetch additional recommendations from content-based filtering
        content_based = content_based_recommendations(user_id, db)
        
        # Convert content-based results to a set of song IDs
        content_based_song_ids = {song['id'] for song in content_based}

        # Merge collaborative and content-based recommendations
        recommended_song_ids.update(content_based_song_ids)

    # If no recommendations, return empty list
    if not recommended_song_ids:
        return []

    # Fetch recommended songs from the database
    recommended_songs = db.query(Song).filter(Song.id.in_(list(recommended_song_ids))).all()

    # Format the response as a list of dictionaries
    recommended_songs_dict = [{
        'id': song.id,
        'song_url': song.song_url,
        'thumbnail_url': song.thumbnail_url,
        'artist': song.artist,
        'song_name': song.song_name,
        'hex_code': song.hex_code
    } for song in recommended_songs]

    return recommended_songs_dict

def content_based_recommendations(user_id: str, db: Session):
    # Fetch the genres the user likes
    liked_genres = (
        db.query(Genre.id)
        .join(user_genre_association, user_genre_association.c.genre_id == Genre.id)
        .filter(user_genre_association.c.user_id == user_id)
        .all()
    )
    liked_genre_ids = [genre.id for genre in liked_genres]

    if not liked_genre_ids:
        return []  # If no genres are associated, return an empty list

    # Fetch user's already liked songs
    user_liked_songs = (
        db.query(Favorite.song_id)
        .filter(Favorite.user_id == user_id)
        .all()
    )
    liked_song_ids = {fav.song_id for fav in user_liked_songs}

    # Fetch songs that match the liked genres and are not already liked
    songs_in_liked_genres = (
        db.query(Song)
        .join(song_genre_association, song_genre_association.c.song_id == Song.id)
        .filter(song_genre_association.c.genre_id.in_(liked_genre_ids))
        .filter(Song.id.notin_(liked_song_ids))
        .all()
    )

    # If no songs are found, return an empty list
    if not songs_in_liked_genres:
        return []

    # Map songs to their genres
    songs_with_genres = (
        db.query(Song.id, song_genre_association.c.genre_id)
        .join(song_genre_association, song_genre_association.c.song_id == Song.id)
        .filter(Song.id.in_([song.id for song in songs_in_liked_genres]))
        .all()
    )

    song_to_genres = {}
    for song_id, genre_id in songs_with_genres:
        if song_id not in song_to_genres:
            song_to_genres[song_id] = set()
        song_to_genres[song_id].add(genre_id)

    # Compute TF (genre frequency per song)
    genre_to_song_count = {}
    for genres in song_to_genres.values():
        for genre in genres:
            genre_to_song_count[genre] = genre_to_song_count.get(genre, 0) + 1

    # Compute IDF (inverse user frequency for each genre)
    user_genre_counts = (
        db.query(user_genre_association.c.genre_id)
        .distinct()
        .count()
    )
    genre_to_idf = {
        genre: log(user_genre_counts / (1 + genre_to_song_count[genre]))
        for genre in genre_to_song_count
    }

    # Compute scores for each song based on liked genres
    song_scores = {}
    for song_id, genres in song_to_genres.items():
        score = sum(genre_to_idf.get(genre, 0) for genre in genres if genre in liked_genre_ids)
        song_scores[song_id] = score

    # Sort songs by their scores
    sorted_song_ids = sorted(song_scores, key=song_scores.get, reverse=True)

    # Fetch song details for the recommendations
    recommended_songs = (
        db.query(Song)
        .filter(Song.id.in_(sorted_song_ids))
        .all()
    )

    # Format the response as a list of dictionaries
    recommended_songs_dict = [
        {
            'id': song.id,
            'song_url': song.song_url,
            'thumbnail_url': song.thumbnail_url,
            'artist': song.artist,
            'song_name': song.song_name,
            'hex_code': song.hex_code
        }
        for song in recommended_songs
    ]

    return recommended_songs_dict



# def content_based_recommendations(user_id: str, db: Session):
#     # Fetch the genres the user likes
#     liked_genres = (
#         db.query(Genre.id)
#         .join(user_genre_association, user_genre_association.c.genre_id == Genre.id)
#         .filter(user_genre_association.c.user_id == user_id)
#         .all()
#     )
#     liked_genre_ids = [genre.id for genre in liked_genres]

#     if not liked_genre_ids:
#         return []  # If no genres are associated, return an empty list

#     # Fetch songs in the liked genres but exclude already liked songs
#     user_liked_songs = (
#         db.query(Favorite.song_id)
#         .filter(Favorite.user_id == user_id)
#         .all()
#     )
#     liked_song_ids = [fav.song_id for fav in user_liked_songs]

#     recommended_songs = (
#         db.query(Song)
#         .join(song_genre_association, song_genre_association.c.song_id == Song.id)
#         .filter(song_genre_association.c.genre_id.in_(liked_genre_ids))
#         .filter(Song.id.notin_(liked_song_ids))
#         .all()
#     )

#     # Format the response as a list of dictionaries
#     recommended_songs_dict = [
#         {
#             'id': song.id,
#             'song_url': song.song_url,
#             'thumbnail_url': song.thumbnail_url,
#             'artist': song.artist,
#             'song_name': song.song_name,
#             'hex_code': song.hex_code
#         }
#         for song in recommended_songs
#     ]

#     return recommended_songs_dict




