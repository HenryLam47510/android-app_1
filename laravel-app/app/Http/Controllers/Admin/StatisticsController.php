<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Carbon\Carbon;
use App\Models\Order;
use App\Models\Product;
use App\Models\User;
use Illuminate\Support\Facades\DB;

class StatisticsController extends Controller
{
    // Trang thống kê
    public function index(Request $request)
    {
        $today = Carbon::today();
        $month = $request->input('month', Carbon::now()->month);
        $year = $request->input('year', Carbon::now()->year);

        // Doanh thu
        $revenue_today = Order::whereDate('created_at', $today)->where('status', 'completed')->sum('total_price');
        $revenue_month = Order::whereMonth('created_at', $month)->whereYear('created_at', $year)->where('status', 'completed')->sum('total_price');
        $revenue_year = Order::whereYear('created_at', $year)->where('status', 'completed')->sum('total_price');

        // Đơn hàng
        $total_orders = Order::whereMonth('created_at', $month)->whereYear('created_at', $year)->count();
        $completed_orders = Order::whereMonth('created_at', $month)->whereYear('created_at', $year)->where('status', 'completed')->count();
        $canceled_orders = Order::whereMonth('created_at', $month)->whereYear('created_at', $year)->where('status', 'canceled')->count();

        // 🔥 Sản phẩm bán chạy nhất
        $best_selling_products = Product::orderByDesc('sold_quantity')->take(5)->get();

        // ⚠️ Sản phẩm sắp hết hàng
        $low_stock_products = Product::where('stock', '<', 10)->orderBy('stock')->take(5)->get();

        // 👥 Tổng số khách hàng
        $total_customers = User::where('role', 'customer')->count();

        // 🛒 Khách hàng mua nhiều nhất (dựa vào tổng giá trị đơn hàng)
        $top_customers = User::select(
            'users.id',
            'users.full_name',
            'users.username',
            DB::raw('COUNT(orders.id) as total_orders')
        )
            ->join('orders', 'users.id', '=', 'orders.user_id')
            ->where('orders.status', 'completed')
            ->groupBy('users.id', 'users.full_name', 'users.username')
            ->orderByDesc('total_orders')
            ->limit(10)
            ->get();



        return view('admin.statistics.index', compact(
            'revenue_today',
            'revenue_month',
            'revenue_year',
            'total_orders',
            'completed_orders',
            'canceled_orders',
            'best_selling_products',
            'low_stock_products',
            'total_customers',
            'top_customers',
            'month',
            'year'
        ));
    }

    public function revenueDetails(Request $request)
    {
        $filter = $request->query('filter', 'day'); // Mặc định lọc theo ngày

        if ($filter == 'day') {
            $revenues = Order::where('status', 'completed')
                ->selectRaw('DATE(created_at) as label, SUM(total_price) as revenue')
                ->groupBy('label')
                ->orderBy('label', 'ASC')
                ->get();
        } elseif ($filter == 'month') {
            $revenues = Order::where('status', 'completed')
                ->selectRaw('YEAR(created_at) as year, MONTH(created_at) as label, SUM(total_price) as revenue')
                ->groupBy('year', 'label')
                ->orderBy('year', 'ASC')
                ->orderBy('label', 'ASC')
                ->get();
        } else {
            $revenues = Order::where('status', 'completed')
                ->selectRaw('YEAR(created_at) as label, SUM(total_price) as revenue')
                ->groupBy('label')
                ->orderBy('label', 'ASC')
                ->get();
        }

        return response()->json($revenues);
    }

    public function showRevenueChart(Request $request)
    {
        $filter = $request->query('filter', 'day'); // Lấy loại biểu đồ (ngày/tháng/năm)
        return view('admin.statistics.revenue_chart', compact('filter'));
    }

}
