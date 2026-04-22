<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class OrderItem extends Model
{
    use HasFactory;

    protected $fillable = ['order_id', 'product_id', 'quantity', 'price'];

    public function order()
    {
        return $this->belongsTo(Order::class);
    }
    public function product()
    {
        return $this->belongsTo(Product::class, 'product_id');
    }
    public static function boot()
    {
        parent::boot();

        static::creating(function ($orderItem) {
            $product = Product::find($orderItem->product_id);
            if ($product) {
                $product->stock -= $orderItem->quantity;
                $product->save();
            }
        });
    }
}

