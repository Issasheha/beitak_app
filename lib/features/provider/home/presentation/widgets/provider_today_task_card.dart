import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/constants/color_x.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/features/provider/home/presentation/widgets/provider_action_buttons.dart';
import 'package:beitak_app/features/provider/home/presentation/widgets/provider_home_content.dart';

import 'package:beitak_app/core/constants/fixed_service_categories.dart';
import 'package:beitak_app/core/constants/fixed_locations.dart';
import 'package:beitak_app/core/providers/areas_name_map_provider.dart';

class ProviderTodayTaskCard extends ConsumerWidget {
  const ProviderTodayTaskCard({
    super.key,
    required this.item,
    required this.onDetailsTap,
    required this.onCompleteTap,
    required this.onCancelTap,
    required this.busy,
  });

  final ProviderTodayTaskUI item;
  final VoidCallback onDetailsTap;
  final VoidCallback? onCompleteTap;
  final VoidCallback? onCancelTap;
  final bool busy;

  String _initials(String s) {
    final parts = s.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'م';
    final first = parts.first.characters.isNotEmpty ? parts.first.characters.first : 'م';
    final second = parts.length > 1 && parts[1].characters.isNotEmpty ? parts[1].characters.first : '';
    final r = (first + second).trim();
    return r.isEmpty ? 'م' : r;
  }

  String _serviceTitleAr(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return '—';

    final key = FixedServiceCategories.keyFromAnyString(s);
    if (key != null) return FixedServiceCategories.labelArFromKey(key);

    // لو عربي أصلاً خلّيه
    final hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(s);
    return hasArabic ? s : s;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initials = _initials(item.customerName);

    // ✅ service بالعربي
    final serviceAr = _serviceTitleAr(item.serviceName);

    // ✅ location بالعربي (city - area) زي التفاصيل
    final areasMapAsync = ref.watch(areasNameMapProvider);
    final locationRaw = item.locationText.trim();

    final locationAr = areasMapAsync.when(
      data: (m) => FixedLocations.labelArFromAny(locationRaw, map: m),
      loading: () => FixedLocations.labelArFromAny(locationRaw),
      error: (_, __) => FixedLocations.labelArFromAny(locationRaw),
    );

    return Container(
      padding: SizeConfig.padding(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeConfig.radius(18)),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.o(0.06),
            blurRadius: 16,
            offset: const Offset(0, 12),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _HeaderRow(
            initials: initials,
            serviceName: serviceAr, // ✅ بدل item.serviceName
            customerName: item.customerName,
            onDetailsTap: onDetailsTap,
          ),
          SizedBox(height: SizeConfig.h(12)),

          // ✅ Meta row Responsive
          _MetaResponsiveRow(
            timeText: item.timeText,
            locationText: locationAr, // ✅ بدل item.locationText
            durationText: item.durationText,
            priceText: item.priceText,
          ),

          SizedBox(height: SizeConfig.h(12)),

          Row(
            textDirection: TextDirection.rtl,
            children: [
              Expanded(
                child: ProviderPrimaryActionBtn(
                  label: 'إنهاء الخدمة',
                  isLoading: busy,
                  onTap: busy ? null : onCompleteTap,
                ),
              ),
              SizedBox(width: SizeConfig.w(10)),
              Expanded(
                child: ProviderOutlineActionBtn(
                  label: 'إلغاء الخدمة',
                  onTap: busy ? null : onCancelTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({
    required this.initials,
    required this.serviceName,
    required this.customerName,
    required this.onDetailsTap,
  });

  final String initials;
  final String serviceName;
  final String customerName;
  final VoidCallback onDetailsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Container(
          width: SizeConfig.w(48),
          height: SizeConfig.w(48),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF4B58FF),
            border: Border.all(color: Colors.white.o(0.35)),
          ),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: TextStyle(
              fontSize: SizeConfig.ts(12.5),
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.0,
            ),
          ),
        ),
        SizedBox(width: SizeConfig.w(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                serviceName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: SizeConfig.ts(13.8),
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: SizeConfig.h(5)),
              Text(
                customerName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: SizeConfig.ts(12.2),
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: SizeConfig.w(10)),
        ProviderGreenDetailsButton(onTap: onDetailsTap, label: 'تفاصيل'),
      ],
    );
  }
}

class _MetaResponsiveRow extends StatelessWidget {
  const _MetaResponsiveRow({
    required this.timeText,
    required this.locationText,
    required this.durationText,
    required this.priceText,
  });

  final String timeText;
  final String locationText;
  final String durationText;
  final String priceText;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final tight = c.maxWidth < 360;

        final metaStyle = TextStyle(
          fontSize: SizeConfig.ts(12),
          fontWeight: FontWeight.w800,
          color: AppColors.textSecondary,
          height: 1.1,
        );

        final priceStyle = TextStyle(
          fontSize: SizeConfig.ts(13),
          fontWeight: FontWeight.w900,
          color: AppColors.lightGreen,
          height: 1.1,
        );

        if (tight) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: SizeConfig.w(10),
                runSpacing: SizeConfig.h(8),
                children: [
                  _MetaChip(icon: '🕘', text: timeText, style: metaStyle),
                  _MetaChip(icon: '📍', text: locationText, style: metaStyle),
                  _MetaChip(icon: '⏱️', text: durationText, style: metaStyle),
                ],
              ),
              SizedBox(height: SizeConfig.h(10)),
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  const Spacer(),
                  Text(priceText, style: priceStyle),
                  SizedBox(width: SizeConfig.w(6)),
                  Text('💵', style: TextStyle(fontSize: SizeConfig.ts(13), height: 1.0)),
                ],
              ),
            ],
          );
        }

        return Row(
          textDirection: TextDirection.rtl,
          children: [
            _MetaInline(icon: '🕘', text: timeText, style: metaStyle),
            SizedBox(width: SizeConfig.w(12)),
            Expanded(
              child: _MetaInline(icon: '📍', text: locationText, style: metaStyle, ellipsis: true),
            ),
            SizedBox(width: SizeConfig.w(12)),
            _MetaInline(icon: '⏱️', text: durationText, style: metaStyle),
            const Spacer(),
            Text(priceText, style: priceStyle),
            SizedBox(width: SizeConfig.w(6)),
            Text('💵', style: TextStyle(fontSize: SizeConfig.ts(13), height: 1.0)),
          ],
        );
      },
    );
  }
}

class _MetaInline extends StatelessWidget {
  const _MetaInline({
    required this.icon,
    required this.text,
    required this.style,
    this.ellipsis = false,
  });

  final String icon;
  final String text;
  final TextStyle style;
  final bool ellipsis;

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: TextStyle(fontSize: SizeConfig.ts(13), height: 1.0)),
        SizedBox(width: SizeConfig.w(6)),
        Text(
          text,
          maxLines: 1,
          overflow: ellipsis ? TextOverflow.ellipsis : TextOverflow.visible,
          style: style,
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.text,
    required this.style,
  });

  final String icon;
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SizeConfig.padding(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: [
          Text(icon, style: TextStyle(fontSize: SizeConfig.ts(13), height: 1.0)),
          SizedBox(width: SizeConfig.w(6)),
          Text(text, style: style),
        ],
      ),
    );
  }
}
