# Study Emotion Monitor

## 1. Introduction

Study Emotion Monitor is an intelligent learning monitoring system that tracks study behavior, emotional state, and focus level. It includes a Flutter frontend, a Python/FastAPI backend, and an admin dashboard for reviewing emotion history, snapshots, and analytics.

## 2. Features

- Student and admin account management
- Periodic camera snapshot capture and emotion analysis
- Emotion history tracking with snapshots
- Daily emotion timeline visualization
- Admin dashboard for user, video, and emotion statistics
- API endpoints for login, frame analysis, and admin reporting
- Image storage and retrieval for detected frames

## 3. System Architecture

The system consists of:

- **Flutter frontend**: mobile/web/desktop UI built with Flutter and Dart.
- **Backend API**: Python FastAPI service for image processing, emotion detection, and database persistence.
- **AI model**: image-based emotion recognition model stored in `backend/AI/best.pt`.
- **Database**: MySQL/MariaDB for storing users, video metadata, and emotion events.

## 4. Workflow

1. User logs in through the frontend.
2. The frontend captures camera frames periodically.
3. Frames are sent to the backend for emotion analysis.
4. Backend processes each frame and saves the result in the database.
5. Admin dashboard queries emotion history and displays analytics.

## 5. Folder Structure

```
├── android/                    # Android native configuration
├── app/                        # Android module and native app files
├── backend/                    # FastAPI backend and AI processing code
│   ├── main.py                 # Backend entry point and API routes
│   ├── concentration_calculator.py
│   ├── video_processor.py
│   ├── requirements.txt        # Python dependencies
│   └── AI/                     # AI model and related files
├── fontend/                    # Flutter application source code
│   ├── constants/
│   ├── core/
│   ├── data/
│   │   ├── local/
│   │   └── remote/
│   ├── features/
│   ├── models/
│   └── main.dart
├── linux/                      # Linux desktop build configuration
├── test/                       # Flutter widget and unit tests
├── web/                        # Web build configuration and assets
├── windows/                    # Windows desktop build configuration
└── pubspec.yaml                # Flutter project configuration
```

## 6. Tech Stack

- Flutter / Dart
- Python 3.10+
- FastAPI
- MySQL / MariaDB
- Uvicorn
- PIL / ultralytics / torch
- Flutter Camera plugin

## 7. Environment Setup

### Backend

1. Open a terminal in `backend/`.
2. Create and activate a virtual environment:

```powershell
cd backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
```

3. Install Python dependencies:

```powershell
pip install -r requirements.txt
```

### Frontend

1. Ensure Flutter SDK is installed and configured.
2. Install Flutter dependencies:

```powershell
cd d:\Code-adr
flutter pub get
```

## 8. Database Setup

1. Create a MySQL or MariaDB database named `emotion_system`.
2. Create the required tables if no SQL schema file exists.
3. Configure backend database connection settings using environment variables or directly in `backend/main.py`.

### Recommended tables

- `users`
- `frame_emotions`
- `videos`
- `video_segments`
- `study_sessions`
- `notifications`
- `emotions`

### Environment variables

- `MYSQL_HOST`
- `MYSQL_PORT`
- `MYSQL_USER`
- `MYSQL_PASSWORD`
- `MYSQL_DB`

## 9. API Documentation

### Common endpoints

- `POST /login` - authenticate users
- `POST /analyze-frame` - upload a frame for emotion analysis
- `GET /admin/emotion-timeline` - retrieve emotion timeline data
- `GET /admin/dashboard` - retrieve dashboard statistics
- `GET /admin/videos` - list stored videos and metadata
- `GET /frame-emotion/{id}/image` - fetch saved snapshot images

> Note: Exact routes may vary in `backend/main.py`.

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

## 12. Troubleshooting

- Ensure the backend is running before starting the frontend.
- Verify the database connection settings and credentials.
- If camera access fails, confirm permissions are granted.
- If dependencies fail to install, check Python and Flutter SDK versions.
- Review backend logs for FastAPI and model loading errors.

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

## 15. Contributors

- Original project author
- Flutter frontend developers
- Python backend developers
- AI model integration team

---

For more help with Flutter development, visit the [Flutter documentation](https://docs.flutter.dev/).
