<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Order;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class OrderController extends Controller
{
    public function index(Request $request)
    {
        $date = $request->query('date', now()->toDateString());
            
        $orders = Order::whereDate('created_at', $date)->orderBy('created_at', 'desc')->get();
        $ordersByDate = $orders->groupBy(fn($order) => $order->created_at->toDateString());
    
        return view('admin.orders.index', compact('ordersByDate', 'date'));
    }
    

    public function show($id)
    {
        $order = Order::with('items.product')->find($id);
    
        if (!$order) {
            return redirect()->route('admin.orders.index')->with('error', 'Đơn hàng không tồn tại.');
        }
    
        return view('admin.orders.show', compact('order'));
    }
    

    public function updateStatus(Request $request, $id)
    {
        $order = Order::find($id);
        
        if (!$order) {
            return redirect()->route('admin.orders.index')->with('error', 'Đơn hàng không tồn tại.');
        }
    
        // Cập nhật trạng thái
        $order->status = $request->status;
    
        // Nếu chọn "Hủy", lưu lý do hủy
        if ($request->status == 'canceled') {
            $order->cancel_reason = $request->cancel_reason ?? 'Không có lý do';
        } else {
            $order->cancel_reason = null; // Xóa lý do nếu không phải trạng thái hủy
        }
    
        $order->save();
    
        return redirect()->back()->with('success', 'Cập nhật trạng thái thành công!');
    }
    
}
