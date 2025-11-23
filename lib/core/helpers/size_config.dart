import 'package:flutter/material.dart';

class SizeConfig {
  static const double designWidth = 375;
  static const double designHeight = 812;

  static late MediaQueryData _mediaQuery;
  static late double screenWidth;
  static late double screenHeight;
  static late double pixelRatio;
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
    textScaleFactor = _mediaQuery.textScaleFactor;
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
    double scale = (_scaleWidth + _scaleHeight) / 2;
    double result = fontSize * scale;

    return result / (textScaleFactor > 1.4 ? 1.4 : textScaleFactor);
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