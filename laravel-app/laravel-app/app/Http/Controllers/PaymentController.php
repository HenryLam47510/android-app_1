<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Services\SePayService;
use App\Models\Order;
use Illuminate\Support\Facades\Log;

class PaymentController extends Controller
{
    protected $sePayService;

    public function __construct(SePayService $sePayService)
    {
        $this->sePayService = $sePayService;
    }

    public function process(Request $request)
    {
        $order = Order::where('user_id', auth()->id())->latest()->first();

        if (!$order) {
            return redirect()->back()->with('error', 'Không tìm thấy đơn hàng.');
        }

        if ($order->payment_method === 'COD') {
            return redirect()->route('payment.success');
        }

        // Gọi API SePay để lấy QR Code
        $returnUrl = route('payment.success');
        $paymentResponse = $this->sePayService->createPayment($order->id, $order->total_price, $returnUrl);

        // Ghi log phản hồi từ SePay để debug
        Log::info('SePay API Response: ', $paymentResponse);

        if (!is_array($paymentResponse) || !isset($paymentResponse['status']) || $paymentResponse['status'] !== 'success') {
            return back()->with('error', 'Lỗi kết nối cổng thanh toán: ' . ($paymentResponse['message'] ?? 'Không rõ lỗi.'));
        }

        // Lưu mã QR Code vào order để hiển thị sau này
        $order->update([
            'status' => 'waiting_payment',
            'payment_qr_code' => $paymentResponse['qr_code'] ?? null, // Lưu mã QR nếu có
        ]);

        return redirect()->route('payment.qr', ['orderId' => $order->id])->with('success', 'Hãy quét mã QR để thanh toán!');
    }

    public function showQr($orderId)
    {
        $order = Order::where('id', $orderId)->firstOrFail();

        if (!$order->payment_qr_code) {
            return redirect()->route('orders.my_orders')->with('error', 'Mã QR không khả dụng.');
        }

        return view('payment.qr', compact('order'));
    }

    public function confirmPayment(Request $request)
    {
        $orderId = $request->order_id;
        $order = Order::where('id', $orderId)->first();

        if (!$order || $order->status !== 'waiting_payment') {
            return response()->json(['message' => 'Đơn hàng không hợp lệ hoặc đã thanh toán.'], 400);
        }

        // Cập nhật trạng thái đơn hàng sau khi thanh toán thành công
        $order->update(['status' => 'completed']);

        return response()->json(['message' => 'Thanh toán thành công']);
    }

    public function success()
    {
        return redirect()->route('orders.success')->with('success', 'Đặt hàng thành công!');
    }
}
