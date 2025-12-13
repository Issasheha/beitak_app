import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';

class ProviderInitialsAvatar extends StatelessWidget {
  const ProviderInitialsAvatar({
    super.key,
    required this.name,
    this.size,
  });

  final String name;
  final double? size;

  String _initials(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return '؟';

    // Split by spaces (supports Arabic/English names)
    final parts = s.split(RegExp(r'\s+')).where((e) => e.trim().isNotEmpty).toList();

    if (parts.length >= 2) {
      final a = parts[0].characters.first;
      final b = parts[1].characters.first;
      return ('$a$b').toUpperCase();
    }

    // Single word: take first 2 characters if possible
    final chars = s.characters.toList();
    if (chars.length >= 2) return ('${chars[0]}${chars[1]}').toUpperCase();
    return chars.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final double d = size ?? SizeConfig.w(44);
    final initials = _initials(name);

    return Container(
      width: d,
      height: d,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.lightGreen.withValues(alpha: 0.16),
        border: Border.all(color: AppColors.lightGreen.withValues(alpha: 0.45),),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: AppColors.lightGreen,
          fontWeight: FontWeight.w900,
          fontSize: SizeConfig.ts(14),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
