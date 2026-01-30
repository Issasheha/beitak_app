// lib/core/error/global_error_handler.dart
// P1: Centralized error handling for uncaught exceptions

import 'dart:async';

import 'package:flutter/foundation.dart';

/// Centralized error handler for the app.
/// 
/// Catches:
/// - Flutter framework errors
/// - Async errors (via zone)
/// - Platform dispatcher errors
/// 
/// Usage:
/// ```dart
/// void main() {
///   GlobalErrorHandler.init();
///   runApp(const MyApp());
/// }
/// ```
class GlobalErrorHandler {
  GlobalErrorHandler._();

  static bool _initialized = false;

  /// Initialize global error handlers.
  /// Call this at the start of main() before runApp().
  static void init() {
    if (_initialized) return;
    _initialized = true;

    // 1) Flutter framework errors (widget build errors, etc.)
    FlutterError.onError = _handleFlutterError;

    // 2) Platform dispatcher errors (async errors not caught by zones)
    PlatformDispatcher.instance.onError = _handlePlatformError;
  }

  /// Run the app with a guarded zone to catch async errors.
  /// 
  /// Usage:
  /// ```dart
  /// GlobalErrorHandler.runGuarded(() => runApp(const MyApp()));
  /// ```
  static void runGuarded(VoidCallback body) {
    runZonedGuarded(
      body,
      _handleZoneError,
    );
  }

  // ========================
  // Error Handlers
  // ========================

  /// Handle Flutter framework errors (e.g., widget build errors)
  static void _handleFlutterError(FlutterErrorDetails details) {
    // In debug mode, print the full error for development
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
      return;
    }

    // In release mode, log silently (could send to crash reporting)
    _logError(
      'FlutterError',
      details.exception,
      details.stack,
    );
  }

  /// Handle platform dispatcher errors (async errors)
  static bool _handlePlatformError(Object error, StackTrace stack) {
    _handleError(error, stack, source: 'PlatformDispatcher');
    // Return true to indicate the error was handled
    return true;
  }

  /// Handle zone errors (uncaught async exceptions)
  static void _handleZoneError(Object error, StackTrace stack) {
    _handleError(error, stack, source: 'ZonedGuarded');
  }

  /// Central error handling logic
  static void _handleError(
    Object error,
    StackTrace stack, {
    required String source,
  }) {
    if (kDebugMode) {
      debugPrint('┌────────────── UNCAUGHT ERROR [$source] ──────────────');
      debugPrint('│ Error: $error');
      debugPrint('│ Stack: $stack');
      debugPrint('└──────────────────────────────────────────────────────');
    }

    _logError(source, error, stack);
  }

  /// Log error (in release mode, could send to crash reporting service)
  static void _logError(String source, Object error, StackTrace? stack) {
    // ✅ P0: Never log sensitive data
    // Sanitize error message to remove potential secrets
    final sanitizedError = _sanitizeError(error.toString());

    if (kDebugMode) {
      debugPrint('GlobalErrorHandler [$source]: $sanitizedError');
    }

    // TODO: In production, send to crash reporting service (e.g., Firebase Crashlytics)
    // FirebaseCrashlytics.instance.recordError(error, stack, reason: source);
  }

  /// Sanitize error messages to remove sensitive data
  static String _sanitizeError(String message) {
    // Remove potential tokens, passwords, or other secrets
    var sanitized = message;

    // Mask Bearer tokens
    sanitized = sanitized.replaceAll(
      RegExp(r'Bearer\s+[A-Za-z0-9\-_.]+', caseSensitive: false),
      'Bearer ***',
    );

    // Mask password fields in JSON-like strings
    sanitized = sanitized.replaceAll(
      RegExp(r'"(password|current_password|new_password|token|secret|api_key)"\s*:\s*"[^"]*"', caseSensitive: false),
      r'"$1": "***"',
    );

    return sanitized;
  }
}
