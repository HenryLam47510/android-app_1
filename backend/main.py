import os
import io
import torch
import uvicorn
import pymysql
import tempfile
from fastapi import FastAPI, File, UploadFile, Form, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
from pydantic import BaseModel, Field
from PIL import Image
from typing import List, Optional, Dict
from datetime import datetime
from video_processor import VideoProcessor
from concentration_calculator import ConcentrationCalculator

try:
    from ultralytics import YOLO
except Exception:
    YOLO = None

app = FastAPI()

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# Tạo thư mục uploads/segments khi khởi động
UPLOAD_SEGMENTS_DIR = os.path.join(BASE_DIR, 'uploads', 'segments')
os.makedirs(UPLOAD_SEGMENTS_DIR, exist_ok=True)

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
        model_path = os.path.join(BASE_DIR, 'AI', 'best.pt')

        if not os.path.exists(model_path):
            print("Model file not found:", model_path)
            return None

        try:
            model = YOLO(model_path)
            print("Model loaded successfully")
        except Exception as exc:
            print("Could not load model:", exc)
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


def _load_video_segments(cursor, video_id: int):
    cursor.execute(
        "SELECT * FROM video_segments WHERE video_id = %s ORDER BY segment_number ASC",
        (video_id,),
    )
    return cursor.fetchall()


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


class VideoSegmentResponse(BaseModel):
    id: int
    video_id: int
    user_id: int
    segment_number: int
    file_path: str
    start_time: Optional[datetime]
    end_time: Optional[datetime]
    duration: Optional[int]
    status: Optional[str]
    created_at: datetime
    concentration_score: Optional[float]
    focus_status: Optional[str]
    focus_emoji: Optional[str]
    emotions: Optional[List[str]]
    emotion_breakdown: Optional[Dict[str, float]]
    dominant_emotion: Optional[str]
    frame_count: Optional[int]
    presence: Optional[float]
    raw_score: Optional[float]


class VideoResponse(BaseModel):
    id: int
    user_id: int
    file_path: str
    duration: Optional[int]
    status: Optional[str]
    created_at: datetime
    segments: List[VideoSegmentResponse] = Field(default_factory=list)


class StudySessionResponse(BaseModel):
    id: int
    user_id: int
    start_time: Optional[datetime]
    end_time: Optional[datetime]
    duration: Optional[int]
    status: Optional[str]
    created_at: datetime
    videos: List[VideoResponse] = Field(default_factory=list)


class AnalyzeResponse(BaseModel):
    concentration_score: float
    focus_status: str
    focus_emoji: str
    emotions: List[str]
    emotion_breakdown: Dict[str, float]
    dominant_emotion: str
    frame_count: int
    presence: float
    raw_score: float


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

    result = results[0]
    boxes = result.boxes

    if boxes is not None and len(boxes) > 0:
        cls_id = int(boxes.cls[0])
        confidence = float(boxes.conf[0])
        label = result.names[cls_id]
    else:
        return {"focus_level": 0.5, "label": "neutral"}

    focus_score = confidence if label == "focus" else (1 - confidence)

    return {
        "focus_level": round(focus_score, 2),
        "label": label
    }

def _analyze_video_file(video_path: str) -> Dict[str, object]:
    loaded_model = load_model()
    if loaded_model is None:
        raise HTTPException(status_code=500, detail="Model is not available")

    processor = VideoProcessor(video_path, target_fps=1)
    frames = processor.extract_frames()
    if not frames:
        raise HTTPException(status_code=400, detail="Không thể lấy frames từ video")

    detection_result = processor.process(loaded_model)
    calculator = ConcentrationCalculator()

    analysis = calculator.analyze(
        frame_emotions=detection_result['frame_emotions'],
        emotion_breakdown=detection_result['emotion_breakdown'],
    )

    return {
        'concentration_score': analysis['concentration_score'],
        'focus_status': analysis['focus_status'],
        'focus_emoji': analysis['focus_emoji'],
        'emotions': detection_result['frame_emotions'],
        'emotion_breakdown': detection_result['emotion_breakdown'],
        'dominant_emotion': detection_result['dominant_emotion'],
        'frame_count': detection_result['total_frames'],
        'presence': analysis['presence'],
        'raw_score': analysis['raw_score'],
    }


