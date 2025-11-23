// lib/features/auth/presentation/viewmodels/login_viewmodel.dart

import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/continue_as_guest_usecase.dart';
import '../../domain/usecases/login_with_identifier_usecase.dart';
import '../../domain/usecases/send_reset_code_usecase.dart';
import '../../domain/usecases/verify_reset_code_usecase.dart';

/// ViewModel مسؤول عن منطق شاشة تسجيل الدخول + إرسال/التحقق من OTP + متابعة كضيف.
///
/// ملاحظة:
/// - تم نقل مسؤولية حفظ الجلسة (SharedPreferences) إلى Data Layer
///   عن طريق AuthLocalDataSource + AuthRepositoryImpl.
/// - هذا الـ ViewModel يركّز على:
///   - التحقق من صحة الإدخال (validation)
///   - استدعاء UseCases
///   - إرجاع success/failure للـ UI.
class LoginViewModel {
  // ================== Dependencies (UseCases) ==================

  late final LoginWithIdentifierUseCase _loginWithIdentifierUseCase;
  late final ContinueAsGuestUseCase _continueAsGuestUseCase;
  late final SendResetCodeUseCase _sendResetCodeUseCase;
  late final VerifyResetCodeUseCase _verifyResetCodeUseCase;

  /// آخر رسالة خطأ (تقدر تستخدمها في الـ UI لعرض SnackBar مثلاً)
  String? lastErrorMessage;

  LoginViewModel() {
    // في هذه المرحلة، ومن أجل عدم كسر شغلك الحالي،
    // نقوم بإنشاء الـ dependencies داخل الـ ViewModel نفسه.
    //
    // لاحقاً، تقدر تنقل هذا الربط إلى Service Locator / DI بسهولة.
    final dio = Dio(
      BaseOptions(
        // مهم: تأكد أن الـ baseUrl هنا يطابق السيرفر عندكم
        // ويفضل أن يكون في مكان مشترك مثل core/network/api_client.dart
        baseUrl: 'http://192.168.1.87:3026/api',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    final remoteDataSource = AuthRemoteDataSourceImpl(dio);
    final localDataSource = AuthLocalDataSourceImpl();

    final authRepository = AuthRepositoryImpl(
      remote: remoteDataSource,
      local: localDataSource,
    );

    _loginWithIdentifierUseCase = LoginWithIdentifierUseCase(authRepository);
    _continueAsGuestUseCase = ContinueAsGuestUseCase(authRepository);
    _sendResetCodeUseCase = SendResetCodeUseCase(authRepository);
    _verifyResetCodeUseCase = VerifyResetCodeUseCase(authRepository);
  }

  // ================== Helpers ==================

  void _setError(String? message) {
    lastErrorMessage = message;
  }

  // ================== Public API ==================

  // === تسجيل الدخول بالإيميل أو رقم الهاتف (مع Validation قوي) ===
  Future<bool> loginWithIdentifier({
    required String identifier,
    required String password,
  }) async {
    // إعادة ضبط رسالة الخطأ
    _setError(null);

    // 1) Validation محلي (بدون API)

    // تحقق الـ identifier: إما إيميل أو رقم هاتف
    bool isEmail = identifier.contains('@');

    if (isEmail) {
      // تحقق تنسيق الإيميل: يجب أن يكون صالحاً، لا مسافات داخلية، لا (..) أو (@@)،
      // لا بدء/إنتهاء بنقطة، إلخ.
      final emailRegex = RegExp(r'^[^.][\w\-.]+@([\w-]+\.)+[\w-]{2,4}[^.]$');

      if (!emailRegex.hasMatch(identifier) ||
          identifier.contains('..') ||
          identifier.contains('@@') ||
          identifier.contains(' ') ||
          !identifier.contains('.') ||
          identifier.startsWith('.') ||
          identifier.endsWith('.')) {
        _setError('البريد الإلكتروني غير صالح');
        return false;
      }
    } else {
      // تحقق رقم الهاتف: 10 أرقام، أردني، يبدأ بـ 075,077,078,079، لا مسافات أو رموز
      String normalizedPhone =
          identifier.replaceAll(RegExp(r'\D'), ''); // إزالة غير الأرقام

      if (normalizedPhone.length != 10 ||
          !normalizedPhone.startsWith('07') ||
          !['5', '7', '8', '9'].contains(normalizedPhone[2])) {
        _setError('رقم الهاتف غير صالح');
        return false;
      }

      // نستخدم normalizedPhone كـ identifier الفعلي المرسل للباك اند
      identifier = normalizedPhone;
    }

    // تحقق كلمة السر: ≥6 أحرف، لا تكون مسافات فقط، لا مسافات داخلية
    String trimmedPassword = password.trim();
    if (trimmedPassword.length < 6 ||
        trimmedPassword.isEmpty ||
        password.contains(' ')) {
      _setError('كلمة المرور غير صالحة');
      return false;
    }

    // 2) استدعاء UseCase (يتعامل مع الـ Repository + DataSources)
    try {
      await _loginWithIdentifierUseCase(
        identifier: identifier,
        password: password,
      );

      // لو وصلنا هنا، يعني:
      // - تم التحقق بنجاح من السيرفر
      // - تم حفظ الجلسة محلياً عبر AuthLocalDataSource
      _setError(null);
      return true;
    } on ServerException catch (e) {
      _setError(e.message);
      return false;
    } on CacheException catch (e) {
      _setError(e.message);
      return false;
    } catch (_) {
      _setError('حدث خطأ غير متوقع، حاول مرة أخرى');
      return false;
    }
  }

  // === إرسال OTP (لتغيير/استرجاع كلمة المرور) ===
  Future<bool> sendOtpCode({required String phone}) async {
    _setError(null);

    // Validation بسيط رقم جوال
    if (phone.isEmpty || phone.length < 9) {
      _setError('رقم الهاتف غير صالح');
      return false;
    }

    try {
      await _sendResetCodeUseCase(phone: phone);
      return true;
    } on ServerException catch (e) {
      _setError(e.message);
      return false;
    } catch (_) {
      _setError('تعذر إرسال رمز التحقق، حاول مرة أخرى');
      return false;
    }
  }

  // === التحقق من OTP ===
  Future<bool> verifyOtpCode({
    required String phone,
    required String code,
  }) async {
    _setError(null);

    if (code.trim().isEmpty || code.trim().length < 4) {
      _setError('رمز التحقق غير صالح');
      return false;
    }

    try {
      await _verifyResetCodeUseCase(
        phone: phone,
        code: code,
      );

      // في الـ backend الحالي، verify-otp قد يرجع token + user،
      // والـ Repository/UseCase يقدروا يتعاملوا مع حفظ الجلسة لو حبيت توسّع لاحقاً.
      return true;
    } on ServerException catch (e) {
      _setError(e.message);
      return false;
    } catch (_) {
      _setError('رمز التحقق غير صحيح أو منتهي');
      return false;
    }
  }

  // === متابعة كزائر ===
  Future<void> continueAsGuest() async {
    _setError(null);

    try {
      await _continueAsGuestUseCase();
      // الـ UseCase/Repository يهتمون بحفظ حالة "ضيف" في التخزين المحلي
    } on CacheException catch (e) {
      _setError(e.message);
    } catch (_) {
      _setError('تعذر المتابعة كزائر، حاول مرة أخرى');
    }
  }
}
