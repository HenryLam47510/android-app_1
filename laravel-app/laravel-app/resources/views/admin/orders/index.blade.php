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
    <h2>Quản lý hóa đơn</h2>

    <!-- Bộ lọc theo ngày -->
    <div class="mb-3">
        <input type="date" id="date-filter" class="form-control" value="{{ $date }}">
    </div>

    <div id="order-list">
        @if(count($ordersByDate) > 0)
            @foreach($ordersByDate as $date => $orders)
                <h3>Ngày: {{ \Carbon\Carbon::parse($date)->format('m/d/Y') }}</h3>
                <table class="table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Khách hàng</th>
                            <th>Tổng tiền</th>
                            <th>Trạng thái</th>
                            <th>Ngày đặt hàng</th>
                            <th>Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($orders as $order)
                            <tr>
                                <td>{{ $order->id }}</td>
                                <td>{{ $order->customer_name }}</td>
                                <td>{{ number_format($order->total_price, 0, ',', '.') }} VND</td>
                                <td>
                                    @if($order->status == 'pending')
                                        <span class="badge bg-warning">Pending</span>
                                    @elseif($order->status == 'completed')
                                        <span class="badge bg-success">Completed</span>
                                    @else
                                        <span class="badge bg-danger">Canceled</span>
                                    @endif
                                </td>
                                <td>{{ $order->created_at->format('d/m/Y H:i') }}</td>
                                <td><a href="{{ route('admin.orders.show', $order->id) }}" class="btn btn-info">Xem</a></td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            @endforeach
        @else
            <p>Không có hóa đơn nào trong ngày này.</p>
        @endif
    </div>
</div>
<script>
    document.getElementById("date-filter").addEventListener("change", function() {
        let selectedDate = this.value;
        if (selectedDate) {
            let url = new URL(window.location.href);
            url.searchParams.set("date", selectedDate);
            window.location.href = url.toString();
        }
    });

</script>
@endsection
@section('scripts')
@endsection
