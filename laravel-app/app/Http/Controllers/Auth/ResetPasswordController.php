<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;
use Illuminate\Support\Facades\DB;
use App\Models\User;

class ResetPasswordController extends Controller
{
    /**
     * Hiển thị form nhập mật khẩu mới
     */
    public function showResetForm($token)
    {
        return view('auth.reset-password', ['token' => $token]);
    }

    /**
     * Xử lý yêu cầu đặt lại mật khẩu
     */
    public function reset(Request $request)
    {
        $request->validate([
            'email' => 'required|email|exists:users,email',
            'password' => 'required|confirmed',
            'token' => 'required'
        ]);

        // Tìm token trong bảng password_resets
        $reset = DB::table('password_resets')
            ->where('email', $request->email)
            ->first();

        // Kiểm tra token có hợp lệ không***
        if (!$reset || !Hash::check($request->token, $reset->token)) {
            return back()->withErrors(['email' => 'Token không hợp lệ hoặc đã hết hạn!']);
        }

        // Cập nhật mật khẩu mới cho user
        $user = User::where('email', $request->email)->first();
        if ($user) {
            $user->password = Hash::make($request->password);
            $user->save();

            // Xóa token sau khi sử dụng
            DB::table('password_resets')->where('email', $request->email)->delete();

            return redirect()->route('login')->with('status', 'Mật khẩu của bạn đã được đặt lại thành công!');
        }

        return back()->withErrors(['email' => 'Không tìm thấy người dùng!']);
    }
}
