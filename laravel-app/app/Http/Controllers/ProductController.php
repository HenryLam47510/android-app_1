<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\Auth;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use App\Models\Product;
use App\Models\Category;

class ProductController extends Controller
{
    public function index()
    {
        $categories = Category::all(); // Lấy danh sách danh mục từ database
        $products = Product::all(); // Lấy danh sách sản phẩm (tuỳ chỉnh nếu cần)
        return view('admin.products', compact('categories', 'products'));
    }

    public function create()
    {
        $categories = Category::all();
        return view('admin.products.create', compact('categories'));
    }

    public function show($id)
    {
        $product = Product::findOrFail($id);
        $product = Product::findOrFail($id);


        // Lấy 4 sản phẩm cùng danh mục, loại trừ sản phẩm hiện tại
        $relatedProducts = Product::where('category_id', $product->category_id)
            ->where('id', '!=', $id)
            ->inRandomOrder()
            ->limit(4)
            ->get();
        $product = Product::with(['reviews.user'])->findOrFail($id);
        // Tính trung bình rating
        $avgRating = $product->reviews->avg('rating') ?? 0;
        return view('admin.view.detail-product', compact('product', 'relatedProducts', 'avgRating'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required',
            'price' => 'required|numeric',
            'stock' => 'required|integer',
            'category_id' => 'required',
            'image_url' => 'nullable|url',
        ]);

        Product::create($request->all());
        return back()->with('success', 'Sản phẩm đã được thêm.');
    }

    public function edit($id)
    {
        $product = Product::findOrFail($id);
        $categories = Category::all();
        return view('admin.products.edit', compact('product', 'categories'));
    }

    public function update(Request $request, $id)
    {
        Log::info('Session ID trước khi update: ' . session()->getId());
        Log::info('User trước khi update: ', ['user' => auth()->user()]);
        $request->validate([
            'name' => 'required|string|max:255',
            'price' => 'required|numeric|min:0',
            'stock' => 'required|integer|min:0',
            'category_id' => 'required|exists:categories,id',
            'image_url' => 'nullable|string|url' // Cho phép null
        ]);

        $product = Product::findOrFail($id);
        $product->name = $request->name;
        $product->price = $request->price;
        $product->stock = $request->stock;
        $product->category_id = $request->category_id;

        // Nếu image_url bị xóa -> đặt về null (xóa ảnh)
        if ($request->filled('image_url')) {
            $product->image_url = $request->image_url;
        }

        $product->save();
        Log::info('Session ID sau khi update: ' . session()->getId());
        Log::info('User sau khi update: ', ['user' => auth()->user()]);

        return back()->with('success', 'Sản phẩm đã được cập nhật.');
    }

    public function destroy($id)
    {
        Product::findOrFail($id)->delete();
        return back()->with('success', 'Sản phẩm đã được xóa.');
    }

    public function showByCategory($slug)
    {
        $category = Category::where('slug', $slug)->firstOrFail();
        $products = Product::where('category_id', $category->id)->take(9)->get();
        return view('products.by_category', compact('category', 'products'));
    }
    public function search(Request $request)
    {
        $keyword = $request->query('q'); // Lấy từ khóa tìm kiếm từ URL (?q=...)

        if (!$keyword) {
            return redirect()->route('products.index')->with('error', 'Vui lòng nhập từ khóa tìm kiếm');
        }

        // Tìm kiếm theo tên hoặc mô tả (có thể thêm điều kiện khác)
        $products = Product::where('name', 'LIKE', "%{$keyword}%")
            ->orWhere('category_id', 'LIKE', "%{$keyword}%")
            ->get();

        return view('layouts.search_results', compact('products', 'keyword'));
    }
    //Filter 
    public function filter(Request $request)
    {
        $query = Product::query();

        // Lọc theo danh mục
        if ($request->category_id) {
            $query->where('category_id', $request->category_id);
        }

        // Lọc theo số lượng tồn kho
        if ($request->stock) {
            if ($request->stock === 'low') {
                $query->where('stock', '<', 10); // Còn ít (dưới 10 sản phẩm)
            } elseif ($request->stock === 'high') {
                $query->where('stock', '>=', 10); // Còn nhiều (từ 10 sản phẩm trở lên)
            }
        }

        $products = $query->get();

        return response()->json(['products' => $products]);
    }


}
