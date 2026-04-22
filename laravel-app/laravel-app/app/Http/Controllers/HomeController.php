<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Product;
use App\Models\Category;
use Illuminate\Support\Facades\Auth;


class HomeController extends Controller
{
    public function index()
    {   

        $user = Auth::user();
        $categories = Category::all(); // Lấy toàn bộ danh mục từ database
        return view('home.index', compact('categories'));
    }

    // Hiển thị danh mục sản phẩm
    public function viewCategory($category)
    {
        $categoryData = Category::where('name', $category)->first();
        
        if (!$categoryData) {
            return redirect()->route('home.index')->with('error', 'Danh mục không tồn tại!');
        }

        $products = Product::where('category_id', $categoryData->id)->get();
        return view('home.category', compact('categoryData', 'products'));
    }
}
