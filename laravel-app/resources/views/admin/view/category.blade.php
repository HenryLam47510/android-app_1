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
    <div class="card p-4">
        <h2 class="text-center mb-4">Danh sách sản phẩm</h2>
        <div class="row">
            @foreach ($products as $product)
                <div class="col-md-4 mb-4">
                    <div class="card h-100 shadow-sm d-flex flex-column">
                        <img src="{{ $product->image_url }}" class="card-img-top" alt="{{ $product->name }}" style="width:100%;height: 200px;object-position: center;object-fit: contain;">
                        <div class="card-body text-center d-flex flex-column flex-grow-1">
                            <h5 class="card-title">
                                <a href="{{ route('product.view', $product->id) }}" class="text-decoration-none text-primary">
                                    {{ $product->name }}
                                </a>
                            </h5>
                            <p class="card-text flex-grow-1"><strong>{{ number_format($product->price, 0, ',', '.') }} VND</strong></p>
                        </div>
                        <div class="card-footer bg-white border-0 text-center">
                            <a href="{{ route('product.view', $product->id) }}" class="btn btn-primary">Xem chi tiết</a>
                        </div>
                    </div>
                </div>
            @endforeach
        </div>
    </div>

</div>

@endsection
