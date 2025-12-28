import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/constants/color_x.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/features/provider/home/data/models/provider_booking_model.dart';

import 'package:beitak_app/core/constants/fixed_service_categories.dart';
import 'package:beitak_app/core/constants/fixed_locations.dart';
import 'package:beitak_app/core/providers/areas_name_map_provider.dart';
import 'package:beitak_app/core/utils/time_format.dart';

class ProviderTodayTaskDetailsSheet extends ConsumerWidget {
  const ProviderTodayTaskDetailsSheet({
    super.key,
    required this.booking,
    required this.onClose,
  });

  final ProviderBookingModel booking;
  final VoidCallback onClose;

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

  String _dateNice(String d) => d.trim().isEmpty ? '—' : d.trim().replaceAll('-', '/');

  // ✅ الوقت موحّد حسب TimeFormat (12-hour عربي)
  String _formatTimeAr(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return '—';
    // إذا أصلاً فيه ص/م خلّيه
    if (s.contains('ص') || s.contains('م')) return s;
    return TimeFormat.timeStringToAr12(s);
  }

  String _formatDurationHours(double h) {
    final v = h.round();
    if (v <= 0) return '—';
    if (v == 1) return 'ساعة';
    if (v == 2) return 'ساعتين';
    return '$v ساعات';
  }

  // ✅ تطبيع عام (عربي/انجليزي) للفصل إلى كلمات
  String _norm(String s) {
    var x = s.trim().toLowerCase();
    if (x.isEmpty) return '';

    x = x
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه');

    x = x.replaceAll(RegExp(r'[^\u0600-\u06FFa-z0-9\s]'), ' ');
    x = x.replaceAll(RegExp(r'\s+'), ' ').trim();
    return x;
  }

  Set<String> _tokens(String s) {
    final n = _norm(s);
    if (n.isEmpty) return {};
    return n.split(' ').where((t) => t.trim().isNotEmpty).toSet();
  }

