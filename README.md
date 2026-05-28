# Study Emotion Monitor

## 1. Introduction

**Study Emotion Monitor** là một **hệ thống giám sát cảm xúc học tập thông minh** giúp theo dõi hành vi học tập, trạng thái cảm xúc và mức độ tập trung của sinh viên trong quá trình học.

Dự án giải quyết các vấn đề sau:

- **Thiếu dữ liệu về hiệu quả học tập**: Cung cấp dữ liệu định lượng về focus level và emotional state
- **Khó theo dõi tiến độ học**: Admin có thể xem lịch sử chi tiết, timeline cảm xúc hàng ngày
- **Cần phân tích AI**: Sử dụng mô hình YOLO để phát hiện tự động trạng thái focus/unfocus
- **Quản lý đa nền tảng**: Hỗ trợ mobile (Android), web (Chrome), và desktop (Windows/Linux)

Hệ thống bao gồm: Frontend Flutter (mobile/web/desktop), Backend Python/FastAPI, Database MySQL, và AI Model YOLO cho phân tích cảm xúc.

---

## 📑 Table of Contents

1. [Introduction](#1-introduction)
2. [Features](#2-features)
3. [System Architecture - Chi tiết](#3-system-architecture---chi-tiết)
4. [Workflow](#4-workflow)
5. [Folder Structure - Chi tiết](#5-folder-structure---chi-tiết)
6. [Tech Stack & Problems & Solutions](#6-tech-stack)
7. [Setup - Chi tiết Quy trình](#7-setup---chi-tiết-quy-trình)
8. [Database Setup - Chi tiết](#8-database-setup---chi-tiết)
9. [API Documentation - Chi tiết](#9-api-documentation---chi-tiết)
10. [Installation](#10-installation)
11. [Running the System](#11-running-the-system)
12. [Troubleshooting - Chi tiết](#12-troubleshooting---chi-tiết)
13. [Limitations](#13-limitations)
14. [Future Improvements](#14-future-improvements)
15. [Development Workflow](#16-development-workflow)
16. [Contributors](#18-contributors)

---

## 2. Features

### Tính năng sinh viên:

- ✅ Đăng nhập/Đăng ký tài khoản sinh viên
- ✅ Chụp ảnh camera liên tục trong quá trình học
- ✅ Theo dõi mức độ tập trung (Focus Level: 0-1)
- ✅ Xem lịch sử cảm xúc hàng ngày (Daily Timeline)
- ✅ Xem thông báo và báo cáo cảm xúc cá nhân
- ✅ Quản lý hồ sơ cá nhân (Profile, Avatar)

### Tính năng Admin:

- ✅ Dashboard thống kê tổng hợp (số students, videos, emotions)
- ✅ Quản lý tài khoản sinh viên (CRUD)
- ✅ Quản lý lớp học và giảng viên
- ✅ Xem lịch sử cảm xúc của từng sinh viên (Timeline)
- ✅ Phân tích video từng học sinh (AI Analysis)
- ✅ Báo cáo thống kê hàng ngày (Daily Stats)
- ✅ Xem danh sách video và chi tiết phân tích

### Tính năng AI/Backend:

- ✅ Phân tích frame ảnh bằng YOLO (Emotion Detection)
- ✅ Tính điểm tập trung (Concentration Calculator)
- ✅ Xử lý video, tách frames (Video Processor)
- ✅ Lưu trữ ảnh snapshots và avatars
- ✅ API RESTful cho Frontend
- ✅ CORS hỗ trợ đa nền tảng

## 3. System Architecture - Chi tiết

```
┌─────────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER                              │
├─────────────────┬──────────────────┬──────────────────┬──────────┤
│   Mobile        │    Web (Chrome)  │   Desktop        │          │
│  (Android/iOS)  │   (Flutter Web)  │ (Windows/Linux)  │          │
│                 │                  │                  │          │
└────────────┬────┴────────┬─────────┴────────┬─────────┴──────────┘
             │             │                  │
             │   Flutter App (lib/)           │
             │   ├─ auth_screen.dart          │
             │   ├─ monitor_page.dart (Camera)
             │   ├─ admin/*_page.dart         │
             │   └─ api_service.dart (HTTP)   │
             │                                │
             └────────────┬─────────────────────┘
                          │ HTTP/REST API
                          │ (Multipart Form Data)
┌─────────────────────────┴─────────────────────────────────────┐
│                     API LAYER (FastAPI)                        │
│                   backend/main.py                              │
├─────────────────────────────────────────────────────────────┤
│  Routes:                                                     │
│  • POST /login ──→ User Authentication                      │
│  • POST /analyze-frame ──→ Frame Analysis (YOLO)            │
│  • GET /admin/dashboard ──→ Statistics                       │
│  • GET /admin/emotion-timeline ──→ Timeline Data            │
│  • GET /admin/videos ──→ Video Management                   │
└────────────┬─────────────────┬────────────────┬─────────────┘
             │                 │                │
       ┌─────▼────────┐  ┌─────▼────────┐  ┌───▼────────┐
       │ AI LAYER     │  │ DATA LAYER   │  │ STORAGE    │
       │              │  │              │  │            │
       │ YOLO Model   │  │ MySQL DB     │  │ uploads/   │
       │ best.pt      │  │ (SQL queries)│  │ frames/    │
       │              │  │              │  │ segments/  │
       │ Video        │  │ pymysql      │  │ avatars/   │
       │ Processor    │  │ connection   │  │            │
       │              │  │              │  │ PIL/       │
       │ Concentration│  │ Database:    │  │ OpenCV     │
       │ Calculator   │  │ emotion_system
       │              │  │              │  │            │
       └──────────────┘  └──────────────┘  └────────────┘
```

### Data Flow (Quy trình dữ liệu):

```
STUDENT SIDE:
1. User Login
   auth_screen.dart → POST /login → Backend validate → MySQL check
   ↓
2. Start Monitoring
   monitor_page.dart → Initialize Camera
   ↓
3. Capture Frame
   CameraController → Take Picture → Send to API
   ↓
4. Frame Analysis
   POST /analyze-frame (MultipartFile)
   → Backend receives frame
   → YOLO model inference (best.pt)
   → Predict emotion_label, focus_level, confidence
   → Save to MySQL (frame_emotions table)
   → Save image to uploads/frames/
   ↓
5. Display Result
   API response → Update UI
   → user_emotion_timeline_page.dart shows results
   ↓
6. View History
   GET /admin/emotion-timeline
   → Timeline chart with emotions
   → Click snapshot → GET /frame-emotion/{id}/image

ADMIN SIDE:
1. Admin Login
   admin_dashboard_page.dart → POST /login (role=admin)
   ↓
2. View Dashboard
   GET /admin/dashboard
   → Total students, videos, emotions metrics
   ↓
3. Monitor Students
   admin_student_accounts_page.dart
   → GET /admin/students
   → Click student → GET /admin/emotion-timeline?user_id=X
   ↓
4. Video Analysis
   admin_video_list_page.dart
   → GET /admin/videos
   → Click video → admin_video_detail_page.dart
   → GET /admin/videos/{video_id}
   → Show all frames + analysis results
   ↓
5. Generate Reports
   admin_monitor_reports_page.dart
   → Backend generates monitor_reports.json
   → Includes emotion distribution, focus stats, etc.
```

## 4. Workflow

### Quy trình chính (Student Side):

1. **Đăng nhập** → User nhập email/password trên `auth_screen.dart`
2. **Camera Start** → App yêu cầu quyền camera, khởi tạo từ `main.dart`
3. **Capture Frames** → Camera chụp ảnh định kỳ trong `monitor_page.dart`
4. **Send to Backend** → POST request frame + metadata tới `/analyze-frame`
5. **Emotion Analysis** → Backend sử dụng YOLO model từ `best.pt`
6. **Save Result** → Lưu emotion, focus_level, confidence vào MySQL
7. **Display Timeline** → Hiển thị kết quả trên `user_emotion_timeline_page.dart`
8. **Get Notifications** → Hiển thị thông báo trên `notification_page.dart`

### Quy trình Admin (Admin Side):

1. **Admin Login** → Đăng nhập admin account
2. **View Dashboard** → Xem tổng quát tất cả students, videos, emotions
3. **Monitor Students** → Xem danh sách sinh viên, lịch sử cảm xúc từng người
4. **Video Analysis** → Xem video chi tiết, AI analysis từng frame
5. **Generate Reports** → Xuất báo cáo thống kê hàng ngày (`monitor_reports.json`)
6. **Manage Data** → Quản lý user, classes, subjects

### Quy trình Backend (API):

```
Frame Input → YOLO Model → Emotion Detection → MySQL Save → JSON Response
```

## 5. Folder Structure - Chi tiết

```
Code-adr/
│
├── 📱 FLUTTER FRONTEND (lib/)
│   ├── main.dart                      # Khởi tạo app, camera initialization
│   │
│   ├── constants/
│   │   └── app_state.dart            # Global state (themeNotifier, isLoggedInNotifier)
│   │
│   ├── core/
│   │   └── slide_page_route.dart      # Custom page transition animation
│   │
│   ├── models/                        # Data models (Dart objects)
│   │   ├── admin_video.dart           # Model cho video (admin view)
│   │   ├── class_model.dart           # Model cho lớp học
│   │   ├── lecturer.dart              # Model giảng viên
│   │   ├── post.dart                  # Model bài đăng
│   │   ├── student.dart               # Model sinh viên
│   │   ├── subject.dart               # Model môn học
│   │   └── video_sync_item.dart       # Model sync video
│   │
│   ├── data/                          # Data layer (API, Database, Repositories)
│   │   ├── remote/
│   │   │   ├── api_service.dart       # API client (HTTP calls to backend)
│   │   │   ├── api_test_page.dart     # Test page để kiểm tra API
│   │   │   ├── emotion_system.sql     # SQL schema cho database
│   │   │   └── settings_page.dart     # Cài đặt ứng dụng
│   │   ├── local/                     # Local storage (SharedPreferences, SQLite)
│   │   │   └── (Local database files)
│   │   └── repositories/              # Business logic layer
│   │       └── (Repository pattern implementation)
│   │
│   └── features/                      # UI Features / Pages
│       ├── home/                      # Home/Student features
│       │   ├── auth_screen.dart       # Login/Register screen
│       │   ├── monitor_page.dart      # Main monitoring page (camera capture)
│       │   ├── user_emotion_timeline_page.dart  # Student emotion history
│       │   ├── notification_page.dart # Notifications
│       │   ├── history_page.dart      # Study history
│       │   ├── button1.dart           # Custom buttons
│       │   └── value_listenable_builder_2.dart  # State management widget
│       │
│       ├── admin/                     # Admin Dashboard
│       │   ├── admin_dashboard_page.dart              # Main dashboard
│       │   ├── admin_emotion_timeline_page.dart       # Emotion timeline (admin)
│       │   ├── admin_latest_ai_analysis_page.dart     # Latest AI analysis results
│       │   ├── admin_monitor_reports_page.dart        # Reports page
│       │   ├── admin_student_accounts_page.dart       # Student account management
│       │   ├── admin_user_daily_stats_page.dart       # Daily statistics
│       │   ├── admin_video_detail_page.dart           # Video detail view
│       │   ├── admin_video_list_page.dart             # List all videos
│       │   ├── class_management_page.dart             # Manage classes
│       │   └── student_management_page.dart           # Manage students
│       │
│       ├── profile/                  # Profile Management
│       │   └── profile_page.dart      # User profile page
│       │
│       └── study/                    # Study-related features
│           └── (Study tracking screens)
│
├── 🐍 PYTHON BACKEND (backend/)
│   ├── main.py                        # FastAPI server & main API routes
│   │                                  # Routes: /login, /analyze-frame, /admin/*, etc.
│   │
│   ├── concentration_calculator.py    # Tính điểm tập trung từ frame
│   │
│   ├── video_processor.py             # Xử lý video, tách frames
│   │
│   ├── requirements.txt               # Python dependencies
│   │                                  # - fastapi, uvicorn, torch, ultralytics
│   │                                  # - opencv, pillow, pymysql, numpy
│   │
│   ├── monitor_reports.json           # Generated reports (JSON output)
│   │
│   ├── AI/
│   │   ├── best.pt                    # YOLO model (Emotion detection)
│   │   └── (Model related files)
│   │
│   ├── uploads/                       # Image storage
│   │   ├── frames/                    # Captured frames from monitoring
│   │   ├── segments/                  # Video segments
│   │   └── avatars/                   # User avatar images
│   │
│   └── venv/                          # Python virtual environment
│       └── (Python packages)
│
├── 🤖 NATIVE BUILD CONFIGS
│   ├── android/                       # Android native configuration
│   │   ├── app/                       # Android app module
│   │   │   ├── build.gradle.kts       # Gradle build config
│   │   │   └── src/
│   │   │       ├── main/              # Android main source
│   │   │       ├── androidTest/       # Android tests
│   │   │       └── test/              # Unit tests
│   │   ├── gradle/wrapper/            # Gradle wrapper
│   │   └── build.gradle.kts           # Root gradle config
│   │
│   ├── ios/                           # iOS native configuration
│   │   └── (iOS specific files)
│   │
│   ├── linux/                         # Linux desktop configuration
│   │   ├── CMakeLists.txt             # Build config
│   │   ├── flutter/                   # Flutter plugin registry
│   │   └── runner/                    # Linux app runner
│   │
│   ├── windows/                       # Windows desktop configuration
│   │   ├── CMakeLists.txt             # Build config
│   │   ├── flutter/                   # Flutter plugin registry
│   │   └── runner/                    # Windows app runner
│   │
│   └── web/                           # Web build configuration
│       ├── index.html                 # Web entry point
│       ├── manifest.json              # PWA manifest
│       ├── icons/                     # Web icons
│       └── (Web assets)
│
├── 🧪 TEST & CONFIG
│   ├── test/                          # Flutter widget & unit tests
│   │   └── (Test files)
│   │
│   ├── pubspec.yaml                   # Flutter project config
│   │                                  # Dependencies: flutter, camera, http, dio, etc.
│   │
│   ├── analysis_options.yaml          # Dart linter options
│   │
│   ├── build.gradle.kts               # Gradle build config (root)
│   ├── settings.gradle.kts            # Gradle settings
│   ├── gradle.properties              # Gradle properties
│   ├── gradlew / gradlew.bat          # Gradle wrapper scripts
│   ├── local.properties               # Local build properties
│   │
│   └── build/                         # Generated build output
│       ├── flutter_assets/            # Flutter compiled assets
│       └── native_assets/             # Native compiled assets
│
├── 📚 DOCUMENTATION
│   ├── README.md                      # Main documentation (this file)
│   ├── BACKEND_DB_FIX_REPORT.md       # Backend database fix notes
│   ├── IMAGE_STORAGE_README.md        # Image storage guide
│   ├── class-diagram.md               # Class relationships diagram
│   ├── model-AI.drawio                # AI model diagram
│   └── model-AI-fixed.drawio          # Fixed AI model diagram
│
└── 📦 PROJECT ROOT
    ├── .venv/                         # Python venv (main project level)
    └── (Project configuration files)
```

### 📋 File Purpose Summary:

| File/Folder                           | Mục đích          | Công nghệ     |
| ------------------------------------- | ----------------- | ------------- |
| `lib/main.dart`                       | App entry point   | Flutter       |
| `lib/features/home/monitor_page.dart` | Camera monitoring | Camera plugin |
| `lib/features/admin/*`                | Admin dashboard   | Flutter UI    |
| `backend/main.py`                     | API server        | FastAPI       |
| `backend/AI/best.pt`                  | Emotion detection | YOLO v8       |
| `backend/video_processor.py`          | Video processing  | OpenCV        |
| `data/remote/api_service.dart`        | API client        | HTTP/Dio      |
| `pubspec.yaml`                        | Dependencies      | Flutter       |
| `requirements.txt`                    | Python deps       | pip           |

## 6. Tech Stack

- Flutter / Dart
- Python 3.10+
- FastAPI
- MySQL / MariaDB
- Uvicorn
- PIL / ultralytics / torch
- Flutter Camera plugin

## 6.5. Problems & Solutions (Vấn đề & Giải pháp)

### 🎯 Vấn đề 1: Không theo dõi được hiệu quả học tập

**Giải pháp**: Sử dụng AI model YOLO để phát hiện tự động trạng thái focus/unfocus từ camera

- `backend/AI/best.pt` được train để phân loại emotion/focus
- `backend/concentration_calculator.py` tính focus score
- Dữ liệu lưu vào MySQL để tracking

### 🎯 Vấn đề 2: Khó quản lý dữ liệu cảm xúc hàng loạt

**Giải pháp**: Admin Dashboard với các tính năng

- `admin_dashboard_page.dart` - Tổng quan thống kê
- `admin_emotion_timeline_page.dart` - Xem lịch sử chi tiết
- `admin_monitor_reports_page.dart` - Xuất báo cáo (`monitor_reports.json`)
- `admin_user_daily_stats_page.dart` - Thống kê hàng ngày

### 🎯 Vấn đề 3: Xử lý video từ nhiều sinh viên

**Giải pháp**:

- `video_processor.py` - Xử lý video, tách frames hiệu quả
- `backend/uploads/frames/` - Lưu frames theo user ID
- `backend/uploads/segments/` - Segment video theo thời gian

### 🎯 Vấn đề 4: Hỗ trợ đa nền tảng

**Giải pháp**: Flutter framework

- Android (`android/`) - Mobile
- iOS (`ios/`) - Mobile
- Web (`web/`) - Browser
- Windows/Linux (`windows/`, `linux/`) - Desktop

### 🎯 Vấn đề 5: API phải hỗ trợ gửi ảnh lớn + JSON

**Giải pháp**: FastAPI + multipart

- `backend/main.py` sử dụng `UploadFile` + `Form`
- CORS middleware hỗ trợ tất cả origins
- `api_service.dart` sử dụng Dio cho multipart requests

## 7. Setup - Chi tiết Quy trình

The project is designed to run with two separate terminals: one for the backend API and one for the frontend app. This keeps the services isolated and makes development easier.

### Terminal 1 — Backend (Python/FastAPI)

1. Open a terminal in `d:\Code-adr\backend`.
2. Create and activate a virtual environment:

```powershell
cd d:\Code-adr\backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
```

3. Install Python dependencies:

```powershell
pip install -r requirements.txt
```

**Dependencies:**

- `fastapi` - Web framework
- `uvicorn` - ASGI server
- `torch`, `torchvision` - Deep learning
- `ultralytics` - YOLO v8
- `opencv-python` - Video/Image processing
- `pillow` - Image manipulation
- `pymysql` - MySQL connector
- `python-multipart` - File upload support

4. Start the backend server:

```powershell
python main.py
```

> The backend should now run at `http://127.0.0.1:8000`.
> API Docs: `http://127.0.0.1:8000/docs`

**Backend Startup Process:**

- Load YOLO model từ `backend/AI/best.pt`
- Kết nối MySQL database
- Tạo upload directories: `uploads/frames/`, `uploads/segments/`, `uploads/avatars/`
- Khởi tạo routes: `/login`, `/analyze-frame`, `/admin/*`, `/frame-emotion/*`
- Enable CORS cho tất cả origins

### Terminal 2 — Frontend (Flutter/Dart)

1. Open a second terminal in the project root `d:\Code-adr`.
2. Install Flutter dependencies:

```powershell
cd d:\Code-adr
flutter pub get
```

**Key Dependencies:**

- `camera: ^0.12.0` - Camera access
- `http`, `dio` - API client
- `shared_preferences` - Local storage
- `sqflite` - Local database
- `video_player` - Video playback
- `workmanager` - Background tasks
- `ffmpeg_kit_flutter` - Video processing

3. Run the Flutter app:

```powershell
flutter run
```

4. To run on Chrome instead of a device/emulator:

```powershell
flutter run -d chrome
```

**Frontend Startup Process:**

- Khởi tạo camera permissions
- Check login status từ SharedPreferences
- Nếu chưa login → `AuthScreen` (đăng nhập)
- Nếu đã login → `HomePage` (monitoring)
- Thiết lập listeners cho app lifecycle
- Connect tới backend API (`http://127.0.0.1:8000`)

### Why two terminals?

- One terminal stays dedicated to the backend service.
- One terminal stays dedicated to the Flutter frontend.
- This makes it easy to see logs and restart one side without stopping the other.
- Backend logs show API calls, model loading, database operations.
- Frontend logs show UI events, camera frames, API responses.

## 8. Database Setup - Chi tiết

1. Create a MySQL or MariaDB database named `emotion_system`.

```sql
CREATE DATABASE IF NOT EXISTS emotion_system;
USE emotion_system;
```

2. Create the required tables (schema mẫu trong `lib/data/remote/emotion_system.sql`):

```sql
-- Users table
CREATE TABLE users (
  user_id INT PRIMARY KEY AUTO_INCREMENT,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255),
  full_name VARCHAR(255),
  role ENUM('student', 'admin', 'lecturer') DEFAULT 'student',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Emotions/Frame analysis results
CREATE TABLE frame_emotions (
  emotion_id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT,
  emotion_label VARCHAR(50),        -- 'focus', 'neutral', etc.
  focus_level FLOAT,                -- 0-1 score
  confidence FLOAT,                 -- AI model confidence
  frame_image_path VARCHAR(500),    -- uploads/frames/...
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Videos table
CREATE TABLE videos (
  video_id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT,
  video_path VARCHAR(500),
  duration_seconds INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Classes
CREATE TABLE classes (
  class_id INT PRIMARY KEY AUTO_INCREMENT,
  class_name VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Subjects/Courses
CREATE TABLE subjects (
  subject_id INT PRIMARY KEY AUTO_INCREMENT,
  subject_name VARCHAR(255),
  class_id INT,
  FOREIGN KEY (class_id) REFERENCES classes(class_id)
);
```

3. Configure backend database connection via environment variables or in `backend/main.py`:

```python
MYSQL_HOST = os.getenv("MYSQL_HOST", "127.0.0.1")
MYSQL_PORT = int(os.getenv("MYSQL_PORT", "3306"))
MYSQL_USER = os.getenv("MYSQL_USER", "root")
MYSQL_PASSWORD = os.getenv("MYSQL_PASSWORD", "")
MYSQL_DB = os.getenv("MYSQL_DB", "emotion_system")
```

### Recommended Tables Structure:

| Table            | Purpose                                |
| ---------------- | -------------------------------------- |
| `users`          | Student/Admin/Lecturer accounts        |
| `frame_emotions` | Emotion analysis results (YOLO output) |
| `videos`         | Video metadata                         |
| `video_segments` | Split video segments                   |
| `study_sessions` | Study session records                  |
| `notifications`  | Notifications for students             |
| `emotions`       | Emotion reference data                 |
| `classes`        | Class/Group information                |
| `subjects`       | Subject/Course information             |

### Environment Variables

```powershell
# Windows PowerShell
$env:MYSQL_HOST="127.0.0.1"
$env:MYSQL_PORT="3306"
$env:MYSQL_USER="root"
$env:MYSQL_PASSWORD=""
$env:MYSQL_DB="emotion_system"

# Then run:
python main.py
```

## 9. API Documentation - Chi tiết

Tất cả API routes được định nghĩa trong `backend/main.py`

### Authentication Endpoints

```
POST /login
  - Req: { email, password }
  - Res: { user_id, role, token }
  - Purpose: User login
```

### Student Frame Analysis Endpoints

```
POST /analyze-frame
  - Req: FormData { frame (image), user_id, timestamp }
  - Res: { focus_level, label, confidence, emotion_id }
  - Purpose: Analyze single frame using YOLO
  - Storage: Saves to uploads/frames/

GET /frame-emotion/{id}/image
  - Res: FileResponse (image file)
  - Purpose: Retrieve saved frame image
```

### Admin Dashboard Endpoints

```
GET /admin/dashboard
  - Res: { total_students, total_videos, total_emotions, ... }
  - Purpose: Dashboard summary statistics
  - Used by: admin_dashboard_page.dart

GET /admin/emotion-timeline?user_id={id}&date={date}
  - Res: [ { emotion_label, focus_level, timestamp }, ... ]
  - Purpose: Get emotion timeline for specific student
  - Used by: admin_emotion_timeline_page.dart

GET /admin/videos
  - Res: [ { video_id, user_id, duration, created_at }, ... ]
  - Purpose: List all videos
  - Used by: admin_video_list_page.dart

GET /admin/videos/{video_id}
  - Res: Video detail with analysis results
  - Purpose: Get specific video details
  - Used by: admin_video_detail_page.dart

GET /admin/user-stats?date={date}
  - Res: [ { user_id, avg_focus, emotion_distribution }, ... ]
  - Purpose: Daily user statistics
  - Used by: admin_user_daily_stats_page.dart

GET /admin/students
  - Res: [ { user_id, email, full_name, class_id }, ... ]
  - Purpose: List all students for management
  - Used by: admin_student_accounts_page.dart
```

### Video Processing Endpoints

```
POST /upload-video
  - Req: FormData { video_file, user_id }
  - Res: { video_id, segments_count }
  - Purpose: Upload video for processing
  - Backend: video_processor.py processes video
```

### Endpoints Usage in Frontend

| Endpoint                    | Frontend File                      | Feature            |
| --------------------------- | ---------------------------------- | ------------------ |
| `/login`                    | `auth_screen.dart`                 | Login              |
| `/analyze-frame`            | `monitor_page.dart`                | Send camera frames |
| `/frame-emotion/{id}/image` | `user_emotion_timeline_page.dart`  | Show snapshots     |
| `/admin/dashboard`          | `admin_dashboard_page.dart`        | Admin overview     |
| `/admin/emotion-timeline`   | `admin_emotion_timeline_page.dart` | Emotion history    |
| `/admin/videos`             | `admin_video_list_page.dart`       | Video list         |
| `/admin/students`           | `admin_student_accounts_page.dart` | Student management |

### Error Handling

```
HTTP 401: Unauthorized (invalid token/login)
HTTP 500: Model not loaded (YOLO model issue)
HTTP 400: Bad request (missing fields)
HTTP 200: Success with JSON response
```

### Testing Endpoints

- **Swagger/OpenAPI**: `http://127.0.0.1:8000/docs`
- **ReDoc**: `http://127.0.0.1:8000/redoc`
- Test page: `lib/data/remote/api_test_page.dart`

## 10. Installation

### Backend installation

```powershell
cd backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

### Frontend installation

```powershell
cd d:\Code-adr
flutter pub get
```

## 11. Running the System

### Start backend

```powershell
cd backend
python main.py
```

### Start frontend

```powershell
flutter run
```

### Run on web

```powershell
flutter run -d chrome
```

## 12. Troubleshooting - Chi tiết

| Problem                          | Solution                                                                                          |
| -------------------------------- | ------------------------------------------------------------------------------------------------- |
| **Backend không start**          | Check Python path, verify `python --version`                                                      |
|                                  | Kiểm tra port 8000 đã được dùng: `netstat -ano \| findstr :8000`                                  |
|                                  | Xóa virtual env và tạo lại: `rmdir .venv`                                                         |
| **Model không load**             | Verify `backend/AI/best.pt` tồn tại                                                               |
|                                  | Check YOLO version: `pip show ultralytics`                                                        |
|                                  | Ensure torch được cài: `pip install torch torchvision`                                            |
| **Database connection error**    | Verify MySQL running: `Get-Service MySQL*`                                                        |
|                                  | Check credentials: `mysql -u root -h 127.0.0.1`                                                   |
|                                  | Verify database exists: `mysql -e "SHOW DATABASES;"`                                              |
| **Camera access fails**          | Grant permissions in OS settings                                                                  |
|                                  | For Android: Check `android/app/AndroidManifest.xml`                                              |
|                                  | For web: Use HTTPS (camera requires secure context)                                               |
| **API 500 error**                | Check backend logs for stack trace                                                                |
|                                  | Verify API endpoint exists in `backend/main.py`                                                   |
|                                  | Test endpoint: `http://127.0.0.1:8000/docs`                                                       |
| **Frame analysis slow**          | Model inference takes time (2-5 sec/frame)                                                        |
|                                  | Consider GPU acceleration: `pip install torch --index-url https://download.pytorch.org/whl/cu118` |
| **CORS error**                   | Check CORS middleware in `backend/main.py`                                                        |
|                                  | Verify `allow_origins=["*"]` is set                                                               |
| **Frontend can't reach backend** | Check backend is running at `127.0.0.1:8000`                                                      |
|                                  | Verify API URL in `api_service.dart`                                                              |
|                                  | For real device: Use actual IP instead of localhost                                               |
| **Dependencies install fails**   | Upgrade pip: `python -m pip install --upgrade pip`                                                |
|                                  | Clear cache: `pip cache purge`                                                                    |
|                                  | Try specific version: `pip install torch==2.0.0`                                                  |

### Common Log Files

- **Backend**: Terminal output (FastAPI logs)
- **Frontend**: `flutter run` terminal output
- **Database**: MySQL error log (check MySQL installation path)
- **Reports**: `backend/monitor_reports.json` (generated reports)

### Debug Tips

1. **Backend Debug**: Add print statements in `backend/main.py`
2. **Frontend Debug**: Use `debugPrint()` in Dart code
3. **API Test**: Use Postman or `http` command:
   ```powershell
   # Test login
   Invoke-RestMethod -Uri "http://127.0.0.1:8000/login" `
     -Method POST `
     -ContentType "application/json" `
     -Body '{"email":"test@example.com","password":"pass"}'
   ```
4. **Database Debug**: Use MySQL Workbench or command line:
   ```sql
   SELECT * FROM frame_emotions ORDER BY created_at DESC LIMIT 10;
   ```

## 13. Limitations

- Emotion detection depends on the accuracy of the provided AI model.
- The project may require additional optimization for production use.
- Database schema and migrations are not fully packaged in this repository.
- Camera permission handling may differ by platform.

## 14. Future Improvements

- Add full database migration scripts.
- Improve emotion classification accuracy.
- Add user session analytics and alerts.
- Expand admin dashboard reports and charts.
- Support offline caching and retry logic.

## 16. Development Workflow

### Local Development Setup

```powershell
# 1. Clone and open project
git clone <repo>
cd d:\Code-adr

# 2. Setup main venv (if needed)
python -m venv .venv
.\.venv\Scripts\Activate.ps1

# 3. Terminal 1 - Backend
cd backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
python main.py
# Backend runs at http://127.0.0.1:8000

# 4. Terminal 2 - Frontend (from project root)
flutter pub get
flutter run -d chrome
# Or: flutter run (for connected device)
```

### Development Files Reference

| Task               | File                                  | Location |
| ------------------ | ------------------------------------- | -------- |
| Add new API route  | `backend/main.py`                     | Backend  |
| Add new UI page    | `lib/features/{feature}/`             | Frontend |
| Add data model     | `lib/models/`                         | Frontend |
| Add API service    | `lib/data/remote/api_service.dart`    | Frontend |
| Configure database | `lib/data/remote/emotion_system.sql`  | SQL      |
| Test API           | `lib/data/remote/api_test_page.dart`  | Frontend |
| Modify AI logic    | `backend/concentration_calculator.py` | Backend  |
| Video processing   | `backend/video_processor.py`          | Backend  |

### Recommended Git Workflow

```bash
git checkout -b feature/your-feature
# Make changes
git add .
git commit -m "feat: description"
git push origin feature/your-feature
# Create Pull Request
```

## 17. Performance Optimization Tips

### Backend Optimization

- **Model Caching**: Model loads once at startup
- **Batch Processing**: Process multiple frames together
- **GPU Acceleration**: Use CUDA for torch if available
- **Database Indexing**: Add indexes on frequently queried columns

### Frontend Optimization

- **Lazy Loading**: Load admin pages on demand
- **Image Compression**: Compress frames before upload
- **Local Caching**: Cache API responses
- **Background Tasks**: Use workmanager for periodic uploads

### Database Optimization

- Partition large tables by date
- Regular backups
- Monitor query performance
- Archive old emotion records

## 18. Contributors

- Original project author
- Flutter frontend developers
- Python backend developers
- AI model integration team

---

For more help with Flutter development, visit the [Flutter documentation](https://docs.flutter.dev/).
For FastAPI docs, visit [FastAPI documentation](https://fastapi.tiangolo.com/).
For YOLO model info, visit [Ultralytics YOLO](https://docs.ultralytics.com/).
