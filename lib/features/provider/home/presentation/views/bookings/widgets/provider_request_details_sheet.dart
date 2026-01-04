import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/constants/color_x.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/provider/home/data/models/provider_booking_model.dart';

import 'package:beitak_app/core/constants/fixed_service_categories.dart';
import 'package:beitak_app/core/constants/fixed_locations.dart';
import 'package:beitak_app/core/providers/areas_name_map_provider.dart';

class ProviderBookingDetailsSheet extends ConsumerWidget {
  final ProviderBookingModel booking;
  final VoidCallback onClose;

  const ProviderBookingDetailsSheet({
    super.key,
    required this.booking,
    required this.onClose,
  });

  // ---------------- Helpers ----------------

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

  String _serviceTitleAr(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return '—';

    final key = FixedServiceCategories.keyFromAnyString(s);
    if (key != null) return FixedServiceCategories.labelArFromKey(key);

    final hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(s);
    return hasArabic ? s : s;
  }

  String _formatTime(String hhmmss) {
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

  String _formatDurationHours(double h) {
    final v = h.round();
    if (v <= 0) return '—';
    if (v == 1) return 'ساعة';
    if (v == 2) return 'ساعتين';
    return '$v ساعات';
  }

  String _dateNice(String d) =>
      d.trim().isEmpty ? '—' : d.trim().replaceAll('-', '/');

  // ---------- Location split ----------
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

  // ✅ نفس فكرة TodayTask: normalize -> tokens
  String _norm(String s) {
    var x = s.trim().toLowerCase();
    if (x.isEmpty) return '';

    x = x
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه');

    // كل شيء غير عربي/لاتيني/أرقام/مسافة -> مسافة
    x = x.replaceAll(RegExp(r'[^\u0600-\u06FFa-z0-9\s]'), ' ');
    x = x.replaceAll(RegExp(r'\s+'), ' ').trim();
    return x;
  }

  Set<String> _tokens(String s) {
    final n = _norm(s);
    if (n.isEmpty) return {};
    return n.split(' ').where((t) => t.trim().isNotEmpty).toSet();
  }

  /// ✅ نفس المنطق الزابط عندك:
  /// نخفي العنوان إذا كان مكرر للموقع حتى لو لغة مختلفة
  bool _shouldShowAddress({
    required String address,
    required String locationAr,
    required String locationRaw,
  }) {
    final addrTokens = _tokens(address);
    if (addrTokens.isEmpty) return false;

    final locTokens = <String>{
      ..._tokens(locationRaw), // غالباً إنجليزي (من السيرفر)
      ..._tokens(locationAr), // عربي (المعروض)
    };

    if (locTokens.isEmpty) return true;

    // إذا كل كلمات العنوان موجودة داخل كلمات الموقع => مكرر
    final addrIsSubset = addrTokens.difference(locTokens).isEmpty;
    if (addrIsSubset) return false;

    // إذا overlap عالي => مكرر
    final intersection = addrTokens.intersection(locTokens);
    final overlapRatio =
        intersection.isEmpty ? 0.0 : (intersection.length / addrTokens.length);
    if (overlapRatio >= 0.9 && addrTokens.length <= locTokens.length + 1) {
      return false;
    }

    // شيل كلمات الموقع من العنوان، إذا ما ضل شيء مفيد نخفيه
    final remainder = addrTokens.difference(locTokens);

    const generic = {
      'jordan',
      'jo',
      'amman',
      'abdoun',
      'abdun',
      'abdoon',
      'street',
      'st',
      'road',
      'rd',
      'building',
      'bldg',
      'apt',
      'apartment',
      'area',
      'near',
      'الاردن',
      'عمان',
      'عبدون',
      'شارع',
      'طريق',
      'بنايه',
      'عماره',
      'شقه',
      'منطقه',
      'بالقرب',
    };

    final remainderUseful =
        remainder.where((t) => t.length >= 3 && !generic.contains(t)).toList();

    if (remainderUseful.isEmpty) return false;

    return true;
  }

  // ---------- Package translation ----------
  String _packageLabelAr(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return '';

    // لو عربي خلّيه
    final hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(s);
    if (hasArabic) return s;

    final n = s.toLowerCase().trim();

    if (n == 'standard' || n == 'normal' || n == 'basic') return 'عادي';
    if (n == 'premium' || n == 'featured' || n == 'vip') return 'مميز';
    if (n == 'urgent' || n == 'express' || n == 'rush') return 'مستعجل';

    return s;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig.init(context);

    final mq = MediaQuery.of(context);
    final screenH = mq.size.height;
    final heightFactor = (screenH < 720 ? 0.94 : 0.86).clamp(0.82, 0.96);

    final b = booking;

    final date = _dateNice(b.bookingDate);
    final time = _formatTime(b.bookingTime);
    final duration = _formatDurationHours(b.durationHours);

    // ✅ تنظيف القيم
    final address = _clean(b.serviceAddress);
    final desc = _clean(b.serviceDescription);
    final notes = _clean(b.customerNotes);
    final packageRaw = _clean(b.packageSelected);
    final packageAr = _packageLabelAr(packageRaw);

    final hasAddress = address.isNotEmpty;
    final hasDesc = desc.isNotEmpty;
    final hasNotes = notes.isNotEmpty;
    final hasPackage = packageAr.isNotEmpty;

    final addons = b.addOnsSelected;
    final addonsPreview = addons.length <= 4 ? addons : addons.take(4).toList();
    final remainingAddons = addons.length - addonsPreview.length;

    // ✅ قبل القبول: اخفاء بيانات التواصل
    final isPending = b.status == 'pending_provider_accept';
    final showContactInfo = !isPending;

    // ✅ ماب المناطق من السيرفر
    final areasMapAsync = ref.watch(areasNameMapProvider);

    // ✅ locationRaw من السيرفر (غالباً "Amman, Abdoun")
    final locationRaw = _clean(b.locationText);

    // ✅ نطلع City + Area (عمان، عبدون)
    final locParts = _splitCityArea(locationRaw);
    final cityRaw = locParts.isNotEmpty ? locParts[0] : '';
    final areaRaw = locParts.length > 1 ? locParts[1] : '';

    final locationAr = areasMapAsync.when(
      data: (m) {
        final cityAr = _clean(FixedLocations.labelArFromAny(cityRaw, map: m));
        final areaAr = _clean(FixedLocations.labelArFromAny(areaRaw, map: m));

        final cityShown = cityAr.isNotEmpty ? cityAr : _clean(cityRaw);
        final areaShown = areaAr.isNotEmpty ? areaAr : _clean(areaRaw);

        final hasCity = cityShown.isNotEmpty && !_isPlaceholder(cityShown);
        final hasArea = areaShown.isNotEmpty && !_isPlaceholder(areaShown);

        if (hasCity && hasArea) return '$cityShown، $areaShown';
        if (hasCity) return cityShown;
        if (hasArea) return areaShown;

        // fallback أخير
        final full = _clean(FixedLocations.labelArFromAny(locationRaw, map: m));
        return full.isNotEmpty ? full : (locationRaw.isNotEmpty ? locationRaw : '—');
      },
      loading: () {
        // أثناء التحميل: لا تكسر.. اعرض raw
        return locationRaw.isNotEmpty ? locationRaw : '—';
      },
      error: (_, __) {
        return locationRaw.isNotEmpty ? locationRaw : '—';
      },
    );

    // ✅ show address فقط إذا مش مكرر (نفس فكرة TodayTask بالضبط)
    final showAddress = hasAddress &&
        _shouldShowAddress(
          address: address,
          locationAr: locationAr,
          locationRaw: locationRaw,
        );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: heightFactor,
            widthFactor: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(SizeConfig.radius(22))),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.o(0.12),
                    blurRadius: 22,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  left: SizeConfig.w(16),
                  right: SizeConfig.w(16),
                  top: SizeConfig.h(12),
                  bottom: SizeConfig.h(12) + mq.padding.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _SheetHandle(),
                    SizedBox(height: SizeConfig.h(10)),

                    Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        Expanded(
                          child: Text(
                            'تفاصيل الحجز',
                            textAlign: TextAlign.right,
                            style: AppTextStyles.title18.copyWith(
                              fontSize: SizeConfig.ts(16.5),
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: onClose,
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),

                    _InfoCard(
                      title: _serviceTitleAr(b.serviceName),
                      subtitle:
                          'رقم الحجز: ${_clean(b.bookingNumber).isEmpty ? '—' : _clean(b.bookingNumber)}',
                      trailing: Text(
                        '${b.totalPrice.toStringAsFixed(0)} د.أ',
                        style: AppTextStyles.body14.copyWith(
                          fontSize: SizeConfig.ts(13.2),
                          fontWeight: FontWeight.w900,
                          color: AppColors.lightGreen,
                        ),
                      ),
                    ),

                    SizedBox(height: SizeConfig.h(10)),

                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _SectionTitle('الموعد والمكان'),
                            SizedBox(height: SizeConfig.h(6)),
                            _KeyValue('📅', 'التاريخ', date),
                            _KeyValue('🕘', 'الوقت', time),
                            _KeyValue('⏱️', 'المدة', duration),

                            // ✅ المنطقة: City + Area
                            _KeyValue('📍', 'المنطقة', locationAr),

                            // ✅ العنوان فقط إذا مش مكرر
                            if (showAddress) _KeyValue('🏠', 'العنوان', address, maxLines: 2),

                            SizedBox(height: SizeConfig.h(10)),

                            const _SectionTitle('العميل'),
                            SizedBox(height: SizeConfig.h(6)),
                            _KeyValue(
                              '👤',
                              'الاسم',
                              _clean(b.customerName).isEmpty ? '—' : _clean(b.customerName),
                            ),

                            if (showContactInfo) ...[
                              if (b.customerPhone != null && _clean(b.customerPhone).isNotEmpty)
                                _KeyValue('📞', 'الهاتف', _clean(b.customerPhone)),
                              if (b.customerEmail != null && _clean(b.customerEmail).isNotEmpty)
                                _KeyValue('✉️', 'الإيميل', _clean(b.customerEmail)),
                            ] else ...[
                              SizedBox(height: SizeConfig.h(10)),
                              const _PrivacyNoticeCard(
                                text:
                                    '🔒 بيانات التواصل مخفية حالياً.\nستظهر رقم الهاتف والإيميل بعد قبول الطلب.',
                              ),
                            ],

                            if (hasDesc || hasPackage || addons.isNotEmpty || hasNotes) ...[
                              SizedBox(height: SizeConfig.h(10)),
                              const _SectionTitle('تفاصيل إضافية'),
                              SizedBox(height: SizeConfig.h(6)),

                              if (hasDesc)
                                _MultiLineCard(
                                  title: 'وصف الخدمة',
                                  text: desc,
                                  maxLines: 3,
                                ),

                              if (hasPackage || addons.isNotEmpty)
                                _CompactCard(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      if (hasPackage) _KeyValue('📦', 'الباقة', packageAr),

                                      if (addonsPreview.isNotEmpty) ...[
                                        SizedBox(height: SizeConfig.h(8)),
                                        Wrap(
                                          spacing: SizeConfig.w(8),
                                          runSpacing: SizeConfig.h(8),
                                          children: [
                                            ...addonsPreview.map((t) => _ChipPill(label: t)),
                                            if (remainingAddons > 0)
                                              _ChipPill(label: '+$remainingAddons'),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                              if (hasNotes)
                                _MultiLineCard(
                                  title: 'ملاحظات العميل',
                                  text: notes,
                                  maxLines: 3,
                                ),
                            ],

                            SizedBox(height: SizeConfig.h(14)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// -------- UI Widgets (كما هي) --------

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 44,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget trailing;

  const _InfoCard({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SizeConfig.padding(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body16.copyWith(
                    fontSize: SizeConfig.ts(14.2),
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: SizeConfig.h(6)),
                Text(
                  subtitle,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body14.copyWith(
                    fontSize: SizeConfig.ts(12.4),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: SizeConfig.w(10)),
          trailing,
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.right,
      style: AppTextStyles.body14.copyWith(
        fontSize: SizeConfig.ts(13.2),
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _KeyValue extends StatelessWidget {
  final String icon;
  final String keyText;
  final String valueText;
  final int maxLines;

  const _KeyValue(this.icon, this.keyText, this.valueText, {this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    final v = valueText.trim().isEmpty ? '—' : valueText.trim();

    return Padding(
      padding: EdgeInsets.only(top: SizeConfig.h(8)),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: AppTextStyles.body14.copyWith(fontSize: SizeConfig.ts(14))),
          SizedBox(width: SizeConfig.w(8)),
          Text(
            '$keyText: ',
            textAlign: TextAlign.right,
            style: AppTextStyles.body14.copyWith(
              fontSize: SizeConfig.ts(12.6),
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          Expanded(
            child: Text(
              v,
              textAlign: TextAlign.right,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body14.copyWith(
                fontSize: SizeConfig.ts(12.6),
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyNoticeCard extends StatelessWidget {
  final String text;
  const _PrivacyNoticeCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SizeConfig.padding(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: SizeConfig.w(34),
            height: SizeConfig.w(34),
            decoration: BoxDecoration(
              color: AppColors.lightGreen.o(0.12),
              borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
              border: Border.all(color: AppColors.lightGreen.o(0.25)),
            ),
            alignment: Alignment.center,
            child: Text(
              '🔒',
              style: TextStyle(fontSize: SizeConfig.ts(16), height: 1.0),
            ),
          ),
          SizedBox(width: SizeConfig.w(10)),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.right,
              style: AppTextStyles.body14.copyWith(
                fontSize: SizeConfig.ts(12.2),
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactCard extends StatelessWidget {
  final Widget child;
  const _CompactCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: SizeConfig.h(8)),
      padding: SizeConfig.padding(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: child,
    );
  }
}

class _MultiLineCard extends StatelessWidget {
  final String title;
  final String text;
  final int maxLines;

  const _MultiLineCard({
    required this.title,
    required this.text,
    required this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return _CompactCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.right,
            style: AppTextStyles.body14.copyWith(
              fontSize: SizeConfig.ts(12.6),
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: SizeConfig.h(6)),
          Text(
            text.trim(),
            textAlign: TextAlign.right,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.body14.copyWith(
              fontSize: SizeConfig.ts(12.6),
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipPill extends StatelessWidget {
  final String label;
  const _ChipPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: SizeConfig.padding(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.lightGreen.o(0.10),
        borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
        border: Border.all(color: AppColors.lightGreen.o(0.25)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.right,
        style: AppTextStyles.body14.copyWith(
          fontSize: SizeConfig.ts(12),
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
