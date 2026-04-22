<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Product;
use App\Models\Category;
use Illuminate\Support\Facades\Auth;
use App\Models\HomepageSection;

class HomeController extends Controller
{
    public function index()
    {   
        $user = Auth::user();
        $categories = Category::all(); // Lấy toàn bộ danh mục
        $salesSections = HomepageSection::with('category')->get();
        $sections = [];

        foreach ($salesSections as $section) {
            $products = collect();
            if ($section->display_type == 'latest') {
                $products = Product::where('category_id', $section->category_id)
                    ->orderBy('created_at', 'desc')
                    ->take(4)
                    ->get();
            } elseif ($section->display_type == 'bestseller') {
                $products = Product::where('category_id', $section->category_id)
                    ->orderBy('sold_quantity', 'desc')
                    ->take(4)
                    ->get();
            }

            $sections[] = [
                'title' => $section->title,
                'products' => $products,
            ];
        }


        return view('home.index', compact('categories', 'sections'));
    }
    public function manageSections()
    {
        $sales = HomepageSection::with('category')->get();
        $categories = Category::all();
        return view('admin.sales.index', compact('sales', 'categories'));
    }

    public function storeSection(Request $request)
    {
        $request->validate([
            'category_id' => 'required|exists:categories,id',
            'title' => 'required|string|max:255',
            'display_type' => 'required|in:latest,bestseller',
        ]);

        HomepageSection::updateOrCreate(
            ['category_id' => $request->category_id],
            ['title' => $request->title, 'display_type' => $request->display_type]
        );

        return redirect()->route('admin.sales')->with('success', 'Cập nhật thành công!');
    }

    public function destroySection($id)
    {
        HomepageSection::findOrFail($id)->delete();
        return redirect()->route('admin.sales')->with('success', 'Xóa thành công!');
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
