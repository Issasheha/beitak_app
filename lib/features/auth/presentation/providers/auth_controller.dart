import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:beitak_app/core/error/exceptions.dart';
import 'package:beitak_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:beitak_app/features/auth/presentation/providers/auth_state.dart';

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  bool _bootstrapped = false;

  AuthController(this._repo) : super(const AuthState.loading());

  Future<void> bootstrap() async {
    if (_bootstrapped) return;
    _bootstrapped = true;

    try {
      final session = await _repo.loadSavedSession();

      if (session == null) {
        state = const AuthState.unauthenticated();
        return;
      }

      if (session.isGuest) {
        state = AuthState.guest(session);
        return;
      }

      if (session.isAuthenticated) {
        state = AuthState.authenticated(session);
        return;
      }

      state = const AuthState.unauthenticated();
    } catch (_) {
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> reload() async {
    _bootstrapped = false;
    state = const AuthState.loading();
    await bootstrap();
  }

  String _mapLoginError(String msg, {int? statusCode}) {
    final m = msg.toLowerCase().trim();

    // provider_suspended
    if (m.contains('provider_suspended')) {
      return 'حساب مزود الخدمة موقوف. يرجى التواصل مع الدعم.';
    }

    // invalid credentials / wrong login
    if (m.contains('invalid credentials') ||
        m.contains('invalid credential') ||
        m.contains('unauthorized') ||
        statusCode == 401 ||
        statusCode == 404) {
      return 'بيانات الدخول غير صحيحة. تأكد منها';
    }

    // generic network english coming from somewhere
    if (m.contains('network error')) {
      return 'تعذر الاتصال بالإنترنت، تحقق من الشبكة وحاول مرة أخرى.';
    }

    return msg;
  }

  Future<void> loginWithIdentifier({
    required String identifier,
    required String password,
  }) async {
    try {
      final session = await _repo.loginWithIdentifier(
        identifier: identifier,
        password: password,
      );

      if (!session.isAuthenticated) {
        throw const ServerException(
          message: 'تعذر تسجيل الدخول، حاول مرة أخرى.',
        );
      }

      state = AuthState.authenticated(session);
    } on DioException catch (e) {
      // ✅ تعريب أخطاء الشبكة
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('تعذر الاتصال بالإنترنت، تحقق من الشبكة وحاول مرة أخرى.');
      }
      throw Exception('حدث خطأ في الاتصال، حاول مرة أخرى.');
    } on SocketException {
      throw Exception('تعذر الاتصال بالإنترنت، تحقق من الشبكة وحاول مرة أخرى.');
    } on ServerException catch (e) {
      throw Exception(_mapLoginError(e.message, statusCode: e.statusCode));
    } on CacheException catch (e) {
      throw Exception(e.message);
    } catch (_) {
      throw Exception('حدث خطأ غير متوقع، حاول مرة أخرى.');
    }
  }

  Future<void> signupCustomer({
    required String firstName,
    required String lastName,
    String? phone,
    String? email,
    required String password,
    int cityId = 1,
    int areaId = 1,
  }) async {
    try {
      final session = await _repo.signup(
        firstName: firstName,
        lastName: lastName,
        phone: (phone ?? '').trim(),
        email: (email ?? '').trim(),
        password: password,
        cityId: cityId,
        areaId: areaId,
        role: 'customer',
      );

      if (!session.isAuthenticated) {
        throw const ServerException(
          message: 'تعذر إنشاء الحساب، حاول مرة أخرى.',
        );
      }

      state = AuthState.authenticated(session);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('تعذر الاتصال بالإنترنت، تحقق من الشبكة وحاول مرة أخرى.');
      }
      throw Exception('حدث خطأ في الاتصال، حاول مرة أخرى.');
    } on SocketException {
      throw Exception('تعذر الاتصال بالإنترنت، تحقق من الشبكة وحاول مرة أخرى.');
    } on ServerException catch (e) {
      throw Exception(e.message);
    } on CacheException catch (e) {
      throw Exception(e.message);
    } catch (_) {
      throw Exception('حدث خطأ غير متوقع أثناء إنشاء الحساب.');
    }
  }

  Future<void> continueAsGuest() async {
    try {
      final session = await _repo.continueAsGuest();
      state = AuthState.guest(session);
    } on CacheException catch (e) {
      throw Exception(e.message);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw Exception('تعذر الاتصال بالإنترنت، تحقق من الشبكة وحاول مرة أخرى.');
      }
      throw Exception('حدث خطأ في الاتصال، حاول مرة أخرى.');
    } on SocketException {
      throw Exception('تعذر الاتصال بالإنترنت، تحقق من الشبكة وحاول مرة أخرى.');
    } catch (_) {
      throw Exception('تعذر المتابعة كزائر، حاول مرة أخرى.');
    }
  }
Future<void> logout() async {
  // ✅ 1) دائماً خليك تعتبر logout محلي أولاً (حتى لو API فشل)
  try {
    await _repo.logout();
  } catch (_) {
    // نتجاهل أي خطأ من السيرفر/الشبكة
  } finally {
    // ✅ 2) المهم: صفّر الحالة دائماً
    state = const AuthState.unauthenticated();
  }
}

  }
