import 'dart:async';

class RetryService {
  static Future<T> withRetry<T>({
    required Future<T> Function() operation,
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
    bool Function(Exception)? shouldRetry,
  }) async {
    int attempts = 0;
    Duration delay = initialDelay;

    while (true) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        
        if (attempts >= maxRetries || (shouldRetry != null && !shouldRetry(e as Exception))) {
          rethrow;
        }

        await Future.delayed(delay);
        delay *= 2; // Exponential backoff
      }
    }
  }

  static bool isNetworkError(Exception e) {
    return e.toString().contains('SocketException') ||
           e.toString().contains('TimeoutException') ||
           e.toString().contains('NetworkError');
  }

  static bool isFirestoreError(Exception e) {
    return e.toString().contains('FirebaseException') ||
           e.toString().contains('cloud_firestore');
  }
} 