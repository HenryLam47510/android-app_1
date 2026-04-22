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
    <h2>Thanh toán</h2>
    
    <form id="checkout-form" action="{{ route('checkout.process') }}" method="POST">
        @csrf
        <div class="mb-3">
            <label for="name" class="form-label">Họ và Tên</label>
            <input type="text" class="form-control" id="name" name="name" required>
        </div>

        <div class="mb-3">
            <label for="phone" class="form-label">Số điện thoại</label>
            <input type="text" class="form-control" id="phone" name="phone" required>
        </div>

        <div class="mb-3">
            <label for="email" class="form-label">Email</label>
            <input type="text" class="form-control" id="email" name="email" required>
        </div>

        <div class="mb-3">
            <label for="address" class="form-label">Địa chỉ giao hàng</label>
            <textarea class="form-control" id="address" name="address" rows="3" required></textarea>
        </div>


        <div class="mb-3">
            <label for="payment_method" class="form-label">Hình thức thanh toán</label>
            <select class="form-control" id="payment_method" name="payment_method" required>
                <option value="COD">Thanh toán khi nhận hàng (COD)</option>
                <option value="online">Thanh toán online</option>
            </select>
        </div>

        <div id="qr_code_section" style="display: none; text-align: center;">
            <h4>Quét mã QR để thanh toán</h4>
            <img id="qr_code" src="" alt="QR Code" width="250">
            <input type="hidden" id="transactionId" name="transactionId">
        </div>

        <h4>Sản phẩm trong giỏ hàng</h4>
        <table class="table">
            <thead>
                <tr>
                    <th>Hình ảnh</th>
                    <th>Sản phẩm</th>
                    <th>Số lượng</th>
                    <th>Đơn giá</th>
                    <th>Tổng</th>
                </tr>
            </thead>
            <tbody>
                @php 
                    $total = 0; 
                    $cart = session('cart', []);
                @endphp
                
                @if (!empty($cart))
                    @foreach($cart as $id => $item)
                        @php
                            $subtotal = $item['price'] * $item['quantity'];
                            $total += $subtotal;
                        @endphp
                        <tr>
                            <td>
                                @if(!empty($item['image_url']))
                                <img src="{{ $item['image_url'] }}" alt="Ảnh sản phẩm" width="80">

                                @else
                                    Không có ảnh
                                @endif
                            </td>
                            
                            <td>{{ $item['name'] }}</td>
                            <td>{{ $item['quantity'] }}</td>
                            <td>{{ number_format($item['price'], 0, ',', '.') }} VND</td>
                            <td>{{ number_format($subtotal, 0, ',', '.') }} VND</td>
                        </tr>
                    @endforeach
                @else
                    <tr>
                        <td colspan="5">Giỏ hàng trống</td>
                    </tr>
                @endif
            </tbody>
            
        </table>

        <h4 class="text-end fw-bold">Tổng cộng: {{ number_format($total, 0, ',', '.') }} VND</h4>

        <div class="text-center">
            <button type="submit" id="submit-btn" class="btn btn-primary">Đặt hàng</button>
        </div>
    </form>
    
</div>
<script>
    document.getElementById('payment_method').addEventListener('change', function() {
        let qrSection = document.getElementById('qr_code_section');
        let qrCode = document.getElementById('qr_code');
        let submitBtn = document.getElementById('submit-btn');
        let totalAmount = {{ $total }}; // Lấy tổng tiền từ PHP
    
        if (this.value == 'online') { // Nếu chọn SEPay
            qrSection.style.display = 'block';
            submitBtn.style.display = 'none'; // Ẩn nút đặt hàng
    
            let userId = "{{ Auth::user()->id }}"; 
            let transactionId = "hoadon" + Math.floor(Math.random() * 10000) + "user" + userId;

            qrCode.src = "https://qr.sepay.vn/img?acc=0898574187&bank=MBBank&amount=" + totalAmount + "&des=" + transactionId;
            document.getElementById("transactionId").value = transactionId.toUpperCase();
            
            // Kiểm tra trạng thái thanh toán
            checkPaymentStatus(transactionId);
        } else {
            qrSection.style.display = 'none';
            document.getElementById("transactionId").value = '0';
            submitBtn.style.display = 'block'; // Hiện lại nút đặt hàng
        }
    });
    
    function checkPaymentStatus(transactionId) {
        let apiUrl = "{{ url('/api/transactions') }}"; // Gọi API Laravel
    
        let checkInterval = setInterval(async function () {
            try {
                let response = await fetch(apiUrl, { method: 'GET' });
                let data = await response.json();
    
                if (data && data.transactions) {
                    let found = data.transactions.some(txn => 
                    txn.transaction_content.toLowerCase().includes(transactionId.toLowerCase())
                    );


                    console.log(found);
                    
                    if (found) {
                        clearInterval(checkInterval);
                        document.getElementById("checkout-form").submit();
                    }
                }
            } catch (error) {
                console.error("Lỗi kết nối API:", error);
            }
        }, 5000); // Kiểm tra mỗi 5 giây
    }
    </script>
    
@endsection
