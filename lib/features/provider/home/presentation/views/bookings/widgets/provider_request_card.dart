import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/provider/home/data/models/provider_booking_model.dart';

import 'package:beitak_app/core/constants/fixed_locations.dart';
import 'package:beitak_app/core/providers/areas_name_map_provider.dart';

class ProviderBookingCard extends ConsumerWidget {
  final ProviderBookingModel booking;

  /// Open details sheet
  final VoidCallback onDetailsTap;

  /// Pending actions
  final VoidCallback? onAccept;

  /// ✅ نفس عملية الإلغاء المستخدمة عند الخدمات القادمة
  /// وستُستخدم أيضًا عند الطلبات الجديدة (بدون رفض)
  final VoidCallback? onCancel;

  /// Upcoming actions
  final VoidCallback? onComplete;

  /// Busy state for this booking
  final bool busy;

  const ProviderBookingCard({
    super.key,
    required this.booking,
    required this.onDetailsTap,
    this.onAccept,
    this.onComplete,
    this.onCancel,
    this.busy = false,
  });

  static const _scheduledLikeStatuses = {
    'confirmed',
    'provider_on_way',
    'provider_arrived',
    'in_progress',
  };

  // ✅ QA: أي status من الباك معناته إلغاء/رفض => نعرضه "ملغاة"
  static const _cancelLikeStatuses = {
    'cancelled',
    'canceled',
    'rejected',
    'declined',
    'rejected_by_provider',
    'provider_rejected',
    'cancelled_by_provider',
    'provider_cancelled',
  };

  bool get _isPending => booking.status == 'pending_provider_accept';
  bool get _isScheduledLike => _scheduledLikeStatuses.contains(booking.status);
  bool get _isCancelledLike => _cancelLikeStatuses.contains(booking.status);

  Color get _statusColor {
    switch (booking.status) {
      case 'pending_provider_accept':
        return Colors.orange;
      case 'confirmed':
        return Colors.green;
      case 'provider_on_way':
      case 'provider_arrived':
      case 'in_progress':
        return AppColors.lightGreen;
      case 'completed':
        return AppColors.lightGreen;

      case 'incomplete':
        return Colors.orange;

      default:
        return _isCancelledLike ? Colors.red : AppColors.textSecondary;
    }
  }

  String get _statusLabel {
    switch (booking.status) {
      case 'pending_provider_accept':
        return 'قيد الانتظار';
      case 'confirmed':
        return 'مقبولة';
      case 'provider_on_way':
        return 'بالطريق';
      case 'provider_arrived':
        return 'وصل';
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'completed':
        return 'مكتملة';

      case 'incomplete':
        return 'غير مكتمل';

      default:
        if (_isCancelledLike) return 'ملغاة';
        return booking.status;
    }
  }

  String _dateNice(String d) => d.trim().replaceAll('-', '/');

  /// ✅ "HH:mm:ss" or "HH:mm" -> "h:mm ص/م"
  String _time12hAr(String hhmmss) {
    final s = hhmmss.trim();
    if (s.isEmpty) return '—';

    final parts = s.split(':');
    if (parts.length < 2) return s;

    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;

    final isPm = h >= 12;
    final suffix = isPm ? 'م' : 'ص';

    int hour12 = h % 12;
    if (hour12 == 0) hour12 = 12;

    final mm = m.toString().padLeft(2, '0');
    return '$hour12:$mm $suffix';
  }

  // ---------------- Clean + Split helpers ----------------

  bool _isPlaceholder(String s) {
    final x = s.trim().toLowerCase();
    return x.isEmpty ||
        x == 'n/a' ||
        x == 'na' ||
        x == 'none' ||
        x == 'null' ||
        x == '-' ||
        x == '—';
  }

  String _clean(String? s) {
    final v = (s ?? '').trim();
    if (v.isEmpty) return '';
    if (_isPlaceholder(v)) return '';
    return v;
  }

  /// ✅ يفك locationText إلى [city, area]
  List<String> _splitCityArea(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return const [];

    var norm = s;
    norm = norm.replaceAll('،', ',');
    norm = norm.replaceAll(' - ', '-');
    norm = norm.replaceAll(' — ', '-');

    List<String> parts;
    if (norm.contains(',')) {
      parts = norm.split(',');
    } else if (norm.contains('-')) {
      parts = norm.split('-');
    } else {
      parts = [norm];
    }

    parts = parts.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    if (parts.length == 1) return ['', parts[0]];
    return [parts[0], parts[1]];
  }

  // ---------------- Avatar helpers ----------------

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'م';

    String firstChar(String s) {
      final t = s.trim();
      if (t.isEmpty) return '';
      return t.characters.first.toUpperCase();
    }

