<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>TNC Store - @yield('title', 'Trang chủ')</title>
    <link rel="stylesheet" href="{{ asset('css/base.css') }}">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-KyZXEJ6HtQSLK19c9S7rFWY8cKjQ5z4jz4rxck60gnnY6rjDABUsv7o74fdp5rYz" crossorigin="anonymous">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons/font/bootstrap-icons.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
</head>
<body>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-8ePLU4fCUNgs0cKALt4vqlzSXYoVt3Sz9p5v4Cg9n3ONe+qvfoPjG6tH4t8GeBz2" crossorigin="anonymous"></script>
    <!-- Header -->
    <header>
        <div class="header-top">
            <div class="logo">
                <a href="{{ route('home') }}" class="navbar-brand">TNC Store</a>
            </div>

            <!-- Thanh tìm kiếm -->
            <div class="search-bar">
                <form action="{{ route('products.search') }}" method="GET">
                    <input type="text" name="q" placeholder="Tìm kiếm sản phẩm..." required>
                    <button type="submit">Tìm kiếm</button>
                </form>
            </div>

            <div class="user-actions">
                @auth
                <div class="dropdown">
                    <button id="dropdownBtn" class="btn btn-light dropdown-toggle" type="button" data-bs-toggle="dropdown">
                        Chào, {{ auth()->user()->username }}!
                    </button>
                    
                    <ul id="dropdownMenu" class="dropdown-menu">
                        @if(auth()->user()->role == 'admin')
                            <li><a class="dropdown-item" href="{{ route('admin.sales') }}">🏠 Quản lý Index</a></li>
                            <li><a class="dropdown-item" href="{{ route('admin.products') }}">🛠 Quản lý sản phẩm</a></li>
                            <li><a class="dropdown-item" href="{{ route('admin.categories') }}">📂 Quản lý danh mục</a></li>
                            <li><a class="dropdown-item" href="{{ route('admin.users') }}">👥 Quản lý người dùng</a></li>
                            <li><a class="dropdown-item" href="{{ route('admin.orders.index') }}">🧾 Quản lý hóa đơn</a></li>
                            <li><a class="dropdown-item" href="{{ route('admin.statistics.index') }}">📊 Thống kê</a></li>
                        @endif
                        <li><a class="dropdown-item" href="{{ route('orders.my_orders') }}">🧾 Hóa đơn của tôi</a></li>
                        <li>
                            <form id="logout-form" action="{{ route('logout') }}" method="POST" style="display: none;">
                                @csrf
                            </form>
                            <a class="dropdown-item" href="#" onclick="event.preventDefault(); document.getElementById('logout-form').submit();">
                                🔑 Đăng xuất
                            </a>
                        </li>
                        
                    </ul>
                </div>                
                

                <div class="cart-info">
                    <a href="{{ route('cart.view') }}" class="cart-btn">
                        <i class="bi bi-cart-fill"></i> Giỏ hàng
                        <span class="cart-count">{{ session()->has('cart_item_count') ? session('cart_item_count') : 0 }}</span>
                    </a>
                </div>                
                
                @else
                    <a href="{{ route('login') }}" class="btn btn-primary">Tài khoản</a>
                @endauth
            </div>
        </div>

        <!-- Navigation Menu -->
        <nav class="nav-menu">
            <ul>
                @foreach ($categories as $category)
                    <li>
                        <a href="{{ route('category.view', ['slug' => $category->slug]) }}">
                            {{ $category->name }}
                        </a>
                    </li>
                @endforeach
            </ul>
        </nav>
    </header>

    <!-- Nội dung trang -->
    <main>
        @yield('content')
    </main>

    <script src="{{ asset('js/script.js') }}"></script>
    
</body>
</html>