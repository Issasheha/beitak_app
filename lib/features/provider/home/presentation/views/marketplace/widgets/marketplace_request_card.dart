import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';

import '../models/marketplace_request_ui_model.dart';

class MarketplaceRequestCard extends StatelessWidget {
  final MarketplaceRequestUiModel request;
  final VoidCallback onTap;
  final VoidCallback onAccept;

  /// ✅ لمنع double-accept + اظهار لودينج
  final bool isAccepting;

  const MarketplaceRequestCard({
    super.key,
    required this.request,
    required this.onTap,
    required this.onAccept,
    this.isAccepting = false,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final initials = _initials(request.customerName);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
          child: Container(
            padding: SizeConfig.padding(all: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: SizeConfig.w(18),
                      backgroundColor:
                          AppColors.lightGreen.withValues(alpha: 0.18),
                      child: Text(
                        initials,
                        style: AppTextStyles.body14.copyWith(
                          fontSize: SizeConfig.ts(12),
                          fontWeight: FontWeight.w900,
                          color: AppColors.lightGreen,
                        ),
                      ),
                    ),
                    SizedBox(width: SizeConfig.w(10)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            request.customerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.body14.copyWith(
                              fontSize: SizeConfig.ts(14),
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: SizeConfig.h(4)),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: SizeConfig.ts(16),
                                color: const Color(0xFF6B7280),
                              ),
                              SizedBox(width: SizeConfig.w(4)),
                              Expanded(
                                // ✅ Wrap بدل ellipsis (QA-friendly)
                                child: Text(
                                  _locationLabel(
                                      request.cityName, request.areaName),
                                  maxLines: 2,
                                  overflow: TextOverflow.clip,
                                  softWrap: true,
                                  style: AppTextStyles.body14.copyWith(
                                    fontSize: SizeConfig.ts(12),
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: SizeConfig.h(12)),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('⚡', style: TextStyle(fontSize: SizeConfig.ts(14))),
                    SizedBox(width: SizeConfig.w(8)),
                    Expanded(
                      // ✅ Wrap بدل truncation القاسي
                      child: Text(
                        request.title,
                        maxLines: 3,
                        overflow: TextOverflow.clip,
                        softWrap: true,
                        style: AppTextStyles.body14.copyWith(
                          fontSize: SizeConfig.ts(14),
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: SizeConfig.h(8)),

                Text(
                  request.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  style: AppTextStyles.body14.copyWith(
                    fontSize: SizeConfig.ts(13),
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),

                SizedBox(height: SizeConfig.h(12)),

                // ✅ meta section: no overflow
                LayoutBuilder(
                  builder: (context, constraints) {
                    final gap = SizeConfig.w(10);
                    final itemW = (constraints.maxWidth - gap) / 2;

                    return Wrap(
                      spacing: gap,
                      runSpacing: SizeConfig.h(8),
                      children: [
                        SizedBox(
                          width: itemW,
                          child: _MetaItem(
                            icon: Icons.calendar_today_outlined,
                            text: request.dateLabel,
                          ),
                        ),
                        SizedBox(
                          width: itemW,
                          child: _MetaItem(
                            icon: Icons.access_time_rounded,
                            text: request.timeLabel,
                          ),
                        ),
                        SizedBox(
                          width: itemW,
                          child: _MetaItem(
                            icon: Icons.payments_outlined,
                            text: _budgetLabel(request.budgetMin, request.budgetMax),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                SizedBox(height: SizeConfig.h(14)),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lightGreen,
                      foregroundColor: Colors.white,
                      padding: SizeConfig.padding(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
                      ),
                      elevation: 0,
                    ),
                    onPressed: isAccepting ? null : onAccept,
                    child: isAccepting
                        ? SizedBox(
                            height: SizeConfig.ts(18),
                            width: SizeConfig.ts(18),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2.4,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'قبول',
                            style: AppTextStyles.body14.copyWith(
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              fontSize: SizeConfig.ts(13.5),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _locationLabel(String? city, String? area) {
    final c = (city ?? '').trim();
    final a = (area ?? '').trim();
    if (c.isEmpty && a.isEmpty) return '—';
    if (c.isEmpty) return a;
    if (a.isEmpty) return c;
    return '$c · $a';
  }

  String _budgetLabel(double? min, double? max) {
    final a = min == null ? '—' : min.toStringAsFixed(0);
    final b = max == null ? '—' : max.toStringAsFixed(0);

    if (a == '—' && b == '—') return '—';
    if (a == b) return '$a د.أ';
    return '$a - $b د.أ';
  }

  String _initials(String fullName) {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();

    if (parts.isEmpty) return 'م';

    String firstChar(String s) {
      final t = s.trim();
      if (t.isEmpty) return '';
      return t.characters.first;
    }

    final a = firstChar(parts[0]);
    final b = parts.length > 1 ? firstChar(parts[1]) : '';

    final out = (a + b).trim();
    return out.isEmpty ? 'م' : out;
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Icon(icon, size: SizeConfig.ts(16), color: const Color(0xFF6B7280)),
        SizedBox(width: SizeConfig.w(4)),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: AppTextStyles.body14.copyWith(
              fontSize: SizeConfig.ts(12),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
        ),
      ],
    );
  }
}
