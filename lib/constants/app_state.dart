import 'package:flutter/material.dart';
import '/features/profile/user.dart';

// Quản lý trạng thái Theme toàn cục
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

// Quản lý trạng thái Đăng nhập giả lập
final ValueNotifier<bool> isLoggedInNotifier = ValueNotifier(false);

// Quản lý thông tin người dùng hiện tại
final ValueNotifier<User> currentUserNotifier = ValueNotifier(
  User(
    name: "Nguyễn Văn A",
    email: "admin@gmail.com",
    avatar: "https://ui-avatars.com/api/?name=Nguyen+Van+A",
  ),
);
