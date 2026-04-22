<?php

namespace App\Http\Controllers;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{

    public function showLoginForm()
    {
        return view('auth.login'); 
    }

    public function showRegisterForm()
    {
        return view('auth.register'); 
    }

    public function register(Request $request)
    {
        $request->validate([
            'full_name' => 'required|max:255',
            'username' => 'required|unique:users|max:255',
            'email' => 'required|email|unique:users|max:255',
            'password' => 'required',
        ]);

        User::create([
            'full_name' => $request->full_name,
            'username' => $request->username,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'role' => 'customer',  // Mặc định user mới đăng ký là khách hàng
        ]);

        return redirect()->route('login')->with('success', 'Đăng ký thành công! Hãy đăng nhập.');
    }
    public function login(Request $request)
    {
        $credentials = $request->validate([
            'username' => 'required', 
            'password' => 'required',
        ]);

        if (Auth::attempt($credentials)) {
            return redirect()->route('home.index');
        }

        return back()->with('error', 'Tên đăng nhập hoặc mật khẩu không chính xác');
    }
        public function logout()
    {
        Auth::logout();
        return redirect()->route('login');
    }

}