@app.post("/analyze", response_model=AnalyzeResponse)
async def analyze_video(file: UploadFile = File(...)):
    """
    Phân tích video 12s:
    1. Extract frames
    2. YOLO phát hiện emotion
    3. Tính concentration score
    """
    try:
        with tempfile.NamedTemporaryFile(delete=False, suffix=".mp4") as tmp_file:
            content = await file.read()
            tmp_file.write(content)
            video_path = tmp_file.name

        try:
            analysis = _analyze_video_file(video_path)
            return AnalyzeResponse(
                concentration_score=analysis['concentration_score'],
                focus_status=analysis['focus_status'],
                focus_emoji=analysis['focus_emoji'],
                emotions=analysis['emotions'],
                emotion_breakdown=analysis['emotion_breakdown'],
                dominant_emotion=analysis['dominant_emotion'],
                frame_count=analysis['frame_count'],
                presence=analysis['presence'],
                raw_score=analysis['raw_score'],
            )
        finally:
            if os.path.exists(video_path):
                os.remove(video_path)
    except HTTPException:
        raise
    except Exception as exc:
        print(f"Lỗi phân tích video: {str(exc)}")
        raise HTTPException(status_code=500, detail=f"Lỗi phân tích: {str(exc)}")


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
    
    query += " ORDER BY created_at DESC"

    try:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute(query, params)
                rows = cursor.fetchall()
                # Convert rows to StudySessionResponse format
                sessions = []
                for row in rows:
                    session = StudySessionResponse(
                        id=row['id'],
                        user_id=row['user_id'],
                        start_time=row['start_time'],
                        end_time=row['end_time'],
                        duration=row.get('duration'),
                        status=row['status'],
                        created_at=row['created_at']
                    )
                    # Load videos for this session
                    video_query = "SELECT * FROM videos WHERE user_id = %s"
                    video_params = [row['user_id']]
                    if row['start_time'] and row['end_time']:
                        video_query += " AND created_at BETWEEN %s AND %s"
                        video_params.extend([row['start_time'], row['end_time']])
                    cursor.execute(video_query, video_params)
                    videos = cursor.fetchall()
                    for video in videos:
                        video["segments"] = _load_video_segments(cursor, video["id"])
                    session.videos = videos
                    sessions.append(session)
                return sessions
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


