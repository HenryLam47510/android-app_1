@extends('layouts.base')

@section('title', 'Trang chủ - TNC Store')

@section('content')


    <section class="slideshow">
        <div class="slide-container">
            <div class="slide fade">
                <img src="{{ asset('images/banner1.jpg') }}" alt="Banner 1">
            </div>
            <div class="slide fade">
                <img src="{{ asset('images/banner2.jpg') }}" alt="Banner 2">
            </div>
            <div class="slide fade">
                <img src="{{ asset('images/banner3.jpg') }}" alt="Banner 3">
            </div>
        </div>
    </section>

    <script src="{{ asset('js/script.js') }}"></script>
@endsection



