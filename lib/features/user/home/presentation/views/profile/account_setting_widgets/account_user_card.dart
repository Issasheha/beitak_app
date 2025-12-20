import 'package:beitak_app/core/constants/color_x.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/features/user/home/domain/entities/user_profile_entity.dart';
import 'package:flutter/material.dart';

class AccountUserCard extends StatelessWidget {
  final UserProfileEntity? profile;

  const AccountUserCard({super.key, required this.profile});

  String _initials(String s) {
    final parts = s.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return 'ض';
    final first = parts.first;
    return first.characters.isNotEmpty ? first.characters.first : 'ض';
  }

  String _memberSinceAr(DateTime? createdAt) {
    if (createdAt == null) return '—';
    const months = [
      'يناير','فبراير','مارس','أبريل','مايو','يونيو',
      'يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر',
    ];
    final m = months[(createdAt.month - 1).clamp(0, 11)];
    return '$m ${createdAt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final name = (profile?.name ?? '').trim();
    final safeName = name.isNotEmpty ? name : 'ضيف عزيز';

    final email = (profile?.email ?? '').trim();
    final phone = (profile?.phone ?? '').trim();

    final city = (profile?.city ?? '').trim(); // ✅ City فقط
    final createdAt = profile?.createdAt;

    return Container(
      padding: SizeConfig.padding(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.o(0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: SizeConfig.w(64),
            height: SizeConfig.w(64),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF2AA7FF),
            ),
            alignment: Alignment.center,
            child: Text(
              _initials(safeName),
              style: TextStyle(
                fontSize: SizeConfig.ts(16),
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: SizeConfig.h(8)),

          Text(
            safeName,
            style: TextStyle(
              fontSize: SizeConfig.ts(14.5),
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: SizeConfig.h(6)),

          if (city.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on_outlined, size: SizeConfig.w(16), color: Colors.redAccent),
                SizedBox(width: SizeConfig.w(6)),
                Text(
                  city,
                  style: TextStyle(
                    fontSize: SizeConfig.ts(12.2),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: SizeConfig.h(6)),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events_outlined, size: SizeConfig.w(16), color: Colors.amber.shade700),
              SizedBox(width: SizeConfig.w(6)),
              Text(
                'Member since ${_memberSinceAr(createdAt)}',
                style: TextStyle(
                  fontSize: SizeConfig.ts(12.0),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          SizedBox(height: SizeConfig.h(12)),
          Container(height: 1, color: Colors.grey.withValues(alpha: 0.14)),
          SizedBox(height: SizeConfig.h(10)),

          // Contact row (زي الصورة تحت)
          Row(
            children: [
              Expanded(
                child: _MiniInfo(
                  icon: Icons.phone_outlined,
                  text: phone.isNotEmpty ? phone : '—',
                  ltr: true,
                ),
              ),
              SizedBox(width: SizeConfig.w(10)),
              Expanded(
                child: _MiniInfo(
                  icon: Icons.email_outlined,
                  text: email.isNotEmpty ? email : '—',
                  ltr: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool ltr;

  const _MiniInfo({
    required this.icon,
    required this.text,
    this.ltr = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SizeConfig.padding(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Icon(icon, size: SizeConfig.w(16), color: AppColors.textSecondary),
          SizedBox(width: SizeConfig.w(8)),
          Expanded(
            child: Directionality(
              textDirection: ltr ? TextDirection.ltr : TextDirection.rtl,
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: SizeConfig.ts(12),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
