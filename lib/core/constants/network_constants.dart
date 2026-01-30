// lib/core/constants/network_constants.dart
// P2: Extract magic numbers into named constants for maintainability

/// Network-related constants for API client configuration.
class NetworkConstants {
  NetworkConstants._();

  // ========================
  // Timeouts
  // ========================

  /// Connection timeout in seconds
  static const int connectTimeoutSeconds = 15;

  /// Receive timeout in seconds
  static const int receiveTimeoutSeconds = 15;

  // ========================
  // Retry Configuration
  // ========================

  /// Maximum number of retry attempts for transient errors
  static const int maxRetryAttempts = 3;

  /// Base delay for exponential backoff (in milliseconds)
  /// Delays: 500ms, 1000ms, 2000ms
  static const int baseRetryDelayMs = 500;

  /// HTTP status codes that should trigger a retry
  static const Set<int> retryableStatusCodes = {
    408, // Request Timeout
    429, // Too Many Requests
    503, // Service Unavailable
  };

  /// HTTP methods that are safe to retry (idempotent)
  static const Set<String> retryableMethods = {
    'GET',
    'HEAD',
    'OPTIONS',
  };

  // ========================
  // Compute Threshold
  // ========================

  /// Threshold in bytes above which we use compute() for JSON parsing
  /// 100KB - most responses are smaller than this
  static const int computeThresholdBytes = 100000;

  // ========================
  // Token Expiry
  // ========================

  /// Minutes before token expiry to trigger proactive refresh
  static const int tokenExpiryBufferMinutes = 5;

  /// Minutes to check if token is expiring soon (for UI warnings)
  static const int tokenExpiringSoonMinutes = 10;
}