    final a = firstChar(parts[0]);
    final b = parts.length > 1 ? firstChar(parts[1]) : '';
    final out = (a + b).trim();
    return out.isEmpty ? 'م' : out;
  }

  Color _avatarColor(String seed) {
    const palette = <Color>[
      Color(0xFF22C55E),
      Color(0xFF10B981),
      Color(0xFF06B6D4),
      Color(0xFF3B82F6),
      Color(0xFF6366F1),
      Color(0xFF8B5CF6),
      Color(0xFFF97316),
      Color(0xFFEF4444),
      Color(0xFF14B8A6),
      Color(0xFFA3A3A3),
    ];

    final s = seed.trim().isEmpty ? 'NA' : seed.trim();
    int hash = 0;
    for (final codeUnit in s.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x7fffffff;
    }
    return palette[hash % palette.length];
  }

  bool _hasContactInfo(ProviderBookingModel b) {
    final p = (b.customerPhone ?? '').trim();
    final e = (b.customerEmail ?? '').trim();
    return p.isNotEmpty || e.isNotEmpty;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initials = _initials(booking.customerName);
    final avatar = _avatarColor(booking.customerName);

    final showNotes = (booking.customerNotes ?? '').trim().isNotEmpty;
    final notes = (booking.customerNotes ?? '').trim();

    final canShowPendingActions =
        _isPending && (onAccept != null || onCancel != null);

    final canShowUpcomingActions =
        _isScheduledLike && (onComplete != null || onCancel != null);

    final showContactHint = _isPending && _hasContactInfo(booking);

    final areasMapAsync = ref.watch(areasNameMapProvider);

    final locationRaw = _clean(booking.locationText);
    final parts = _splitCityArea(locationRaw);

    final cityRaw = parts.isNotEmpty ? parts[0] : '';
    final areaRaw = parts.length > 1 ? parts[1] : '';

    final cityAr = areasMapAsync.when(
      data: (m) => FixedLocations.labelArFromAny(cityRaw, map: m),
      loading: () => FixedLocations.labelArFromAny(cityRaw),
      error: (_, __) => FixedLocations.labelArFromAny(cityRaw),
    );

    final areaAr = areasMapAsync.when(
      data: (m) => FixedLocations.labelArFromAny(areaRaw, map: m),
      loading: () => FixedLocations.labelArFromAny(areaRaw),
      error: (_, __) => FixedLocations.labelArFromAny(areaRaw),
    );

    final cityShown =
        (cityRaw.trim().isEmpty) ? '' : (cityAr.trim().isEmpty ? cityRaw : cityAr);

    final areaShown =
        (areaRaw.trim().isEmpty) ? '' : (areaAr.trim().isEmpty ? areaRaw : areaAr);

    final hasCity = cityShown.trim().isNotEmpty && !_isPlaceholder(cityShown);
    final hasArea = areaShown.trim().isNotEmpty && !_isPlaceholder(areaShown);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: EdgeInsets.only(bottom: SizeConfig.h(10)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SizeConfig.radius(18)),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onDetailsTap,
                borderRadius: BorderRadius.circular(SizeConfig.radius(18)),
                child: Padding(
                  padding: SizeConfig.padding(all: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              booking.serviceNameAr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.title18.copyWith(
                                fontSize: SizeConfig.ts(15),
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _statusLabel,
                              style: AppTextStyles.label12.copyWith(
                                fontSize: SizeConfig.ts(11),
                                fontWeight: FontWeight.w800,
                                color: _statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: SizeConfig.h(10)),

                      Row(
                        children: [
                          Container(
                            width: SizeConfig.w(44),
                            height: SizeConfig.w(44),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: avatar,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              initials,
                              style: AppTextStyles.body14.copyWith(
                                fontSize: SizeConfig.ts(14),
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: SizeConfig.w(10)),
                          Expanded(
                            child: Text(
                              booking.customerName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.body14.copyWith(
                                fontSize: SizeConfig.ts(13.2),
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          SizedBox(width: SizeConfig.w(10)),
                          Icon(
                            Icons.chevron_left_rounded,
                            color: AppColors.textSecondary,
                            size: SizeConfig.ts(22),
                          ),
                        ],
                      ),

                      if (showContactHint) ...[
                        SizedBox(height: SizeConfig.h(10)),
                        const _ContactHiddenHint(),
                      ],

                      if (showNotes) ...[
                        SizedBox(height: SizeConfig.h(10)),
                        Container(
                          padding: SizeConfig.padding(horizontal: 10, vertical: 9),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Row(
                            children: [
                              const Text('📝'),
                              SizedBox(width: SizeConfig.w(8)),
                              Expanded(
                                child: Text(
                                  notes,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                  style: AppTextStyles.body14.copyWith(
                                    fontSize: SizeConfig.ts(12.2),
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondary,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      SizedBox(height: SizeConfig.h(12)),

                      Row(
                        children: [
                          _Meta(
                            Icons.calendar_today_outlined,
                            _dateNice(booking.bookingDate),
                          ),
                          SizedBox(width: SizeConfig.w(12)),
                          _Meta(
                            Icons.access_time,
                            _time12hAr(booking.bookingTime),
                          ),
                          const Spacer(),
                          Container(
                            width: SizeConfig.w(44),
                            height: SizeConfig.w(44),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
                              color: AppColors.lightGreen.withValues(alpha: 0.12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              booking.status == 'pending_provider_accept' ? '📩' : '🧳',
                              style: AppTextStyles.body16.copyWith(
                                fontSize: SizeConfig.ts(20),
                                height: 1,
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (hasCity || hasArea) ...[
                        SizedBox(height: SizeConfig.h(10)),
                        Wrap(
                          spacing: SizeConfig.w(8),
                          runSpacing: SizeConfig.h(8),
                          alignment: WrapAlignment.start,
                          children: [
                            if (hasCity)
                              _MiniChip(
                                icon: Icons.location_city_outlined,
                                text: cityShown,
                              ),
                            if (hasArea)
                              _MiniChip(
                                icon: Icons.place_outlined,
                                text: areaShown,
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            if (canShowPendingActions || canShowUpcomingActions) ...[
              Divider(
                height: 1,
                color: AppColors.borderLight.withValues(alpha: 0.9),
              ),
              Padding(
                padding: SizeConfig.padding(horizontal: 14, vertical: 12),
                child: _buildActions(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    if (_isPending) {
      return Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
            child: _PrimaryBtn(
              label: 'قبول',
              isLoading: busy,
              onTap: (busy || onAccept == null) ? null : onAccept,
            ),
          ),
          SizedBox(width: SizeConfig.w(10)),
          Expanded(
            child: _DangerOutlineBtn(
              label: 'إلغاء',
              onTap: (busy || onCancel == null) ? null : onCancel,
            ),
          ),
        ],
      );
    }

    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Expanded(
          child: _PrimaryBtn(
            label: 'إنهاء الخدمة',
            isLoading: busy,
            onTap: (busy || onComplete == null) ? null : onComplete,
          ),
        ),
        SizedBox(width: SizeConfig.w(10)),
        Expanded(
          child: _DangerOutlineBtn(
            label: 'إلغاء الخدمة',
            onTap: (busy || onCancel == null) ? null : onCancel,
          ),
        ),
      ],
    );
  }
}

// ---------------- UI widgets ----------------

class _ContactHiddenHint extends StatelessWidget {
  const _ContactHiddenHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SizeConfig.padding(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: SizeConfig.w(30),
            height: SizeConfig.w(30),
            decoration: BoxDecoration(
              color: AppColors.lightGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(SizeConfig.radius(10)),
              border: Border.all(
                color: AppColors.lightGreen.withValues(alpha: 0.22),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '🔒',
              style: TextStyle(
                fontSize: SizeConfig.ts(14),
                height: 1.0,
              ),
            ),
          ),
          SizedBox(width: SizeConfig.w(10)),
          Expanded(
            child: Text(
              'بيانات التواصل (الهاتف/الإيميل) تظهر بعد قبول الطلب.',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: AppTextStyles.body14.copyWith(
                fontSize: SizeConfig.ts(12.2),
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          text,
          style: AppTextStyles.body14.copyWith(
            fontSize: SizeConfig.ts(12),
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.w(10),
        vertical: SizeConfig.h(7),
      ),
      decoration: BoxDecoration(
        color: AppColors.lightGreen.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(SizeConfig.radius(999)),
        border: Border.all(
          color: AppColors.lightGreen.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: [
          Icon(
            icon,
            size: SizeConfig.ts(14),
            color: AppColors.textSecondary,
          ),
          SizedBox(width: SizeConfig.w(6)),
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body14.copyWith(
              fontSize: SizeConfig.ts(12),
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;

  const _PrimaryBtn({
    required this.label,
    required this.onTap,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightGreen,
        elevation: 0,
        padding: SizeConfig.padding(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
        ),
      ),
      child: isLoading
          ? SizedBox(
              width: SizeConfig.w(18),
              height: SizeConfig.w(18),
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(
              label,
              style: AppTextStyles.body14.copyWith(
                fontSize: SizeConfig.ts(13),
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
    );
  }
}

/// ✅ QA: زر إلغاء أحمر كامل
class _DangerOutlineBtn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _DangerOutlineBtn({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: SizeConfig.padding(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.body14.copyWith(
          fontSize: SizeConfig.ts(13),
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }
}
