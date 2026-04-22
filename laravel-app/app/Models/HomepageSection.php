<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\Category;

class HomepageSection extends Model
{
    use HasFactory;
    protected $table = 'homepage_sections'; 
    protected $fillable = ['category_id', 'title', 'display_type'];

    public function category()
    {
        return $this->belongsTo(Category::class);
    }
    public function product()
    {
        return $this->belongsTo(Product::class);
    }
}

