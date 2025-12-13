import 'package:flutter_riverpod/legacy.dart';

/// يمثّل التاب/العنصر الحالي في الـ Bottom Navigation
/// 0 => الرئيسية
/// 1 => خدماتي
/// 2 => الملف الشخصي
final homeBottomNavIndexProvider = StateProvider<int>((ref) => 0);
