// lib/features/auth/presentation/providers/auth_controller.dart
import 'dart:io';

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
    } on SocketException {
      // ✅ عربي بدل إنجليزي
      throw Exception('تعذر الاتصال بالإنترنت، تحقق من الشبكة وحاول مرة أخرى.');
    } on ServerException catch (e) {
      throw Exception(e.message);
    } on CacheException catch (e) {
      throw Exception(e.message);
    } catch (_) {
      throw Exception('حدث خطأ غير متوقع، حاول مرة أخرى.');
    }
  }

  /// ✅ تسجيل مستخدم عادي (Customer) وربط النتيجة مع AuthState
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

      // ✅ صار عندنا session محفوظة + state محدثة
      state = AuthState.authenticated(session);
    } on SocketException {
      // ✅ عربي بدل إنجليزي
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
    } on SocketException {
      throw Exception('تعذر الاتصال بالإنترنت، تحقق من الشبكة وحاول مرة أخرى.');
    } catch (_) {
      throw Exception('تعذر المتابعة كزائر، حاول مرة أخرى.');
    }
  }

  Future<void> logout() async {
    try {
      await _repo.logout();
      state = const AuthState.unauthenticated();
    } on SocketException {
      throw Exception('تعذر الاتصال بالإنترنت، تحقق من الشبكة وحاول مرة أخرى.');
    } catch (_) {
      throw Exception('تعذر تسجيل الخروج، حاول مرة أخرى.');
    }
  }
}
