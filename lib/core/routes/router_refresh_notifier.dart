// lib/core/routes/router_refresh_notifier.dart
import 'package:flutter/foundation.dart';

class RouterRefreshNotifier extends ChangeNotifier {
  void ping() => notifyListeners();
}
