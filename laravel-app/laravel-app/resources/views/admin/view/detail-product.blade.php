@extends('layouts.base')

@section('content')

<link rel="stylesheet" href="{{ asset('css/detail-product.css') }}">
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
<div class="container mt-4">
    <div class="container mt-5">
    <div class="row">
        <div class="col-md-5">
            <img src="{{ asset($product->image_url) }}" alt="{{ $product->name }}" class="img-fluid rounded" style="width: 100%">
            <div class="mt-3">
                <span class="badge bg-primary">Chính hãng</span>
                <span class="badge bg-success">Bảo hành 12 tháng</span>
            </div>
        </div>
        <div class="col-md-7">
            <h3>{{ $product->name }}</h3>
            <p style="font-size:20px; color:red;"><strong>Giá: </strong>{{ number_format($product->price) }} VND</p>
            <p><strong>Số lượng đã bán:</strong> {{ $product->sold_quantity }} chiếc</p>
            <a href="#" class="btn btn-success add-to-cart" data-id="{{ $product->id }}" data-name="{{ $product->name }}" 
                data-price="{{ $product->price }}" data-image="{{ $product->image_url }}">
                Thêm vào giỏ hàng
            </a>
            <a href="{{ url()->previous() }}" class="btn btn-warning ">Quay lại</a>
        </div>
    </div>
    </div>

    <div class="container mt-5">
        <h4 class="mb-3">Sản phẩm tương tự</h4>
        <div class="row">
            @foreach($relatedProducts as $related)
                <div class="col-md-3">
                    <div class="card">
                        <img style="width:100%;height: 200px;object-position: center;object-fit: contain;" src="{{ asset($related->image_url) }}" class="card-img-top" alt="{{ $related->name }}">
                        <div class="card-body text-center">
                            <p class="product-title">{{ $related->name }}</p>
                            <p class="text-danger fw-bold">{{ number_format($related->price) }} VND</p>
                            <a href="{{ route('admin.view.detail-product', $related->id) }}" class="btn btn-primary btn-sm">Xem chi tiết</a>
                        </div>
                    </div>
                </div>
            @endforeach
        </div>
    </div>
    <div class="container mt-5">
        <h3 class="review-header">Đánh giá của khách hàng</h3>
        
        @php
            $reviews = $product->reviews ?? collect();
            $avgRating = $reviews->isNotEmpty() ? number_format($reviews->avg('rating'), 1) : 'Chưa có';
            $totalReviews = $reviews->count();
            $ratingCounts = [5 => 0, 4 => 0, 3 => 0, 2 => 0, 1 => 0];
            foreach ($reviews as $review) {
                $ratingCounts[$review->rating]++;
            }
        @endphp
    
        <div class="rating-summary">
            <div class="average-rating">
                <span>{{ $avgRating }}</span> ⭐
            </div>
            <div class="rating-bar">
                @foreach ($ratingCounts as $stars => $count)
                    @php $percentage = $totalReviews > 0 ? ($count / $totalReviews) * 100 : 0; @endphp
                    <div>
                        <span>{{ $stars }}</span>
                        <div class="progress">
                            <div class="progress-fill" style="width: {{ $percentage }}%;"></div>
                        </div>
                        <span>{{ round($percentage, 0) }}%</span>
                    </div>
                @endforeach
            </div>
        </div>
    
        @if(Auth::check())
        <form class="review-form" action="{{ url('/products/'.$product->id.'/review') }}" method="POST">
            @csrf
            <label>Đánh giá:</label>
            <select name="rating">
                <option value="5">⭐⭐⭐⭐⭐</option>
                <option value="4">⭐⭐⭐⭐</option>
                <option value="3">⭐⭐⭐</option>
                <option value="2">⭐⭐</option>
                <option value="1">⭐</option>
            </select>
            <textarea name="comment" placeholder="Viết đánh giá..."></textarea>
            <button type="submit">Gửi đánh giá</button>
        </form>
        @else
            <p><a href="{{ route('login') }}">Đăng nhập</a> để viết đánh giá.</p>
        @endif
    
        <div class="review-list">
            @if($reviews->isNotEmpty())
                @foreach($reviews as $review)
                    <div class="review">
                        <p><strong>{{ $review->user->full_name }}</strong> ⭐{{ number_format($review->rating, 1) }}</p>
                        <p>{{ $review->comment }}</p>
                        <p><small>{{ $review->created_at->format('d/m/Y') }}</small>
                            <a href="#" class="reply-button" data-review-id="{{ $review->id }}">Phản hồi</a>
                        </p>
                        {{-- Form phản hồi (ẩn ban đầu) --}}
                        <form class="reply-form" action="{{ url('/reviews/'.$review->id.'/reply') }}" method="POST" style="display: none;">
                            @csrf
                            <textarea name="reply_content" placeholder="Nhập phản hồi..." required></textarea>
                            <button type="submit">Gửi phản hồi</button>
                        </form>

                        <!-- Hiển thị phản hồi -->
                        @if($review->replies->isNotEmpty())
                        <div class="review-replies">
                            @foreach($review->replies as $reply)
                                <div class="review-reply">
                                    <p><strong>{{ $reply->user->full_name }}</strong></p>
                                    <p>{{ $reply->reply_content }}</p>
                                    <p><small>{{ $reply->created_at->format('d/m/Y') }}</small>
                                        <a href="#" class="reply-button" data-review-id="{{ $review->id }}">Phản hồi</a>
                                    </p>
                                </div>
                            @endforeach
                        </div>
                        @endif
                    </div>
                @endforeach
            @else
                <p>Chưa có đánh giá nào.</p>
            @endif
        </div>
    </div>
    
</div>

<script>
document.addEventListener("DOMContentLoaded", function() {
    document.querySelectorAll(".reply-button").forEach(button => {
        button.addEventListener("click", function(event) {
            event.preventDefault(); // Ngăn chặn load lại trang khi click

            let reviewId = this.getAttribute("data-review-id");
            let replyForm = this.closest(".review").querySelector(".reply-form");

            // Ẩn tất cả các form khác trước khi mở form hiện tại
            document.querySelectorAll(".reply-form").forEach(form => {
                if (form !== replyForm) {
                    form.style.display = "none";
                }
            });

            // Toggle hiển thị form phản hồi
            replyForm.style.display = (replyForm.style.display === "none" || replyForm.style.display === "") ? "block" : "none";
        });
    });
});


    document.addEventListener('DOMContentLoaded', function () {
        document.querySelectorAll('.add-to-cart').forEach(button => {
            button.addEventListener('click', function (event) {
                event.preventDefault();
                
                let productId = this.getAttribute('data-id');
                let productName = this.getAttribute('data-name');
                let productPrice = this.getAttribute('data-price');
                let productImage = this.getAttribute('data-image');

                fetch('/cart/add', {
                    method: 'POST',
                    headers: {
                        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content,
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        id: productId,
                        name: productName,
                        price: productPrice,
                        image_url: productImage
                    })
                })
                .then(response => response.json())
                .then(data => {
                    document.querySelector('.cart-count').innerText = data.cart_count;
                    alert('Sản phẩm đã được thêm vào giỏ hàng!');
                });
            });
        });
    });
</script>
@endsection
