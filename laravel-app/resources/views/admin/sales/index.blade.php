@extends('layouts.base')

@section('title', 'Quản lý Sales')

@section('content')
<link rel="stylesheet" href="{{ asset('css/ad-category.css') }}">
<!-- Bootstrap CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<!-- jQuery -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<div class="container">
    <h1>Quản lý Sales trên Trang Chủ</h1>

    @if(session('success'))
        <div class="alert alert-success">{{ session('success') }}</div>
    @endif

    <form action="{{ route('admin.sales.store') }}" method="POST">
        @csrf
        <label for="title">Tiêu đề Sale:</label>
        <input type="text" id="title" name="title" required>

        <label for="category_id">Chọn danh mục:</label>
        <select id="category_id" name="category_id" required>
            @foreach($categories as $category)
                <option value="{{ $category->id }}">{{ $category->name }}</option>
            @endforeach
        </select>

        <label for="display_type">Chọn kiểu hiển thị:</label>
        <select id="display_type" name="display_type">
            <option value="latest">Sản phẩm mới nhất</option>
            <option value="bestseller">Sản phẩm bán chạy</option>
        </select>

        <button type="submit">Thêm</button>
    </form>

    <h2>Danh sách Sale</h2>
    <table>
        <tr>
            <th>Tiêu đề</th>
            <th>Danh mục</th>
            <th>Kiểu hiển thị</th>
            <th>Hành động</th>
        </tr>
        @foreach($sales as $sale)
            <tr>
                <td>{{ $sale->title }}</td>
                <td>{{ $sale->category->name }}</td>
                <td>{{ $sale->display_type == 'latest' ? 'Sản phẩm mới nhất' : 'Bán chạy nhất' }}</td>
                <td>
                    <form action="{{ route('admin.sales.destroy', $sale->id) }}" method="POST">
                        @csrf
                        @method('DELETE')
                        <button type="submit">Xóa</button>
                    </form>
                </td>
            </tr>
        @endforeach
    </table>
</div>
    
@endsection
