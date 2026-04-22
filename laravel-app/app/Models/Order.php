<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\OrderItem;

class Order extends Model
{
    use HasFactory;
    protected $fillable = [
        'user_id',
        'customer_name',
        'email',
        'phone',
        'address',
        'total_price',
        'status',
        'payment_method',
        'cancel_reason',
        'payment_qr_code'
    ];
    

    public function orderItems()
    {
        return $this->hasMany(OrderItem::class, 'order_id')->with('product');
    }
    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
    
    public function items()
    {
        return $this->hasMany(OrderItem::class);
    }
    public static function boot()
    {
        parent::boot();

        // Khi đơn hàng được cập nhật
        static::updating(function ($order) {
            if ($order->isDirty('status')) { // Kiểm tra nếu status thay đổi
                if ($order->status === 'completed') {
                    $order->increaseSoldQuantity();
                } elseif ($order->status === 'canceled') {
                    $order->restoreStock();
                }
            }
        });
    }
    private function increaseSoldQuantity()
    {
        foreach ($this->orderItems as $item) {
            $product = $item->product;
            if ($product) {
                $product->sold_quantity += $item->quantity;
                $product->save();
            }
        }
    }
    private function restoreStock()
    {
        foreach ($this->orderItems as $item) {
            $product = $item->product;
            if ($product) {
                $product->stock += $item->quantity;
                $product->save();
            }
        }
    }
}
