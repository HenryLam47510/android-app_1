<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Statistic extends Model
{
    use HasFactory;
    protected $table = 'statistics';
    protected $fillable = [
        'report_date',
        'report_month',
        'report_year',
        'total_revenue',
        'total_orders',
        'completed_orders',
        'canceled_orders',
        'total_products_sold',
    ];
        // Tắt timestamps nếu không sử dụng Laravel timestamps mặc định
        public $timestamps = true;
}
