<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Product;

class OrderController extends Controller
{
    public function myOrders()
    {
        $orders = Order::where('user_id', auth()->id())->orderBy('created_at', 'desc')->get();
        return view('orders.my_orders', compact('orders'));
    }

    public function orderDetails($id)
    {
        $order = Order::where('id', $id)
            ->where('user_id', auth()->id())
            ->with('orderItems.product')
            ->firstOrFail();

        return view('orders.details', compact('order'));
    }

    public function checkout(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email',
            'phone' => 'required|string',
            'address' => 'required|string',
            'payment_method' => 'required|string'
        ]);

        $cart = session('cart', []);
        if (empty($cart)) {
            return redirect()->back()->with('error', 'Giỏ hàng trống!');
        }

        $totalPrice = array_sum(array_map(fn($item) => $item['price'] * $item['quantity'], $cart));

        // Tạo đơn hàng mới
        $order = Order::create([
            'user_id' => auth()->id(),
            'customer_name' => $request->name,
            'email' => $request->email,
            'phone' => $request->phone,
            'address' => $request->address,
            'total_price' => $totalPrice,
            'status' => 'pending',
            'payment_method' => $request->payment_method,
        ]);

        // Duyệt qua các sản phẩm trong giỏ hàng và tạo OrderItem
        foreach ($cart as $productId => $item) {
            OrderItem::create([
                'order_id' => $order->id,
                'product_id' => $productId,
                'quantity' => $item['quantity'],
                'price' => $item['price'],
            ]);
        }

        // Xóa giỏ hàng sau khi đặt hàng thành công
        session()->forget('cart');

        return redirect()->route('orders.success')->with('success', 'Đặt hàng thành công!');
    }


    public function updateOrderStatus(Request $request, $orderId)
    {
        $order = Order::findOrFail($orderId);
        $order->status = $request->status;
        $order->save(); // Model Event sẽ tự động cập nhật stock hoặc sold_quantity

        return redirect()->back()->with('success', 'Cập nhật trạng thái đơn hàng thành công.');
    }


    public function success()
    {
        return view('cart.orders.success');
    }

    public function cancelOrder(Request $request, $id)
    {
        $order = Order::where('id', $id)->where('user_id', auth()->id())->first();

        if (!$order || $order->status == 'canceled') {
            return redirect()->back()->with('error', 'Đơn hàng không hợp lệ hoặc đã bị hủy.');
        }

        $order->update([
            'status' => 'canceled',
            'cancel_reason' => $request->cancel_reason,
        ]);

        $this->restoreStockOnCancel($order);

        return redirect()->route('orders.show', $id)->with('success', 'Đơn hàng đã được hủy.');
    }
}