@app.post("/study", response_model=StudySessionResponse)
def save_study_session(session: StudySessionResponse):
    query = (
        "INSERT INTO study_sessions (user_id, start_time, end_time, status, created_at) "
        "VALUES (%s, %s, %s, %s, %s)"
    )
    values = [
        session.user_id,
        session.start_time,
        session.end_time,
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


@app.post("/upload_segment")
async def upload_segment(
    user_id: int = Form(...),
    segment_number: int = Form(...),
    start_time: str = Form(...),
    end_time: str = Form(...),
    status: str = Form('recorded'),
    video_id: Optional[int] = Form(None),
    file: UploadFile = File(...),
):
    try:
        start_dt = datetime.fromisoformat(start_time)
        end_dt = datetime.fromisoformat(end_time)
    except ValueError:
        raise HTTPException(status_code=400, detail="Thời gian không đúng định dạng ISO 8601")

    try:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                if video_id is None:
                    cursor.execute(
                        "INSERT INTO videos (user_id, file_path, duration, status, created_at) VALUES (%s, %s, %s, %s, %s)",
                        (user_id, '', int((end_dt - start_dt).total_seconds()), 'recorded', datetime.utcnow()),
                    )
                    conn.commit()
                    video_id = cursor.lastrowid
                else:
                    cursor.execute("SELECT id FROM videos WHERE id = %s", (video_id,))
                    if cursor.fetchone() is None:
                        raise HTTPException(status_code=404, detail="Video session not found")

                filename = f"segment_{video_id}_{segment_number}_{int(start_dt.timestamp())}.mp4"
                stored_path = os.path.join(UPLOAD_SEGMENTS_DIR, filename)
                file_content = await file.read()
                with open(stored_path, "wb") as out_file:
                    out_file.write(file_content)

                segment_path = os.path.relpath(stored_path, os.path.dirname(__file__)).replace('\\', '/')
                duration = int((end_dt - start_dt).total_seconds())

                insert_query = (
                    "INSERT INTO video_segments (video_id, user_id, segment_number, file_path, start_time, end_time, duration, status, created_at) "
                    "VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)"
                )
                cursor.execute(
                    insert_query,
                    (
                        video_id,
                        user_id,
                        segment_number,
                        segment_path,
                        start_dt,
                        end_dt,
                        duration,
                        status,
                        datetime.utcnow(),
                    ),
                )
                conn.commit()
                segment_id = cursor.lastrowid
                cursor.execute("SELECT * FROM video_segments WHERE id = %s", (segment_id,))
                segment_data = cursor.fetchone()

        analysis = _analyze_video_file(stored_path)

        # Update segment with analysis data
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                update_query = """
                    UPDATE video_segments SET 
                    concentration_score = %s, focus_status = %s, focus_emoji = %s, 
                    emotions = %s, emotion_breakdown = %s, dominant_emotion = %s, 
                    frame_count = %s, presence = %s, raw_score = %s 
                    WHERE id = %s
                """
                cursor.execute(update_query, (
                    analysis['concentration_score'], analysis['focus_status'], analysis['focus_emoji'],
                    str(analysis['emotions']), str(analysis['emotion_breakdown']), analysis['dominant_emotion'],
                    analysis['frame_count'], analysis['presence'], analysis['raw_score'],
                    segment_id
                ))
                conn.commit()
                # Fetch updated segment
                cursor.execute("SELECT * FROM video_segments WHERE id = %s", (segment_id,))
                segment_data = cursor.fetchone()

        return {
            'segment': segment_data,
            'analysis': analysis,
            'video_id': video_id,
        }
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


@app.get("/videos", response_model=List[VideoResponse])
def list_videos(user_id: Optional[int] = None):
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                query = "SELECT * FROM videos WHERE EXISTS (SELECT 1 FROM video_segments WHERE video_id = videos.id)"
                params = []
                if user_id is not None:
                    query += " AND user_id = %s"
                    params.append(user_id)
                query += " ORDER BY created_at DESC"
                cursor.execute(query, params)
                videos = cursor.fetchall()
                for video in videos:
                    video["segments"] = _load_video_segments(cursor, video["id"])
                return videos
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


@app.get("/videos/{video_id}", response_model=VideoResponse)
def get_video(video_id: int):
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute("SELECT * FROM videos WHERE id = %s", (video_id,))
                video = cursor.fetchone()
                if not video:
                    raise HTTPException(status_code=404, detail="Video not found")
                video["segments"] = _load_video_segments(cursor, video_id)
                return video
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


@app.get("/admin/videos", response_model=List[VideoResponse])
def admin_videos():
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute("""
                    SELECT * FROM videos 
                    WHERE EXISTS (SELECT 1 FROM video_segments WHERE video_id = videos.id)
                    ORDER BY created_at DESC
                """)
                videos = cursor.fetchall()
                for video in videos:
                    video["segments"] = _load_video_segments(cursor, video["id"])
                return videos
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


@app.get("/admin/videos/{video_id}/segments", response_model=List[VideoSegmentResponse])
def admin_video_segments(video_id: int):
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute(
                    "SELECT * FROM video_segments WHERE video_id = %s ORDER BY segment_number ASC",
                    (video_id,),
                )
                return cursor.fetchall()
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


@app.delete("/admin/segments/{segment_id}")
def delete_segment(segment_id: int):
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute("DELETE FROM video_segments WHERE id = %s", (segment_id,))
                deleted = cursor.rowcount
                conn.commit()
                if deleted == 0:
                    raise HTTPException(status_code=404, detail="Segment not found")
                return {"success": True}
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


@app.get("/admin/videos/{video_id}", response_model=VideoResponse)
def admin_video_detail(video_id: int):
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute("SELECT * FROM videos WHERE id = %s", (video_id,))
                video = cursor.fetchone()
                if not video:
                    raise HTTPException(status_code=404, detail="Video not found")
                video["segments"] = _load_video_segments(cursor, video_id)
                return video
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


@app.get("/admin/segments/{segment_id}", response_model=VideoSegmentResponse)
def admin_segment_detail(segment_id: int):
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute("SELECT * FROM video_segments WHERE id = %s", (segment_id,))
                segment = cursor.fetchone()
                if not segment:
                    raise HTTPException(status_code=404, detail="Segment not found")
                return segment
    except HTTPException:
        raise
    except Exception as exc:
        raise HTTPException(status_code=500, detail=str(exc))


@app.get("/admin/segments/{segment_id}/download")
def download_segment(segment_id: int):
    try:
        with get_db_connection() as conn:
            with conn.cursor() as cursor:
                cursor.execute("SELECT file_path FROM video_segments WHERE id = %s", (segment_id,))
                row = cursor.fetchone()
                if not row:
                    raise HTTPException(status_code=404, detail="Segment not found")

                segment_path = row["file_path"]
                absolute_path = os.path.join(BASE_DIR, segment_path)
                if not os.path.exists(absolute_path):
                    raise HTTPException(status_code=404, detail="Segment file not found")

                return FileResponse(absolute_path, media_type="video/mp4", filename=os.path.basename(absolute_path))
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
