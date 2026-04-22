@extends('layouts.base')

@section('content')

    <link rel="stylesheet" href="{{ asset('css/ad-category.css') }}">
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <div class="container mt-4">
        <h2 class="mb-4">🛒 Giỏ hàng của bạn</h2>

        @if(session('cart') && count(session('cart')) > 0)
            <table class="table table-bordered">
                <thead class="table-dark">
                    <tr>
                        <th>Hình ảnh</th>
                        <th>Tên sản phẩm</th>
                        <th>Đơn giá</th>
                        <th>Số lượng</th>
                        <th>Tổng</th>
                        <th>Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    @php $total = 0; @endphp
                    @foreach(session('cart') as $id => $item)
                            @php 
                                $price = $item['price'] ?? 0;
                                $quantity = $item['quantity'] ?? 1;
                                $subtotal = $price * $quantity;
                            @endphp
                            <tr>
                                <td>
                                    <img src="{{ $item['image_url'] ?? asset('default.jpg') }}" width="60"
                                        alt="{{ $item['name'] ?? 'Sản phẩm' }}">
                                </td>
                                <td>{{ $item['name'] ?? 'Không có tên' }}</td>
                                <td>{{ number_format($price, 0, ',', '.') }} VND</td>
                                <td>
                                    <input type="number" class="form-control update-quantity" data-id="{{ $id }}"
                                        value="{{ $quantity }}" min="1">
                                </td>
                                <td>{{ number_format($subtotal, 0, ',', '.') }} VND</td>
                                <td>
                                    <button class="remove-from-cart btn btn-danger" data-id="{{ $id }}"
                                    data-url="{{ route('cart.remove') }}">
                                        Xóa
                                    </button>

                                </td>
                            </tr>
                            @php $total += $subtotal; @endphp
                    @endforeach
                </tbody>
            </table>

            <h4 class="text-end">Tổng cộng: <strong>{{ number_format($total, 0, ',', '.') }} VND</strong></h4>

            <div class="text-end mt-3">
                <a href="{{ route('checkout') }}" class="btn btn-success">Thanh toán</a>
                <a href="{{ route('home') }}" class="btn btn-secondary">Tiếp tục mua sắm</a>
            </div>
        @else
            <div class="alert alert-warning">Giỏ hàng của bạn đang trống!</div>
            <a href="{{ route('home') }}" class="btn btn-primary">Quay lại mua sắm</a>
        @endif
    </div>

    <script>
        $(document).ready(function () {
            $('.update-quantity').on('change', function () {
                let productId = $(this).data('id');
                let newQuantity = $(this).val();

                $.ajax({
                    url: '/cart/update',
                    type: 'POST',
                    headers: { 'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content') }, // Thêm CSRF token
                    data: { id: productId, quantity: newQuantity },
                    success: function () {
                        location.reload();
                    }
                });

            });
        });

        $(document).on('click', '.remove-from-cart', function () {
            var productId = $(this).data('id');
            var url = $(this).data('url'); // Lấy URL từ attribute

            $.ajax({
                url: url,
                type: "POST",
                data: {
                    _token: $('meta[name="csrf-token"]').attr('content'), // Lấy CSRF token đúng cách
                    id: productId
                },
                success: function (response) {
                    if (response.success) {
                        $("button[data-id='" + productId + "']").closest("tr").remove(); // Xóa dòng sản phẩm
                        $(".cart-count").text(response.cart_count); // Cập nhật số lượng giỏ hàng
                    } else {
                        alert("Xóa không thành công!");
                    }
                },
                error: function (xhr) {
                    console.log(xhr.responseText);
                    alert("Xóa không thành công!");
                }
            });
        });

        $('.update-quantity').on('change', function () {
            let productId = $(this).data('id');
            let newQuantity = $(this).val();

            $.ajax({
                url: '/cart/update',
                type: 'POST',
                headers: { 'X-CSRF-TOKEN': $('meta[name="csrf-token"]').attr('content') },
                data: { id: productId, quantity: newQuantity },
                success: function () {
                    location.reload();
                },
                error: function (response) {
                    alert(response.responseJSON.error);
                    location.reload();
                }
            });
        });

    </script>

@endsection