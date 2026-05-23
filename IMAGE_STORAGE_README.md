# Hệ Thống Lưu Trữ Ảnh Người Dùng

## Cấu Trúc Thư Mục

```
backend/uploads/
├── avatars/                    # Thư mục lưu trữ avatar của người dùng
│   ├── 1/                     # User ID 1
│   │   └── avatar.jpg         # Ảnh avatar của user 1
│   ├── 2/                     # User ID 2
│   │   └── avatar.png         # Ảnh avatar của user 2
│   └── ...
├── frames/                    # Thư mục lưu trữ các frame từ video
├── segments/                  # Thư mục lưu trữ các đoạn video
└── <user_id>/               # Thư mục người dùng (dữ liệu khuôn mặt)
    └── <YYYY-MM-DD>/
        └── images/           # Ảnh được phân tích
```

## Định Dạng Ảnh Được Hỗ Trợ

### Avatar (Ảnh Đại Diện)

- **JPG/JPEG** (.jpg, .jpeg)
- **PNG** (.png)
- **GIF** (.gif)
- **WebP** (.webp)
- **BMP** (.bmp)

### Giới Hạn Kích Thước

- **Tối đa**: 10 MB cho mỗi ảnh

## Tính Năng

### 1. Upload Avatar

- **Endpoint**: `POST /users/{user_id}/avatar`
- **Tham số**:
  - `avatar` (file): Tệp ảnh
- **Hỗ trợ**: Tất cả định dạng ảnh trên
- **Xác thực**:
  - Kiểm tra Content-Type
  - Kiểm tra phần mở rộng tệp
  - Kiểm tra kích thước (max 10MB)
  - Xác thực nội dung ảnh

### 2. Lấy Avatar

- **Endpoint**: `GET /admin/users/{user_id}/avatar`
- **Trả về**: Tệp ảnh với Content-Type phù hợp

### 3. Xóa Avatar Cũ

- Khi upload avatar mới, avatar cũ sẽ bị xóa tự động
- Mỗi user chỉ lưu một avatar

## Sử Dụng trong Flutter

### Chọn Ảnh

```dart
final result = await FilePicker.pickFiles(
  type: FileType.custom,
  allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'],
  withData: true,
);
```

### Upload Avatar

```dart
final uploadedUrl = await ApiService.uploadUserAvatar(
  userId: currentUser.id,
  bytes: selectedFile.bytes,
  filename: selectedFile.name,
  path: selectedFile.path,
);
```

## Xác Thực Tệp

### Client-side (Flutter)

1. Kiểm tra phần mở rộng tệp
2. Xác thực kích thước tệp (10MB)
3. Hiển thị preview ảnh

### Server-side (Python/FastAPI)

1. Kiểm tra Content-Type
2. Kiểm tra phần mở rộng tệp
3. Kiểm tra kích thước tệp
4. Xác thực tệp ảnh bằng PIL (Pillow)
5. Lưu trữ với phần mở rộng gốc

## Thông Báo Lỗi

| Lỗi                                       | Mô Tả                          |
| ----------------------------------------- | ------------------------------ |
| `Tệp phải là ảnh. Vui lòng chọn tệp ảnh.` | Content-Type không phải ảnh    |
| `Định dạng ảnh không được hỗ trợ...`      | Phần mở rộng không được hỗ trợ |
| `Kích thước ảnh quá lớn. Tối đa 10MB.`    | Tệp vượt quá 10MB              |
| `Tệp ảnh không hợp lệ...`                 | Tệp không phải ảnh hợp lệ      |
| `Lỗi upload ảnh...`                       | Lỗi khi xử lý tệp              |

## Cải Thiện So Với Trước

✅ Hỗ trợ nhiều định dạng ảnh (JPG, PNG, GIF, WebP, BMP)
✅ Xác thực tệp ảnh trên cả client và server
✅ Kiểm tra kích thước tệp (tối đa 10MB)
✅ Thông báo lỗi rõ ràng bằng tiếng Việt
✅ Xóa avatar cũ tự động
✅ Tạo thư mục avatars tự động khi khởi động
✅ Xác thực nội dung ảnh bằng PIL

## API Endpoints

### Upload Avatar (User)

```
POST /users/{user_id}/avatar
Content-Type: multipart/form-data

Parameters:
- avatar: UploadFile (file)

Response (200):
{
  "avatar_url": "/admin/users/1/avatar"
}

Error (400):
{
  "detail": "Lỗi: ..."
}
```

### Get Avatar (Admin)

```
GET /admin/users/{user_id}/avatar

Response (200):
[Image File]

Error (404):
{
  "detail": "Avatar không tồn tại"
}
```