  bool _shouldShowAddress({
    required String address,
    required String locationAr,
    required String locationRaw,
  }) {
    final addrTokens = _tokens(address);
    if (addrTokens.isEmpty) return false;

    final locTokens = <String>{
      ..._tokens(locationRaw), // غالباً إنجليزي
      ..._tokens(locationAr), // عربي (احتياط)
    };

    if (locTokens.isEmpty) return true;

    // إذا كل كلمات العنوان موجودة داخل كلمات الموقع => مكرر
    final addrIsSubset = addrTokens.difference(locTokens).isEmpty;
    if (addrIsSubset) return false;

    // إذا العنوان قريب جداً من الموقع (overlap عالي) => مكرر
    final intersection = addrTokens.intersection(locTokens);
    final overlapRatio = intersection.isEmpty ? 0.0 : (intersection.length / addrTokens.length);
    if (overlapRatio >= 0.9 && addrTokens.length <= locTokens.length + 1) return false;

    // شيل كلمات الموقع من العنوان، إذا ما ضل شيء "معتبر" نخفيه
    final remainder = addrTokens.difference(locTokens);

    const generic = {
      'jordan', 'jo', 'amman', 'abdoun', 'abdun', 'abdoon',
      'street', 'st', 'road', 'rd', 'building', 'bldg', 'apt', 'apartment',
      'area', 'near',
      'الاردن', 'عمان', 'عبدون', 'شارع', 'طريق', 'بنايه', 'عماره', 'شقه', 'منطقه', 'بالقرب'
    };

    final remainderUseful = remainder.where((t) => t.length >= 3 && !generic.contains(t)).toList();
    if (remainderUseful.isEmpty) return false;

    return true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    SizeConfig.init(context);
    final mq = MediaQuery.of(context);

    final heightFactor = (mq.size.height < 720 ? 0.94 : 0.86).clamp(0.82, 0.96);

    final b = booking;

    final date = _dateNice(_clean(b.bookingDate));
    final time = _formatTimeAr(_clean(b.bookingTime));
    final duration = _formatDurationHours(b.durationHours);

    final address = _clean(b.serviceAddress);
    final desc = _clean(b.serviceDescription);
    final notes = _clean(b.customerNotes);

    final packageName = _clean(b.packageSelected);
    final addons = b.addOnsSelected;
    final hasAddons = addons.isNotEmpty;

    final hasAddress = address.isNotEmpty;
    final hasDesc = desc.isNotEmpty;
    final hasNotes = notes.isNotEmpty;
    final hasPackage = packageName.isNotEmpty;

    // ✅ ماب المناطق من السيرفر
    final areasMapAsync = ref.watch(areasNameMapProvider);

    final locationRaw = _clean(b.locationText);
    final locationAr = areasMapAsync.when(
      data: (m) => FixedLocations.labelArFromAny(locationRaw, map: m),
      loading: () => FixedLocations.labelArFromAny(locationRaw),
      error: (_, __) => FixedLocations.labelArFromAny(locationRaw),
    );

    // ✅ إظهار العنوان فقط إذا مش مكرر (حتى لو لغة مختلفة)
    final showAddress = hasAddress &&
        _shouldShowAddress(address: address, locationAr: locationAr, locationRaw: locationRaw);

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
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(SizeConfig.radius(22)),
                ),
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
                            'تفاصيل مهمة اليوم',
                            textAlign: TextAlign.right,
                            style: TextStyle(
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
                    SizedBox(height: SizeConfig.h(10)),
                    _InfoCard(
                      title: _serviceTitleAr(_clean(b.serviceName)),
                      subtitle: 'العميل: ${_clean(b.customerName).isEmpty ? '—' : _clean(b.customerName)}',
                      trailing: Text(
                        '${b.totalPrice.toStringAsFixed(0)} د.أ',
                        style: TextStyle(
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
                            _KeyValue('📍', 'المنطقة', locationAr),

                            if (showAddress) _KeyValue('🏠', 'العنوان', address, maxLines: 2),

                            SizedBox(height: SizeConfig.h(12)),
                            const _SectionTitle('معلومات العميل'),
                            SizedBox(height: SizeConfig.h(6)),
                            _KeyValue('👤', 'الاسم', _clean(b.customerName).isEmpty ? '—' : _clean(b.customerName)),
                            if (b.customerPhone != null && _clean(b.customerPhone).isNotEmpty)
                              _KeyValue('📞', 'الهاتف', _clean(b.customerPhone)),
                            if (b.customerEmail != null && _clean(b.customerEmail).isNotEmpty)
                              _KeyValue('✉️', 'الإيميل', _clean(b.customerEmail)),

                            if (hasDesc || hasNotes || hasPackage || hasAddons) ...[
                              SizedBox(height: SizeConfig.h(12)),
                              const _SectionTitle('تفاصيل إضافية'),
                              SizedBox(height: SizeConfig.h(6)),
                              if (hasDesc) _MultiLineCard(title: 'وصف الخدمة', text: desc),
                              if (hasPackage) _CompactCard(child: _KeyValue('📦', 'الباقة', packageName)),
                              if (hasAddons)
                                _CompactCard(
                                  child: Wrap(
                                    spacing: SizeConfig.w(8),
                                    runSpacing: SizeConfig.h(8),
                                    children: addons.map((t) => _ChipPill(label: t)).toList(),
                                  ),
                                ),
                              if (hasNotes) _MultiLineCard(title: 'ملاحظات العميل', text: notes),
                            ],
                            SizedBox(height: SizeConfig.h(12)),
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
  const _InfoCard({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget trailing;

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
                  style: TextStyle(
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
                  style: TextStyle(
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
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.right,
      style: TextStyle(
        fontSize: SizeConfig.ts(13.2),
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _KeyValue extends StatelessWidget {
  const _KeyValue(this.icon, this.keyText, this.valueText, {this.maxLines = 1});
  final String icon;
  final String keyText;
  final String valueText;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final v = valueText.trim().isEmpty ? '—' : valueText.trim();

    return Padding(
      padding: EdgeInsets.only(top: SizeConfig.h(8)),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: TextStyle(fontSize: SizeConfig.ts(14), height: 1.0)),
          SizedBox(width: SizeConfig.w(8)),
          Text(
            '$keyText: ',
            style: TextStyle(
              fontSize: SizeConfig.ts(12.6),
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          Expanded(
            child: Text(
              v,
              textAlign: TextAlign.right,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
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

class _CompactCard extends StatelessWidget {
  const _CompactCard({required this.child});
  final Widget child;

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
  const _MultiLineCard({required this.title, required this.text});
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return _CompactCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: SizeConfig.ts(12.6),
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: SizeConfig.h(6)),
          Text(
            text.trim(),
            textAlign: TextAlign.right,
            style: TextStyle(
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
  const _ChipPill({required this.label});
  final String label;

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
        style: TextStyle(
          fontSize: SizeConfig.ts(12),
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          height: 1.1,
        ),
      ),
    );
  }
}
