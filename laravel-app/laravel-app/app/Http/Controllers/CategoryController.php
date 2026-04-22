<?php

namespace App\Http\Controllers;

use App\Models\Category;
use Illuminate\Http\Request;
use App\Models\Product;

class CategoryController extends Controller
{
    public function index() {
        $categories = Category::all();
        return view('admin.categories', compact('categories'));
    }

    public function store(Request $request) {
        $request->validate(['name' => 'required|unique:categories']);
        Category::create(['name' => $request->name]);
        return redirect()->route('admin.categories')->with('success', 'Danh mục đã được thêm thành công!');
    }

    public function update(Request $request, Category $category)
    {
        $request->validate(['name' => 'required|unique:categories,name,' . $category->id]);
        $category->update(['name' => $request->name]);
        return redirect()->route('admin.categories')->with('success', 'Danh mục đã được cập nhật!');
    }

    public function destroy(Category $category)
    {
        $category->delete();
        return redirect()->route('admin.categories')->with('success', 'Danh mục đã được xóa!');
    }
    public function view($slug)
    {
        // Tìm danh mục theo slug
        $category = Category::where('slug', $slug)->firstOrFail();
    
        // Lấy danh sách sản phẩm thuộc danh mục này
        $products = Product::where('category_id', $category->id)->paginate(10);
    
        // Trả về view hiển thị sản phẩm
        return view('admin.view.category', compact('category', 'products'));
    }
}
