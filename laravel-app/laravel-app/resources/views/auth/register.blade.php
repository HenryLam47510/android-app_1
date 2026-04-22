<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TNC Store - Đăng Ký</title>
    <link rel="stylesheet" href="{{ asset('css/register.css') }}">
</head>
<body>
    <div class="login-container">
        <h2>TNC Store</h2>
        <h3>Đăng ký tài khoản</h3>

        <!-- Hiển thị thông báo lỗi nếu có -->
        @if($errors->any())
            <div class="error-message">
                <ul>
                    @foreach ($errors->all() as $error)
                        <li>{{ $error }}</li>
                    @endforeach
                </ul>
            </div>
        @endif

        <!-- Form đăng ký -->
        <form method="POST" action="{{ route('register') }}">
            @csrf
            <label for="username">Tên đăng nhập:</label>
            <input type="text" name="username" id="username" required>

            <label for="full_name">Họ và tên:</label>
            <input type="text" name="full_name" id="full_name" required>
        
            <label for="email">Email:</label>
            <input type="email" name="email" id="email" required>
        
            <label for="password">Mật khẩu:</label>
            <input type="password" name="password" id="password" required>
        
            <button type="submit">Đăng ký</button>
        </form>

        <p>Đã có tài khoản? <a href="{{ route('login') }}">Đăng nhập ngay</a></p>


    </div>
</body>
</html>
