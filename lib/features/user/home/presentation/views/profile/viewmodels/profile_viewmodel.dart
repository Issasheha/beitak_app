// import 'package:beitak_app/features/user/home/domain/entities/recent_activity_entity.dart';
// import 'package:beitak_app/features/user/home/domain/entities/user_profile_entity.dart';
// import 'package:beitak_app/features/user/home/domain/usecases/get_profile_usecase.dart';
// import 'package:beitak_app/features/user/home/domain/usecases/get_recent_activity_usecase.dart';
// import 'package:beitak_app/features/user/home/domain/usecases/update_profile_usecase.dart';
// import 'package:beitak_app/features/user/home/domain/usecases/upload_profile_image_usecase.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:beitak_app/core/helpers/local_logout.dart';

// // ✅ مهم لتفادي تعارض UpdateProfileParams لو عندك أكثر من تعريف سابق
// import 'package:beitak_app/features/user/home/domain/repositories/profile_repository.dart'
//     as pr;

// class ProfileViewModel extends ChangeNotifier {
//   final GetProfileUseCase getProfileUseCase;
//   final UpdateProfileUseCase updateProfileUseCase;
//   final UploadProfileImageUseCase uploadProfileImageUseCase;
//   final GetRecentActivityUseCase getRecentActivityUseCase;

//   ProfileViewModel({
//     required this.getProfileUseCase,
//     required this.updateProfileUseCase,
//     required this.uploadProfileImageUseCase,
//     required this.getRecentActivityUseCase,
//   });

//   bool _loading = false;
//   String? _errorMessage;

//   UserProfileEntity? _profile;
//   List<RecentActivityEntity> _activities = const [];

//   bool get isLoading => _loading;
//   String? get errorMessage => _errorMessage;
//   UserProfileEntity? get profile => _profile;
//   List<RecentActivityEntity> get activities => _activities;

//   Future<void> init() async => refresh();

//   Future<void> refresh() async {
//     _setLoading(true);
//     _errorMessage = null;

//     try {
//       _profile = await getProfileUseCase();
//     } catch (e) {
//       _errorMessage = _mapError(e);
//       _setLoading(false);
//       return;
//     }

//     try {
//       final acts = await getRecentActivityUseCase(limit: 10);
//       // ✅ الآن المصدر الرسمي للأنشطة هو backend، لا نضيف شيء يدويًا هنا
//       acts.sort((a, b) => b.time.compareTo(a.time));
//       _activities = acts.take(10).toList();
//     } catch (_) {
//       _activities = const [];
//     } finally {
//       _setLoading(false);
//     }
//   }

//   Future<bool> saveProfile({
//     required String firstName,
//     required String lastName,
//     required String email,
//     required String phone,
//     String? address,
//   }) async {
//     _setLoading(true);
//     _errorMessage = null;

//     try {
//       final updated = await updateProfileUseCase(
//         pr.UpdateProfileParams(
//           firstName: firstName,
//           lastName: lastName,
//           email: email,
//           phone: phone,
//           address: address,
//         ),
//       );

//       _profile = updated;

//       // ✅ لا نضيف activity محلياً. فقط اعمل refresh للـ list من backend
//       await refresh();
//       return true;
//     } catch (e) {
//       _errorMessage = _mapError(e);
//       return false;
//     } finally {
//       _setLoading(false);
//     }
//   }

//   Future<bool> uploadImage(String filePath) async {
//     _setLoading(true);
//     _errorMessage = null;

//     try {
//       final updated = await uploadProfileImageUseCase(filePath);
//       _profile = updated;
//       notifyListeners();
//       return true;
//     } catch (e) {
//       _errorMessage = _mapError(e);
//       return false;
//     } finally {
//       _setLoading(false);
//     }
//   }

//   Future<void> logout() async {
//     await LocalLogout.clearSessionOnly();
//   }

//   String _mapError(Object e) {
//     if (e is DioException) {
//       final status = e.response?.statusCode;

//       if (status == 401) return 'انتهت الجلسة، سجل دخول مرة ثانية';
//       if (status != null && status >= 500) return 'صار خطأ بالسيرفر، جرّب لاحقًا';

//       final err = e.error?.toString().trim();
//       if (err != null && err.isNotEmpty) return err;

//       final data = e.response?.data;
//       if (data is Map<String, dynamic>) {
//         final msg = data['message']?.toString().trim();
//         if (msg != null && msg.isNotEmpty) return msg;
//       }

//       if (e.type == DioExceptionType.connectionTimeout ||
//           e.type == DioExceptionType.receiveTimeout ||
//           e.type == DioExceptionType.sendTimeout) {
//         return 'الاتصال بطيء، حاول مرة أخرى';
//       }

//       return 'حدث خطأ بالشبكة، حاول مرة أخرى';
//     }

//     return 'حدث خطأ، حاول مرة أخرى';
//   }

//   void _setLoading(bool v) {
//     _loading = v;
//     notifyListeners();
//   }
// }
