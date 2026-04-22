<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PasswordReset extends Model
{
    protected $table = 'password_resets'; // Đặt lại tên bảng
    public $timestamps = false; // Không có cột updated_at, created_at
}
