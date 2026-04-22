import os
import io
import torch
import uvicorn
import pymysql
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from PIL import Image
from typing import List, Optional
from datetime import datetime

app = FastAPI()

# Cho phép tất cả các nguồn truy cập (Web/Mobile/Desktop)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Cấu hình MySQL/XAMPP
MYSQL_HOST = os.getenv("MYSQL_HOST", "127.0.0.1")
MYSQL_PORT = int(os.getenv("MYSQL_PORT", "3306"))
MYSQL_USER = os.getenv("MYSQL_USER", "root")
MYSQL_PASSWORD = os.getenv("MYSQL_PASSWORD", "")
MYSQL_DB = os.getenv("MYSQL_DB", "emotion_system")

# Load model (Sử dụng YOLOv5/v8 hoặc PyTorch tùy vào cách bạn train)
# Lưu ý: Bạn cần cài đặt thư viện ultralytics hoặc torch
model = None


def load_model():
    global model
    if model is None:
        try:
            model = torch.hub.load(
                'ultralytics/yolov5',
                'custom',
                path='../app/src/main/assets/best.pt',
            )
        except Exception as exc:
            print('Could not load model:', exc)
            model = None
    return model


def get_db_connection():
    return pymysql.connect(
        host=MYSQL_HOST,
        port=MYSQL_PORT,
        user=MYSQL_USER,
        password=MYSQL_PASSWORD,
        db=MYSQL_DB,
        cursorclass=pymysql.cursors.DictCursor,
        charset='utf8mb4',
    )


class UserRegisterRequest(BaseModel):
    name: str
    email: str
    password: str


class UserLoginRequest(BaseModel):
    email: str
    password: str


class UserResponse(BaseModel):
    id: int
    name: str
    email: str
    role: str
    created_at: datetime


class StudySessionResponse(BaseModel):
    id: int
    user_id: int
    start_time: datetime
    end_time: Optional[datetime]
    duration: Optional[int]
    status: Optional[str]
    created_at: datetime


class VideoResponse(BaseModel):
    id: int
    user_id: int
    file_path: str
    duration: Optional[int]
    status: Optional[str]
    created_at: datetime


@app.get("/")
def root():
    return {"status": "ok", "message": "Backend is running"}


@app.get("/login")
def login_get():
    return {"detail": "Use POST /login with email and password"}


@app.get("/register")
def register_get():
    return {"detail": "Use POST /register with name, email, password"}


@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    request_object_content = await file.read()
    img = Image.open(io.BytesIO(request_object_content))

    loaded_model = load_model()
    if loaded_model is None:
        raise HTTPException(status_code=500, detail="Model is not available")

    results = loaded_model(img)
    detections = results.pandas().xyxy[0]

    if not detections.empty:
        label = detections.iloc[0]['name']
        confidence = float(detections.iloc[0]['confidence'])
        focus_score = confidence if label == 'focus' else (1 - confidence)
        return {"focus_level": round(focus_score, 2), "label": label}

    return {"focus_level": 0.5, "label": "neutral"}


@app.post("/register", response_model=UserResponse)
def register_user(user: UserRegisterRequest):
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute("SELECT id FROM users WHERE email = %s", (user.email,))
                if cursor.fetchone():
                    raise HTTPException(status_code=400, detail="Email đã tồn tại")

                cursor.execute(
                    "INSERT INTO users (name, email, password, role) VALUES (%s, %s, %s, %s)",
                    (user.name, user.email, user.password, 'student'),
                )
                conn.commit()
                user_id = cursor.lastrowid
                cursor.execute("SELECT * FROM users WHERE id = %s", (user_id,))
                row = cursor.fetchone()
                return row
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


@app.post("/login", response_model=UserResponse)
def login_user(credentials: UserLoginRequest):
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute(
                    "SELECT * FROM users WHERE email = %s AND password = %s",
                    (credentials.email, credentials.password),
                )
                row = cursor.fetchone()
                if not row:
                    raise HTTPException(status_code=401, detail="Email hoặc mật khẩu không đúng")
                return row
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


@app.get("/study/history", response_model=List[StudySessionResponse])
def study_history(user_id: Optional[int] = None):
    query = "SELECT * FROM study_sessions"
    params = []
    if user_id is not None:
        query += " WHERE user_id = %s"
        params = [user_id]

    try:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute(query, params)
                rows = cursor.fetchall()
                return rows
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


@app.post("/study", response_model=StudySessionResponse)
def save_study_session(session: StudySessionResponse):
    query = (
        "INSERT INTO study_sessions (user_id, start_time, end_time, duration, status, created_at) "
        "VALUES (%s, %s, %s, %s, %s, %s)"
    )
    values = [
        session.user_id,
        session.start_time,
        session.end_time,
        session.duration,
        session.status,
        session.created_at,
    ]

    try:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute(query, values)
                conn.commit()
                session_id = cursor.lastrowid
                cursor.execute("SELECT * FROM study_sessions WHERE id = %s", (session_id,))
                return cursor.fetchone()
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


@app.get("/admin/videos", response_model=List[VideoResponse])
def admin_videos():
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute("SELECT * FROM videos ORDER BY created_at DESC")
                return cursor.fetchall()
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


@app.delete("/admin/videos/{video_id}")
def delete_video(video_id: int):
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute("DELETE FROM videos WHERE id = %s", (video_id,))
                deleted = cursor.rowcount
                conn.commit()
                if deleted == 0:
                    raise HTTPException(status_code=404, detail="Video not found")
                return {"success": True}
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


@app.get("/admin/dashboard")
def admin_dashboard():
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute("SELECT COUNT(*) AS total_videos FROM videos")
                videos = cursor.fetchone()
                cursor.execute("SELECT COUNT(*) AS total_sessions FROM study_sessions")
                sessions = cursor.fetchone()
                return {
                    "totalVideos": videos['total_videos'],
                    "totalSessions": sessions['total_sessions'],
                }
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
