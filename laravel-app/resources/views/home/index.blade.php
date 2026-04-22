@extends('layouts.base')

@section('title', 'Trang chủ - TNC Store')

@section('content')
<link rel="stylesheet" href="{{ asset('css/home.css') }}">
<!-- Bootstrap CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<!-- jQuery -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<section>
    <div id="bannerCarousel" class="carousel slide" data-bs-ride="carousel">
        <div class="carousel-inner">
            <div class="carousel-item active">
                <img src="{{ asset('images/banner1.jpg') }}" class="d-block w-100" alt="Banner 1">
            </div>
            <div class="carousel-item">
                <img src="{{ asset('images/banner2.jpg') }}" class="d-block w-100" alt="Banner 2">
            </div>
            <div class="carousel-item">
                <img src="{{ asset('images/banner3.jpg') }}" class="d-block w-100" alt="Banner 3">
            </div>
        </div>
        <button class="carousel-control-prev" type="button" data-bs-target="#bannerCarousel" data-bs-slide="prev">
            <span class="carousel-control-prev-icon" aria-hidden="true"></span>
            <span class="visually-hidden">Previous</span>
        </button>
        <button class="carousel-control-next" type="button" data-bs-target="#bannerCarousel" data-bs-slide="next">
            <span class="carousel-control-next-icon" aria-hidden="true"></span>
            <span class="visually-hidden">Next</span>
        </button>
    </div>
</section>

@foreach($sections as $section)
    @if($section['products']->isNotEmpty())
    <div class="container mt-5">
        <h4 class="mb-3">{{ $section['title'] }}</h4>
        <div class="row">
            @foreach($section['products'] as $product)
                <div class="col-md-3 mb-4">
                    <div class="card h-100">
                        <a href="{{ route('admin.view.detail-product', $product->id) }}">
                            <img style="width:100%;height: 200px;object-position: center;object-fit: contain;"src="{{ asset($product->image_url) }}" class="card-img-top" alt="{{ $product->name }}">
                        </a>
                        <div class="card-body text-center">
                            <a style="text-decoration: none"  href="{{ route('admin.view.detail-product', $product->id) }}" class="product-title text-dark fw-bold">
                                {{ $product->name }}
                            </a>
                            <p class="text-danger fw-bold mt-2">{{ number_format($product->price) }} VND</p>
                            <a href="{{ route('admin.view.detail-product', $product->id) }}" class="btn btn-primary btn-sm">Xem chi tiết</a>
                        </div>
                    </div>
                </div>
            @endforeach
        </div>
    </div>
    @endif
@endforeach

<script>
    let slideIndex = 0;

    function showSlides() {
        let slides = document.getElementsByClassName("slide");
        for (let i = 0; i < slides.length; i++) {
            slides[i].style.display = "none";  
        }
        slideIndex++;
        if (slideIndex > slides.length) {slideIndex = 1}    
        slides[slideIndex-1].style.display = "block";  
        setTimeout(showSlides, 400); // Chuyển slide sau 4 giây
    }

</script>
@endsection
