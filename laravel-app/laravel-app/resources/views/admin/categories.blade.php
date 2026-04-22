@extends('layouts.base')

@section('content')
<link rel="stylesheet" href="{{ asset('css/ad-category.css') }}">
<!-- Bootstrap CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<!-- jQuery -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

@if(session('success'))
    <div class="alert alert-success">
        {{ session('success') }}
    </div>
@endif
<script>
    document.addEventListener("DOMContentLoaded", function() {
        console.log("Bootstrap version:", bootstrap);
    });
</script>
<script>
    document.addEventListener("click", function(event) {
        console.log("Clicked element:", event.target);
    });
</script>

<div class="container mt-4">
    <h3 class="text-center fw-bold">Quản lý danh mục</h3>

    <div class="card shadow-lg p-4">
        <div class="d-flex justify-content-between mb-3">
            <button class="btn btn-danger" data-bs-toggle="modal" data-bs-target="#addCategoryModal">
                ➕ Thêm danh mục
            </button>
        </div>

        <table class="table table-bordered text-center align-middle">
            <thead class="table-dark">
                <tr>
                    <th>ID</th>
                    <th>Tên danh mục</th>
                    <th>Hành động</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($categories as $category)
                <tr>
                    <td>{{ $category->id }}</td>
                    <td>{{ $category->name }}</td>
                    <td>
                        <button class="btn btn-warning btn-sm" onclick="editCategory({{ $category->id }}, '{{ $category->name }}')">
                            ✏️ Sửa
                        </button>
                        <form action="{{ route('categories.destroy', $category->id) }}" method="POST" class="d-inline">
                            @csrf
                            @method('DELETE')
                            <button type="submit" class="btn btn-danger btn-sm" onclick="return confirm('Bạn có chắc muốn xóa?')">
                                ❌ Xóa
                            </button>
                        </form>
                    </td>
                </tr>
                @endforeach
            </tbody>
        </table>
    </div>
</div>

{{-- Modal thêm danh mục --}}
<div class="modal fade" id="addCategoryModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title">Thêm danh mục</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <form action="{{ route('categories.store') }}" method="POST">
                    @csrf
                    <div class="mb-3">
                        <input type="text" name="name" class="form-control" placeholder="Nhập tên danh mục..." required>
                    </div>
                    <button type="submit" class="btn btn-success w-100">Lưu</button>
                </form>
            </div>
        </div>
    </div>
</div>

{{-- JavaScript để chỉnh sửa danh mục --}}
<script>
    function editCategory(id, name) {
        let newName = prompt("Chỉnh sửa tên danh mục:", name);
        if (newName !== null) {
            fetch(`/admin/categories/${id}`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json', 'X-CSRF-TOKEN': '{{ csrf_token() }}' },
                body: JSON.stringify({ name: newName })
            }).then(response => location.reload());
        }
    }
</script>
@endsection
