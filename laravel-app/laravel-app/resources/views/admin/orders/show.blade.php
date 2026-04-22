@extends('layouts.base')

@section('content')
<link rel="stylesheet" href="{{ asset('css/ad-category.css') }}">
<!-- Bootstrap CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<!-- jQuery -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<div class="container">
    <h2>Chi tiết đơn hàng #{{ $order->id }}</h2>
    <p><strong>Ngày đặt hàng:</strong> {{ $order->created_at->format('d/m/Y H:i') }}</p>
    <p><strong>Tên:</strong> {{ $order->customer_name }}</p>
    <p><strong>Email:</strong> {{ $order->email }}</p>
    <p><strong>Địa chỉ:</strong> {{ $order->address }}</p>
    <p><strong>Số điện thoại:</strong> {{ $order->phone }}</p>
    <p><strong>Phương thức thanh toán:</strong> {{ $order->payment_method ?? 'Chưa xác định' }}</p>
    <p><strong>Tổng tiền:</strong> {{ number_format($order->total_price, 0, ',', '.') }} VND</p>
    <p><strong>Trạng thái:</strong> 
        <span class="badge 
            {{ $order->status == 'pending' ? 'bg-warning' : '' }}
            {{ $order->status == 'processing' ? 'bg-primary' : '' }}
            {{ $order->status == 'completed' ? 'bg-success' : '' }}
            {{ $order->status == 'canceled' ? 'bg-danger' : '' }}">
            {{ ucfirst($order->status) }}
        </span>
    </p>

    @if ($order->status == 'canceled' && $order->cancel_reason)
        <p><strong>Lý do hủy:</strong> {{ $order->cancel_reason }}</p>
    @endif

    <h3>Sản phẩm trong đơn hàng</h3>
    <table class="table table-bordered">
        <thead>
            <tr>
                <th>Ảnh</th>
                <th>Tên sản phẩm</th>
                <th>Số lượng</th>
                <th>Giá</th>
                <th>Tổng</th>
            </tr>
        </thead>
        <tbody>
            @foreach ($order->items as $item)
            <tr>
                <td>
                    <img src="{{ $item->product->image_url ?? '/images/no-image.png' }}" width="50">
                </td>
                <td>{{ $item->product->name }}</td>
                <td>{{ $item->quantity }}</td>
                <td>{{ number_format($item->price, 0, ',', '.') }} VND</td>
                <td>{{ number_format($item->quantity * $item->price, 0, ',', '.') }} VND</td>
            </tr>
            @endforeach
        </tbody>
    </table>

    <h3>Cập nhật trạng thái đơn hàng</h3>
    <form action="{{ route('admin.orders.updateStatus', $order->id) }}" method="POST">
        @csrf
        <div class="mb-3">
            <label for="status" class="form-label">Trạng thái:</label>
            <select id="status" name="status" class="form-control" onchange="toggleReasonField()">
                <option value="pending" {{ $order->status == 'pending' ? 'selected' : '' }}>Chờ xử lý</option>
                <option value="processing" {{ $order->status == 'processing' ? 'selected' : '' }}>Đang xử lý</option>
                <option value="completed" {{ $order->status == 'completed' ? 'selected' : '' }}>Hoàn thành</option>
                <option value="canceled" {{ $order->status == 'canceled' ? 'selected' : '' }}>Hủy</option>
            </select>
        </div>
    
        <!-- Chọn lý do hủy (Ẩn nếu không chọn Hủy) -->
        <div id="cancelReasonDiv" style="display: none;">
            <label for="cancel_reason" class="form-label">Lý do hủy:</label>
            <select id="cancel_reason" name="cancel_reason" class="form-control">
                <option value="">-- Chọn lý do --</option>
                <option value="Không thể liên lạc với khách hàng">Không thể liên lạc với khách hàng</option>
                <option value="Khách hàng yêu cầu hủy">Khách hàng yêu cầu hủy</option>
                <option value="Hết hàng">Hết hàng</option>
                <option value="Lý do khác">Lý do khác</option>
            </select>
        </div>
    
        <button type="submit" class="btn btn-primary mt-2">Cập nhật</button>
    </form>
    

    <a href="{{ route('admin.orders.index') }}" class="btn btn-secondary mt-3">Quay lại</a>
</div>
<script>
    function toggleReasonField() {
        var status = document.getElementById("status").value;
        var reasonDiv = document.getElementById("cancelReasonDiv");
        
        if (status === "canceled") {
            reasonDiv.style.display = "block";
        } else {
            reasonDiv.style.display = "none";
        }
    }

    // Kiểm tra trạng thái khi trang tải
    document.addEventListener("DOMContentLoaded", function() {
        toggleReasonField();
    });
</script>

@endsection
