<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TNC Store - Đăng Nhập</title>
    <link rel="stylesheet" href="{{ asset('css/login.css') }}">
    <!-- Bootstrap CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<!-- jQuery -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</head>
<body>
    @if(session('success'))
    <div class="alert alert-success">
        {{ session('success') }}
    </div>
@endif

@if($errors->any())
    <div class="alert alert-danger">
        <ul>
            @foreach ($errors->all() as $error)
                <li>{{ $error }}</li>
            @endforeach
        </ul>
    </div>
@endif

<div class="container">
    <h2>Đặt Lại Mật Khẩu</h2>

    <form action="{{ route('password.update') }}" method="POST">
        @csrf
    
        <!-- Token reset mật khẩu -->
        <input type="hidden" name="token" value="{{ $token }}">
    
        <div class="mb-3">
            <label for="email">Email:</label>
            <input type="email" name="email" class="form-control" required>
        </div>
    
        <div class="mb-3">
            <label for="password">Mật khẩu mới:</label>
            <input type="password" name="password" class="form-control" required>
        </div>
    
        <div class="mb-3">
            <label for="password_confirmation">Nhập lại mật khẩu:</label>
            <input type="password" name="password_confirmation" class="form-control" required>
        </div>
    
        <button type="submit" class="btn btn-primary">Đặt lại mật khẩu</button>
    </form>
    

</div>
</body>
</html>





