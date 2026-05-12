# Study Emotion Monitor

## Giới thiệu

Study Emotion Monitor là một hệ thống học tập thông minh gồm:

- Ứng dụng Flutter để giám sát thái độ, trạng thái cảm xúc và mức độ tập trung khi học.
- Backend Python/FastAPI để xử lý ảnh, nhận diện cảm xúc và lưu trữ kết quả vào MySQL.
- Dashboard admin để xem lịch sử cảm xúc, ảnh snapshot và thống kê học tập.

Mục tiêu dự án:

- Giúp học sinh theo dõi trạng thái tập trung và cảm xúc khi học.
- Cung cấp dữ liệu lịch sử, timeline và cảnh báo qua ảnh chụp định kỳ.
- Hỗ trợ quản trị viên quản lý video, người dùng và dữ liệu AI.

## Công nghệ sử dụng

- Flutter / Dart: giao diện mobile/web/desktop
- Python 3.x: backend API
- FastAPI: framework HTTP cho backend
- MySQL / MariaDB: cơ sở dữ liệu
- Camera plugin Flutter: chụp ảnh/videostream
- PIL / ultralytics / torch: xử lý ảnh và model nhận diện
- Uvicorn: server backend

## Cấu trúc thư mục chính

```
├── android/                    # cấu hình Android
├── app/                        # module Android gốc
├── backend/                    # backend FastAPI và xử lý AI
│   ├── main.py                 # điểm vào backend
│   ├── concentration_calculator.py
│   ├── video_processor.py
│   ├── requirements.txt
│   └── AI/                     # model và dữ liệu liên quan
├── lib/                        # mã nguồn Flutter
│   ├── features/               # giao diện và chức năng chính
│   ├── data/remote/             # dịch vụ API và cấu hình remote
│   ├── models/                 # model dữ liệu Flutter
│   └── main.dart
├── linux/                      # cấu hình Linux desktop
├── test/                       # test Flutter
├── web/                        # cấu hình web
├── windows/                    # cấu hình Windows desktop
└── pubspec.yaml                # cấu hình Flutter
```

## Yêu cầu môi trường

### Backend

- Python 3.10+ hoặc 3.11+
- MySQL/MariaDB
- Các package Python trong `backend/requirements.txt`

### Frontend

- Flutter 3.x hoặc mới hơn
- Dart SDK tương thích
- Thiết bị hoặc trình duyệt hỗ trợ Flutter

## Database setup

1. Tạo database MySQL/MariaDB với tên `emotion_system`.
2. Thực thi file SQL schema nếu có hoặc tạo cấu trúc bảng sau:
   - `users`
   - `frame_emotions`
   - `videos`
   - `video_segments`
   - `study_sessions`
   - `notifications`
   - `emotions`
3. Cấu hình kết nối MySQL trong backend bằng biến môi trường hoặc trực tiếp trong `backend/main.py`:
   - `MYSQL_HOST`
   - `MYSQL_PORT`
   - `MYSQL_USER`
   - `MYSQL_PASSWORD`
   - `MYSQL_DB`

## File cấu hình

- `pubspec.yaml`: cấu hình Flutter, dependencies frontend.
- `backend/requirements.txt`: dependencies Python backend.
- `backend/main.py`: cấu hình API, kết nối DB, routes.
- `backend/AI/best.pt`: model nhận diện ảnh.
- `local.properties`, `gradle.properties`: cấu hình Android/Gradle.

## Workflow Git

- Tạo branch mới cho mỗi tính năng hoặc sửa lỗi: `git checkout -b feature/<tên>` hoặc `git checkout -b fix/<tên>`.
- Commit nhỏ, rõ ràng.
- Merge về branch chính sau khi review và test.
- Sử dụng `git push origin <branch>` để đẩy lên remote.

## Tính năng hiện có

- Quản lý người dùng student/admin
- Chụp ảnh định kỳ từ camera để phân tích cảm xúc
- Ghi lại lịch sử cảm xúc và ảnh snapshot
- Hiển thị timeline cảm xúc theo ngày
- Bảng điều khiển admin xem thống kê, video và lịch sử
- Lưu trữ và tải ảnh frame qua endpoint `/frame-emotion/{id}/image`
- API backend gồm: login, analyze-frame, admin/emotion-timeline, admin/dashboard, admin/videos

## Cách cài đặt

### Backend

```powershell
cd backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

### Frontend

```powershell
cd d:\Code-adr
flutter pub get
```

## Cách chạy hệ thống

### Chạy backend

```powershell
cd backend
.\.venv\Scripts\Activate.ps1
python main.py
```

### Chạy frontend

```powershell
cd d:\Code-adr
flutter run
```

Hoặc chạy web:

```powershell
flutter run -d chrome
```

## Lưu ý

- Đảm bảo backend đang chạy trước khi frontend khởi động.
- Cấu hình đúng MySQL và tạo dữ liệu mẫu nếu cần.
- Nếu sử dụng camera, cấp quyền truy cập cho ứng dụng.

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
