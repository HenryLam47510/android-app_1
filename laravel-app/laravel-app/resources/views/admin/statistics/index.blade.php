@extends('layouts.base')

@section('content')
    <link rel="stylesheet" href="{{ asset('css/statistic.css') }}">
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

    <div class="container mt-4">
        <h2 class="text-center">📊 Bảng thống kê tổng quan</h2>
        <div class="container">
            <!-- 1️⃣ Tổng quan doanh thu và đơn hàng -->
            <div class="row my-4">
                <div class="col-md-4">
                    <div class="card text-bg-success">
                        <div class="card-body">
                            <a style="color: white;font-weight:500; text-decoration: none;font-size: 20px" href="{{ route('admin.revenue.chart', ['filter' => 'day']) }}" class="text-lg font-bold underline hover:text-gray-200">
                                📅 Doanh thu hôm nay
                            </a>
                            <p class="fs-4">{{ number_format($revenue_today, 0, ',', '.') }} VND</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card text-bg-primary">
                        <div class="card-body">
                            <a style="color: white;font-weight:500; text-decoration: none;font-size: 20px" href="{{ route('admin.revenue.chart', ['filter' => 'month']) }}" class="text-lg font-bold underline hover:text-gray-200">
                                📆 Doanh thu tháng này
                            </a>
                            <p class="fs-4">{{ number_format($revenue_month, 0, ',', '.') }} VND</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card text-bg-warning">
                        <div class="card-body">
                            <a style="color: black;font-weight:500; text-decoration: none;font-size: 20px" href="{{ route('admin.revenue.chart', ['filter' => 'year']) }}" class="text-lg font-bold underline hover:text-gray-700">
                                📊 Doanh thu năm nay
                            </a>
                            <p class="fs-4">{{ number_format($revenue_year, 0, ',', '.') }} VND</p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Tổng số đơn hàng -->
            <div class="row my-4">
                <div class="col-md-4">
                    <div class="card text-bg-info">
                        <div class="card-body">
                            <h5>📦 Tổng số đơn hàng</h5>
                            <p class="fs-4">{{ $total_orders }}</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card text-bg-success">
                        <div class="card-body">
                            <h5>✅ Số đơn hàng hoàn thành</h5>
                            <p class="fs-4">{{ $completed_orders }}</p>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card text-bg-danger">
                        <div class="card-body">
                            <h5>❌ Số đơn hàng bị hủy</h5>
                            <p class="fs-4">{{ $canceled_orders }}</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- 2️⃣ Thống kê sản phẩm -->
        <div class="container text-center">
            <h2 class="text-xl font-bold mb-4">🔥 Sản phẩm bán chạy nhất</h2>
            <table class="min-w-full border border-gray-300 mx-auto w-3/4">
                <thead>
                    <tr class="bg-gray-200">
                        <th class="border px-4 py-2">STT</th>
                        <th class="border px-4 py-2">Tên sản phẩm</th>
                        <th class="border px-4 py-2">Số lượng đã bán</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach ($best_selling_products as $index => $product)
                        <tr>
                            <td class="border px-4 py-2">{{ $index + 1 }}</td>
                            <td class="border px-4 py-2">{{ $product->name }}</td>
                            <td class="border px-4 py-2">{{ $product->sold_quantity }}</td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>

        <div class="container text-center mt-6">
            <h2 class="text-xl font-bold mb-4">⚠️ Sản phẩm sắp hết hàng</h2>
            <table class="min-w-full border border-gray-300 mx-auto w-3/4">
                <thead>
                    <tr class="bg-gray-200">
                        <th class="border px-4 py-2">STT</th>
                        <th class="border px-4 py-2">Tên sản phẩm</th>
                        <th class="border px-4 py-2">Số lượng còn lại</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach ($low_stock_products as $index => $product)
                        <tr>
                            <td class="border px-4 py-2">{{ $index + 1 }}</td>
                            <td class="border px-4 py-2">{{ $product->name }}</td>
                            <td class="border px-4 py-2">{{ $product->stock }}</td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>

        <!-- 3️⃣ Thống kê khách hàng -->
    <div class="container">
        <h3>👥 Tổng số khách hàng: {{ $total_customers }}</h3>
    </div>

    <div class="container mx-auto flex justify-center">
        <div class="w-full max-w-4xl">
            <h2 class="text-2xl font-bold mb-4 flex items-center">
                <span class="mr-2">👤</span> Khách hàng mua nhiều nhất
            </h2>
            <div class="overflow-x-auto">
                <table class="w-full border border-gray-300 mx-auto text-center">
                    <thead>
                        <tr class="bg-gray-200">
                            <th class="border px-4 py-2">STT</th>
                            <th class="border px-4 py-2">Họ tên</th>
                            <th class="border px-4 py-2">Username</th>
                            <th class="border px-4 py-2">Số đơn hàng</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach ($top_customers as $index => $customer)
                            <tr class="hover:bg-gray-100">
                                <td class="border px-4 py-2">{{ $index + 1 }}</td>
                                <td class="border px-4 py-2">{{ $customer->full_name }}</td>
                                <td class="border px-4 py-2">{{ $customer->username }}</td>
                                <td class="border px-4 py-2">{{ $customer->total_orders }}</td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    
    


    </div>
@endsection