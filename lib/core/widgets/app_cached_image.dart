// lib/core/widgets/app_cached_image.dart
// P1: Reusable cached network image widget for better performance

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// A reusable cached network image widget with shimmer placeholder and error handling.
/// Uses cached_network_image for automatic disk/memory caching.
class AppCachedImage extends StatelessWidget {
  const AppCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.fadeInDuration = const Duration(milliseconds: 300),
  });

  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Duration fadeInDuration;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();

    // Handle null or empty URL
    if (url == null || url.isEmpty) {
      return _buildErrorWidget();
    }

    Widget image = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: fadeInDuration,
      fadeOutDuration: const Duration(milliseconds: 100),
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) => _buildErrorWidget(),
      // Performance: use memory cache for faster loads
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
    );

    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }

  Widget _buildPlaceholder() {
    if (placeholder != null) return placeholder!;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: borderRadius,
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    if (errorWidget != null) return errorWidget!;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: borderRadius,
      ),
      child: Icon(
        Icons.broken_image_outlined,
        color: Colors.grey.shade400,
        size: 32,
      ),
    );
  }
}

/// Circle avatar with cached network image
class AppCachedCircleAvatar extends StatelessWidget {
  const AppCachedCircleAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 24,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor,
  });

  final String? imageUrl;
  final double radius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    final diameter = radius * 2;

    if (url == null || url.isEmpty) {
      return _buildFallback();
    }

    return CachedNetworkImage(
      imageUrl: url,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: radius,
        backgroundImage: imageProvider,
        backgroundColor: backgroundColor ?? Colors.grey.shade200,
      ),
      placeholder: (context, url) => CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Colors.grey.shade200,
        child: placeholder ??
            SizedBox(
              width: diameter * 0.5,
              height: diameter * 0.5,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
              ),
            ),
      ),
      errorWidget: (context, url, error) => _buildFallback(),
      memCacheWidth: diameter.toInt(),
      memCacheHeight: diameter.toInt(),
    );
  }

  Widget _buildFallback() {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.grey.shade200,
      child: errorWidget ??
          Icon(
            Icons.person,
            color: Colors.grey.shade400,
            size: radius,
          ),
    );
  }
}
