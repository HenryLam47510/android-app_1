<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;

class UserController extends Controller
{
    // Hiển thị danh sách tài khoản
    public function index()
    {
        $users = User::all();
        return view('admin.users', compact('users'));
    }

    // Cập nhật quyền (admin, customer)
    public function setRole(Request $request, $id)
    {
        $user = User::findOrFail($id);
        $request->validate([
            'role' => 'required|in:admin,customer',
        ]);

        $user->role = $request->role;
        $user->save();

        return back()->with('success', 'Cập nhật quyền thành công!');
    }

    // Xóa tài khoản
    public function destroy($id)
    {
        $user = User::findOrFail($id);
        $user->delete();

        return back()->with('success', 'Tài khoản đã bị xóa!');
    }
}
