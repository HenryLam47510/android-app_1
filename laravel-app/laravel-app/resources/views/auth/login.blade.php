<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TNC Store - Đăng Nhập</title>
    <link rel="stylesheet" href="{{ asset('css/login.css') }}">
</head>
<body>
    <div class="login-container">
        <h2>Đăng nhập</h2>

        <!-- Hiển thị thông báo lỗi nếu có -->
        @if(session('error'))
            <div class="error-message">
                <ul>
                    <li>{{ session('error') }}</li>
                </ul>
            </div>
        @endif

        <!-- Form đăng nhập -->
        <form method="POST" action="{{ route('login') }}">
            @csrf
            <label for="username">Tên đăng nhập:</label>
            <input type="text" name="username" id="username" required>
        
            <label for="password">Mật khẩu:</label>
            <input type="password" name="password" id="password" required>
        
            <button type="submit">Đăng nhập</button>
        </form>
        

        <p>Chưa có tài khoản? <a href="{{ route('register') }}">Đăng ký ngay</a></p>
        <p>Bạn quên mật khẩu? <a href="{{ route('password.request') }}">Reset Password</a></p>
    </div>
</body>
</html>
