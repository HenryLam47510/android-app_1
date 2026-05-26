# Class Diagram dự án

## Sơ đồ lớp chính

```mermaid
classDiagram
    class User {
        int id
        String name
        String email
        String password
        String role
        DateTime createdAt
        String? avatarUrl
    }

    class Student {
        String id
        String name
        String email
        String phoneNumber
        String classId
        String status
        String? avatarUrl
        List<String> faceImageUrls
        double attendanceRate
        List<String> attendanceHistory
    }

    class Lecturer {
        String id
        String name
        String email
    }

    class Subject {
        String id
        String code
        String name
        String description
        String lecturerId
        List<String> managerIds
        List<String> activityLogs
    }

    class ClassModel {
        String id
        String name
        String code
        String subjectId
        String lecturerId
        int maxSize
        String schedule
        int attendanceWindowMinutes
        double faceThreshold
        List<String> studentIds
        List<String> managerIds
        double attendanceRate
        int totalSessions
        List<String> activityLogs
    }

    class AdminVideo {
        String id
        String filename
        Duration duration
        DateTime createdAt
        String status
        String videoUrl
        List<VideoSegment> segments
        List<AiResult> aiResults
    }

    class VideoSegment {
        String id
        int segmentNumber
        DateTime startTime
        DateTime endTime
        Duration duration
        String status
        String filePath
    }

    class AiResult {
        String timestamp
        String emotion
    }

    class FrameEmotion {
        int id
        String emotion
        double confidence
        DateTime timestamp
        String? imagePath
        bool stateChange
        String? previousEmotion
    }

    class StudySession {
        String id
        DateTime startTime
        DateTime? endTime
        int duration
        double avgFocusScore
        String dominantEmotion
        Map<String,int> emotionFrequency
        String? videoPath
        int totalFrames
    }

    class VideoSyncItem {
        int? id
        String filePath
        int duration
        DateTime createdAt
        String syncStatus
        String? serverId
    }

    %% Associations
    ClassModel --> "1" Subject : subjectId
    ClassModel --> "1" Lecturer : lecturerId
    ClassModel --> "*" Student : studentIds
    Subject --> "1" Lecturer : lecturerId
    Student --> "1" ClassModel : classId
    User --> "*" AdminVideo : user_id
    User --> "*" StudySession : user_id
    User --> "*" VideoSegment : user_id
    User --> "*" FrameEmotion : user_id
    AdminVideo --> "*" VideoSegment : segments
    AdminVideo --> "*" AiResult : aiResults
    StudySession --> "*" AdminVideo : videos
```

## Chức năng chính và chức năng con

1. Quản lý người dùng
   - Đăng ký / đăng nhập
   - Quản lý profile
   - Phân quyền user / student / lecturer / admin

2. Quản lý đào tạo
   - Quản lý môn học (`Subject`)
   - Quản lý lớp học (`ClassModel`)
   - Quản lý sinh viên (`Student`)
   - Gán giảng viên (`Lecturer`) cho môn học và lớp học

3. Giám sát và phân tích video
   - Tải video lên và xử lý (`AdminVideo`, `VideoSegment`)
   - Trích xuất đoạn video, phân đoạn và trạng thái xử lý
   - Phân tích cảm xúc từ khung hình (`FrameEmotion`)

4. Theo dõi buổi học / học tập
   - Lưu lịch sử phiên học (`StudySession`)
   - Tính điểm tập trung, cảm xúc chiếm ưu thế
   - Hiển thị thống kê session và chart

5. Đồng bộ và lưu trữ cục bộ
   - Lưu video cục bộ và theo dõi trạng thái đồng bộ (`VideoSyncItem`)
   - Quản lý trạng thái offline / uploading / synced / failed

## Lưu ý

- `Post` là mô hình test API và không phải bảng chính của hệ thống.
- `VideoSyncItem` là bảng local SQLite dùng cho chức năng đồng bộ video cục bộ.
- `FrameEmotion` và `VideoSegment` là phần lõi cho việc phân tích hành vi, tập trung và cảm xúc.
