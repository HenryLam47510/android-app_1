<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\HomeController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\CheckoutController;
use App\Http\Controllers\Admin\UserController;
use App\Http\Controllers\Auth\ForgotPasswordController;
use App\Http\Controllers\Auth\ResetPasswordController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\CartController;
use App\Http\Controllers\OrderController;
use App\Http\Controllers\Admin\OrderController as AdminOrderController;
use App\Http\Controllers\Admin\StatisticsController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\ReviewController;


/*------------------forget and reset password-------------------*/
Route::get('forgot-password', [ForgotPasswordController::class, 'showLinkRequestForm'])->name('password.request');
Route::post('forgot-password', [ForgotPasswordController::class, 'sendResetLinkEmail'])->name('password.email');

Route::get('reset-password/{token}', [ResetPasswordController::class, 'showResetForm'])->name('password.reset');
Route::post('reset-password', [ResetPasswordController::class, 'reset'])->name('password.update');


/*-------------- Login & Register --------------*/
Route::get('/login', [AuthController::class, 'showLoginForm'])->name('login');
Route::post('/login', [AuthController::class, 'login']);

Route::get('/register', [AuthController::class, 'showRegisterForm'])->name('register');
Route::post('/register', [AuthController::class, 'register']);

Route::post('/logout', [AuthController::class, 'logout'])->name('logout');

/*-------------- Home & Category --------------*/
Route::get('/', [HomeController::class, 'index'])->name('home');
Route::get('/home', [HomeController::class, 'index'])->name('home.index');
Route::get('/category/{category}', [CategoryController::class, 'view'])->name('category.view');
Route::get('/products/search', [ProductController::class, 'search'])->name('products.search');


/*-------------- Route yêu cầu đăng nhập --------------*/
Route::middleware(['auth'])->group(function () {

    // Trang hóa đơn của user
    Route::get('/my-orders', [OrderController::class, 'myOrders'])->name('orders.my_orders')->middleware('auth');
    Route::get('/order/{id}', [OrderController::class, 'orderDetails'])->name('orders.details')->middleware('auth');
    Route::put('/orders/{id}/cancel', [OrderController::class, 'cancelOrder'])->name('orders.cancel');


    //route xử lí giỏ hàng 
    Route::post('/cart/add', [CartController::class, 'addToCart'])->name('cart.add');
    Route::get('/cart/count', [CartController::class, 'getCartCount'])->name('cart.count');
    Route::post('/cart/remove', [CartController::class, 'remove'])->name('cart.remove');
    Route::post('/cart/update',[CartController::class,'update'])->name('cart.update');


    // 🛠 Route nhóm Admin
    Route::middleware(['admin'])->prefix('admin')->group(function () {

        //  route chính 
        Route::get('/', function () {
            return view('admin.dashboard'); 
        })->name('admin.dashboard');

        // 🛍 Quản lý sản phẩm (trong nhóm admin)
        Route::get('/products', [ProductController::class, 'index'])->name('admin.products');
        Route::get('/create', [ProductController::class, 'create'])->name('admin.products.create');
        Route::post('/store', [ProductController::class, 'store'])->name('admin.products.store');
        Route::get('/edit/{id}', [ProductController::class, 'edit'])->name('admin.products.edit');
        Route::put('product/update/{id}', [ProductController::class, 'update'])->name('admin.products.update');
        Route::delete('/delete/{id}', [ProductController::class, 'destroy'])->name('admin.products.destroy');
        Route::get('/products/search', [ProductController::class, 'search'])->name('products.search');

        // 👥 Quản lý người dùng
        Route::get('/users', function () {
            return view('admin.users'); 
        })->name('admin.users');

        // 📦 Quản lý đơn hàng
        Route::get('/admin/orders', [AdminOrderController::class, 'index'])->name('admin.orders.index');
        Route::get('/admin/orders/{order}', [AdminOrderController::class, 'show'])->name('admin.orders.show');
        Route::post('/admin/orders/{order}/update-status', [AdminOrderController::class, 'updateStatus'])->name('admin.orders.updateStatus');
        
        // 📊 Thống kê
        Route::prefix('/statistics')->group(function () {
            Route::get('/', [StatisticsController::class, 'index'])->name('admin.statistics.index');
            Route::get('/revenue-chart', [StatisticsController::class, 'showRevenueChart'])->name('admin.revenue.chart');
            Route::get('/revenue-data', [StatisticsController::class, 'revenueDetails'])->name('admin.revenue.data');
        });
        // 🗂 Quản lý danh mục
        Route::get('/categories', [CategoryController::class, 'index'])->name('admin.categories');
        Route::post('/categories', [CategoryController::class, 'store'])->name('categories.store');
        Route::put('/categories/{category}', [CategoryController::class, 'update'])->name('categories.update');
        Route::delete('/categories/{category}', [CategoryController::class, 'destroy'])->name('categories.destroy');
        Route::get('/category/{slug}', [ProductController::class, 'showCategory'])->name('category.show');
        Route::get('/category/{slug}/load-more', [ProductController::class, 'loadMoreProducts'])->name('category.loadMore');
        
        // Quản Lý User
        Route::get('/users', [UserController::class, 'index'])->name('admin.users');
        Route::post('/users/{id}/set-role', [UserController::class, 'setRole'])->name('admin.users.setRole');
        Route::delete('/users/{id}', [UserController::class, 'destroy'])->name('admin.users.destroy');
    
    });

    //route Sản phẩm ->user 
    Route::get('/product/{id}', [ProductController::class, 'show'])->name('product.view');
    Route::get('/admin/product/{id}', [ProductController::class, 'show'])->name('admin.view.detail-product');
    Route::get('/category/{slug}', [ProductController::class, 'showByCategory'])->name('category.view');

    //route đánh giá -> user
    Route::post('/products/{product}/review', [ReviewController::class, 'store'])->middleware('auth');
    Route::post('/reviews/{review}/reply', [ReviewController::class, 'addReply'])->middleware('auth');





    // 🛒 Xem giỏ hàng
    Route::get('/cart', function () {
        return view('cart.view'); 
    })->name('cart.view');
    Route::get('/cart/count', function () {
        return response()->json(['cart_count' => session('cart_item_count', 0)]);
    })->name('cart.count');
    Route::post('/checkout', [OrderController::class, 'checkout'])->name('checkout.process');


    
//Route Thanh toán 
Route::get('/checkout', [CheckoutController::class, 'index'])->name('checkout');
Route::get('/checkout/success', [OrderController::class, 'success'])->name('orders.success');


});
