import 'package:flutter/material.dart';

class SizeConfig {
  static const double designWidth = 375;
  static const double designHeight = 812;

  static late MediaQueryData _mediaQuery;
  static late double screenWidth;
  static late double screenHeight;
  static late double pixelRatio;

  // ✅ بدل textScaleFactor deprecated
  static late TextScaler textScaler;

  // ✅ إذا بدك تظل تستخدم رقم جاهز مثل قبل (بدون تغيير سلوك)
  static late double textScaleFactor;

  static late Orientation orientation;

  static late double _scaleWidth;
  static late double _scaleHeight;

  static bool _initialized = false;

  /// Should be called inside the build method once for each screen
  static void init(BuildContext context) {
    _mediaQuery = MediaQuery.of(context);

    screenWidth = _mediaQuery.size.width;
    screenHeight = _mediaQuery.size.height;
    pixelRatio = _mediaQuery.devicePixelRatio;

    // ✅ الجديد
    textScaler = _mediaQuery.textScaler;

    // ✅ نطلع scale كرقم مثل القديم (تقريباً نفس المعنى)
    // scale(1.0) يعطينا قيمة تكبير النص بالنسبة للـ base
    textScaleFactor = textScaler.scale(1.0);

    orientation = _mediaQuery.orientation;

    _scaleWidth = screenWidth / designWidth;
    _scaleHeight = screenHeight / designHeight;

    _initialized = true;
  }

  static void _checkInit() {
    if (!_initialized) {
      throw FlutterError(
        'SizeConfig.init(context) must be called first!',
      );
    }
  }

  // Scaled width
  static double w(double value) {
    _checkInit();
    return value * _scaleWidth;
  }

  // Scaled height
  static double h(double value) {
    _checkInit();
    return value * _scaleHeight;
  }

  // Scaled font size
  static double ts(double fontSize) {
    _checkInit();
    final scale = (_scaleWidth + _scaleHeight) / 2;
    final result = fontSize * scale;

    // ✅ نفس منطقك بالضبط: cap 1.4
    final effective = textScaleFactor > 1.4 ? 1.4 : textScaleFactor;

    // ✅ حماية إضافية بسيطة (لو صار 0 لأي سبب)
    return effective <= 0 ? result : (result / effective);
  }

  // Padding/margin scaled
  static EdgeInsets padding({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
    double horizontal = 0,
    double vertical = 0,
    double all = 0,
  }) {
    if (all != 0) {
      left = right = top = bottom = all;
    } else {
      if (horizontal != 0) {
        left = right = horizontal;
      }
      if (vertical != 0) {
        top = bottom = vertical;
      }
    }
    _checkInit();
    return EdgeInsets.fromLTRB(
      w(left),
      h(top),
      w(right),
      h(bottom),
    );
  }

  static double radius(double r) => w(r);
  static SizedBox v(double value) => SizedBox(height: h(value));
  static SizedBox hSpace(double value) => SizedBox(width: w(value));
}
