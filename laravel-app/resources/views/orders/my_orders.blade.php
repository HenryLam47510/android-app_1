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
    <h2>📝 Danh sách đơn hàng của bạn</h2>
    
    @if ($orders->isEmpty())
        <p>Bạn chưa có đơn hàng nào.</p>
    @else
        <table class="table">
            <thead>
                <tr>
                    <th>Mã đơn hàng</th>
                    <th>Ngày đặt</th>
                    <th>Tổng tiền</th>
                    <th>Trạng thái</th>
                    <th>Chi tiết</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($orders as $order)
                <tr>
                    <td>#{{ $order->id }}</td>
                    <td>{{ $order->created_at->format('d/m/Y H:i') }}</td>
                    <td>{{ number_format($order->total_price, 0, ',', '.') }} VND</td>
                    <td>
                        @if ($order->status == 'pending')
                            <span class="badge bg-warning">Chờ xử lý</span>
                        @elseif ($order->status == 'processing')
                            <span class="badge bg-primary">Đang xử lý</span>
                        @elseif ($order->status == 'completed')
                            <span class="badge bg-success">Hoàn thành</span>
                        @elseif ($order->status == 'canceled')
                            <span class="badge bg-danger">Đã hủy</span>
                        @endif
                    </td>
                    <td>
                        <a href="{{ route('orders.details', $order->id) }}" class="btn btn-info btn-sm">Xem</a>
                    </td>
                </tr>
                @endforeach
            </tbody>
        </table>
    @endif
</div>
@endsection
