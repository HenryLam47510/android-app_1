<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Product;

class CartController extends Controller
{
    public function viewCart()
    {
        $cart = session()->get('cart', []);
    
        if (empty($cart)) {
            return view('cart.view')->with('cart', [])->with('cartItemCount', 0);
        }
    
        $cartItemCount = count($cart); // Đếm số loại sản phẩm
        session()->put('cart_item_count', $cartItemCount);
        return view('cart.view', compact('cart', 'cartItemCount'));
        
    }

    public function addToCart(Request $request)
    {
        $productId = $request->id;
        $product = Product::find($productId);
    
        if (!$product) {
            return response()->json(['message' => 'Sản phẩm không tồn tại'], 404);
        }
    
        $cart = session()->get('cart', []);
    
        if (!isset($cart[$productId])) {
            $cart[$productId] = [
                "id" => $product->id, 
                "name" => $product->name,
                "price" => $product->price,
                "image_url" => $product->image_url,
                "quantity" => 1,
                "stock" => $product->stock
            ];
        } else {
            if ($cart[$productId]["quantity"] < $product->stock) {
                $cart[$productId]["quantity"]++;
            }
        }
    
        session()->put('cart', $cart);
        session()->put('cart_item_count', count($cart));
    
        return response()->json([
            'message' => 'Đã thêm vào giỏ hàng!',
            'cart_count' => array_sum(array_column($cart, 'quantity'))
        ]);
    }
    

    public function update(Request $request)
    {
        $cart = session()->get('cart', []);
        $id = $request->id;
        $quantity = (int) $request->quantity;
    
        if (isset($cart[$id])) {
            $stock = $cart[$id]['stock'];
            if ($quantity > $stock) {
                return response()->json(['error' => 'Vượt quá số lượng tồn kho!'], 400);
            }
            $cart[$id]['quantity'] = $quantity;
            session()->put('cart', $cart);
            session()->put('cart_item_count', count($cart));
            
        }
    
        return response()->json(['success' => true]);
    }
    

    public function remove(Request $request)
    {
        $cart = session()->get('cart', []);
    
        if (isset($cart[$request->id])) {
            unset($cart[$request->id]);
            session()->put('cart', $cart);
            session()->put('cart_item_count', count($cart));
        
            return response()->json([
                'success' => true,
                'cart_count' => count($cart)
            ]);
        }

    
        return response()->json(['success' => false]);
    }
    

    public function getCartCount()
    {
        $cart = session()->get('cart', []);
        $count = array_sum(array_column($cart, 'quantity'));

        session(['cart_item_count' => $count]);

        return response()->json(['count' => $count]);
    }
}
