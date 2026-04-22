@extends('layouts.base')

@section('content')
<link rel="stylesheet" href="{{ asset('css/statistic.css') }}">
<!-- Bootstrap CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<!-- jQuery -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<div class="container mt-5">
    <a href="{{ route('admin.statistics.index') }}" class="btn btn-warning">Quay lại</a>
    <h2 class="text-center">📊 Biểu đồ Doanh thu</h2>

    <div class="text-center mb-3">
        <select id="filter-select" class="form-select w-auto mx-auto">
            <option value="day" {{ $filter == 'day' ? 'selected' : '' }}>Doanh thu theo ngày</option>
            <option value="month" {{ $filter == 'month' ? 'selected' : '' }}>Doanh thu theo tháng</option>
            <option value="year" {{ $filter == 'year' ? 'selected' : '' }}>Doanh thu theo năm</option>
        </select>
    </div>

    <div style="width: 100%; overflow-x: auto;">
        <canvas id="revenueChart" style="min-width: 1200px; height: 300px;"></canvas>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
document.addEventListener("DOMContentLoaded", function() {
    let filter = "{{ $filter }}";
    let ctx = document.getElementById('revenueChart').getContext('2d');
    let revenueChart;

    function loadChartData(filter) {
        fetch(`/admin/statistics/revenue-data?filter=${filter}`)
            .then(response => response.json())
            .then(data => {
                let labels = data.map(item => item.label);
                let revenues = data.map(item => item.revenue);

                if (revenueChart) revenueChart.destroy(); // Xóa biểu đồ cũ nếu có

                revenueChart = new Chart(ctx, {
                    type: 'bar',
                    data: {
                        labels: labels,
                        datasets: [{
                            label: 'Doanh thu (VND)',
                            data: revenues,
                            backgroundColor: 'rgba(54, 162, 235, 0.5)',
                            borderColor: 'rgba(54, 162, 235, 1)',
                            borderWidth: 1
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false, // Cho phép cuộn ngang
                        scales: {
                            x: {
                                ticks: {
                                    autoSkip: false, // Không tự động ẩn nhãn
                                    maxRotation: 45, // Giảm góc xoay nhãn để dễ đọc
                                    minRotation: 0
                                }
                            },
                            y: { beginAtZero: true }
                        },
                        plugins: {
                            legend: { display: true },
                            zoom: {
                                pan: {
                                    enabled: true,
                                    mode: "x", // Chỉ cuộn theo trục X
                                },
                                zoom: {
                                    enabled: true,
                                    mode: "x",
                                    speed: 0.1
                                }
                            }
                        }
                    }
                });
            });
    }

    document.getElementById('filter-select').addEventListener('change', function() {
        let selectedFilter = this.value;
        window.location.href = `/admin/statistics/revenue-chart?filter=${selectedFilter}`;
    });

    loadChartData(filter);
});

</script>
@endsection
