@extends('layouts.base')

@section('content')
    <link rel="stylesheet" href="{{ asset('css/ad-category.css') }}">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

    <div class="container mt-4">
        <h2 class="mb-3">🛠 Quản lý sản phẩm</h2>
        <div class="card shadow-lg p-3">
            
            <!-- Thanh điều khiển -->
            <div class="d-flex justify-content-between align-items-center mb-3">
                <a href="{{ route('admin.products.create') }}" class="btn btn-primary btn-sm">
                    + Thêm sản phẩm
                </a>

                <div class="input-group w-50">
                    
                    <input type="text" class="form-control" placeholder="Tìm kiếm sản phẩm..." aria-label="Tìm kiếm">
                    <button class="btn btn-outline-secondary">
                        <i class="fas fa-search"></i>
                    </button>
                </div>
            </div>

            <!-- Bộ lọc -->
            <div class="row g-2 mb-3">
                <div class="col-md-3">
                    <select class="form-select">
                        <option value="">Lọc theo danh mục</option>
                        @foreach($categories as $category)
                            <option value="{{ $category->id }}">{{ $category->name }}</option>
                        @endforeach
                    </select>
                </div>
                
                <div class="col-md-3">
                    <select class="form-select">
                        <option value="">Lọc theo số lượng tồn kho</option>
                        <option value="low">Còn ít</option>
                        <option value="high">Còn nhiều</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <button class="btn btn-success w-100">Xác nhận bộ lọc</button>
                </div>
            </div>

            <!-- Bảng sản phẩm -->
<table class="table table-striped">
    <thead>
        <tr>
            <th>ID</th>
            <th>Hình ảnh</th> <!-- ✅ Cột hình ảnh -->
            <th>Tên sản phẩm</th>
            <th>Giá</th>
            <th>Số lượng</th>
            <th>Hành động</th>
        </tr>
    </thead>
    <tbody>
        @foreach($products as $product)
        <tr>
            <td>{{ $product->id }}</td>
            <td>
                @if($product->image_url)
                    <img src="{{ $product->image_url }}" alt="Hình ảnh sản phẩm" style="width: 80px; height: 80px;">
                    @else
                    <span>Không có ảnh</span>
                @endif
            </td>
            <td>{{ $product->name }}</td>
            <td>{{ number_format($product->price) }}đ</td>
            <td>{{ $product->stock }}</td>
            <td>
                <a href="{{ route('admin.products.edit', $product->id) }}" class="btn btn-warning btn-sm">✏ Sửa</a>
                <form action="{{ route('products.destroy', $product->id) }}" method="POST" style="display:inline-block;">
                    @csrf
                    @method('DELETE')
                    <button type="submit" class="btn btn-danger btn-sm" onclick="return confirm('Bạn có chắc chắn muốn xóa sản phẩm này?');">🗑 Xóa</button>
                </form>
            </td>
        </tr>
        @endforeach
    </tbody>
</table>

        </div>
    </div>
@endsection
