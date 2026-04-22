<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Product;
use App\Models\Category;

class ProductController extends Controller
{
    public function index() {
        $categories = Category::all(); // Lấy danh sách danh mục từ database
        $products = Product::all(); // Lấy danh sách sản phẩm (tuỳ chỉnh nếu cần)
        return view('admin.products', compact('categories', 'products'));
    }
    
    public function create()
    {
        $categories = Category::all();
        return view('admin.products.create', compact('categories'));
    }
    
    public function show($id) {
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
        return view('admin.view.detail-product', compact('product','relatedProducts','avgRating'));
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
        return redirect()->route('products.index')->with('success', 'Sản phẩm đã được thêm.');
    }

    public function edit($id)
    {
        $product = Product::findOrFail($id);
        $categories = Category::all();
        return view('admin.products.edit', compact('product', 'categories'));
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'price' => 'required|numeric|min:0',
            'stock' => 'required|integer|min:0',
            'category_id' => 'required|exists:categories,id',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048'
        ]);
    
        $product = Product::findOrFail($id);
        $product->name = $request->name;
        $product->price = $request->price;
        $product->stock = $request->stock;
        $product->category_id = $request->category_id;
    
        // Xử lý ảnh mới
        if ($request->hasFile('image')) {
            $image = $request->file('image');
            $imageName = time().'.'.$image->getClientOriginalExtension();
            $imagePath = 'uploads/products/'.$imageName;
            $image->move(public_path('uploads/products'), $imageName);
            
            // Xóa ảnh cũ nếu có
            if ($product->image_url && file_exists(public_path($product->image_url))) {
                unlink(public_path($product->image_url));
            }
    
            // Lưu đường dẫn ảnh mới vào database
            $product->image_url = $imagePath;
        }
    
        $product->save();
    
        return redirect()->route('products.index')->with('success', 'Cập nhật sản phẩm thành công!');
    }
    

    public function destroy($id)
    {
        Product::findOrFail($id)->delete();
        return redirect()->route('products.index')->with('success', 'Sản phẩm đã được xóa.');
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

}
