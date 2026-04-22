<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\ReviewReply;
use  App\Models\Review;
use Illuminate\Support\Facades\Auth;

class ReviewController extends Controller
{
    public function store(Request $request, $productId)
    {
        $request->validate([
            'rating' => 'required|integer|min:1|max:5',
            'comment' => 'required|string',
        ]);

        Review::create([
            'user_id' => auth()->id(),
            'product_id' => $productId,
            'rating' => $request->rating,
            'comment' => $request->comment,
        ]);

        return redirect()->back()->with('success', 'Cảm ơn bạn đã đánh giá sản phẩm!');

    }
    public function addReply(Request $request, $reviewId)
    {
        $request->validate([
            'reply_content' => 'required|string|max:500',
        ]);
    
        $reply = new ReviewReply();
        $reply->review_id = $reviewId;
        $reply->user_id = auth()->id();
        $reply->reply_content = $request->reply_content; // Đổi từ 'comment' thành 'reply_content'
        $reply->save();
    
        return back()->with('success', 'Phản hồi đã được thêm.');
    }
    public function showReviews($productId)
    {
        $reviews = Review::with('user', 'replies.user')
            ->where('product_id', $productId)
            ->get();

        return view('products.reviews', compact('reviews'));
    }
    
}

