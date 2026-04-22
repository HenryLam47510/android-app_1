<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Http;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/
use App\Http\Controllers\UserController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\CartController;
use App\Http\Controllers\OrderController;
use App\Http\Controllers\Admin\StatisticsController;

Route::apiResource('users', UserController::class);
Route::apiResource('products', ProductController::class);
Route::apiResource('categories', CategoryController::class);
Route::apiResource('cart', CartController::class);
Route::apiResource('orders', OrderController::class);
Route::get('statistics', [StatisticController::class, 'index']);



Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});


Route::get('/transactions', function (Request $request) {
    $accountNumber = '0898574187';
    $limit = 20;
    $bearerToken = 'VP76PYCSDGHNL1WQAOB9F9WVNWE43HPB2JO7XJD5L4AFSNCJBGA2ZXE88HYLNMXR'; 

    $response = Http::withHeaders([
        'Authorization' => "Bearer $bearerToken",
        'Content-Type' => 'application/json',
    ])->get("https://my.sepay.vn/userapi/transactions/list", [
        'account_number' => $accountNumber,
        'limit' => $limit
    ]);

    return $response->json();
});