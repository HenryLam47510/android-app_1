import 'package:flutter/material.dart';

// Quản lý trạng thái Theme toàn cục
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

// Quản lý trạng thái Đăng nhập giả lập
final ValueNotifier<bool> isLoggedInNotifier = ValueNotifier(false);
