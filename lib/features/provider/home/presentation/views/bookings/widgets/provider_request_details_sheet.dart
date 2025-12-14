import 'package:flutter/material.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/constants/color_x.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/provider/home/data/models/provider_booking_model.dart';

class ProviderBookingDetailsSheet extends StatelessWidget {
  final ProviderBookingModel booking;
  final VoidCallback onClose;

  const ProviderBookingDetailsSheet({
    super.key,
    required this.booking,
    required this.onClose,
  });

  String _formatTime(String hhmmss) {
    final s = hhmmss.trim();
    if (s.isEmpty) return '—';
    final parts = s.split(':');
    if (parts.length < 2) return s;
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
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

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final mq = MediaQuery.of(context);
    final screenH = mq.size.height;

    final heightFactor = (screenH < 720 ? 0.94 : 0.86).clamp(0.82, 0.96);

    final b = booking;

    final date = _dateNice(b.bookingDate);
    final time = _formatTime(b.bookingTime);
    final duration = _formatDurationHours(b.durationHours);

    final hasAddress = (b.serviceAddress ?? '').trim().isNotEmpty;
    final hasDesc = (b.serviceDescription ?? '').trim().isNotEmpty;
    final hasNotes = (b.customerNotes ?? '').trim().isNotEmpty;

    final hasPackage = (b.packageSelected ?? '').trim().isNotEmpty;
    final addons = b.addOnsSelected;
    final addonsPreview = addons.length <= 4 ? addons : addons.take(4).toList();
    final remainingAddons = addons.length - addonsPreview.length;

    // ✅ قبل القبول: اخفاء بيانات التواصل
    final isPending = b.status == 'pending_provider_accept';
    final showContactInfo = !isPending;

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
                      title: b.serviceName,
                      subtitle:
                          'رقم الحجز: ${b.bookingNumber.isEmpty ? '—' : b.bookingNumber}',
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

                    // ✅ FIX: اجعل باقي المحتوى Scrollable لتفادي overflow
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
                            _KeyValue('📍', 'المنطقة', b.locationText),
                            if (hasAddress)
                              _KeyValue('🏠', 'العنوان', b.serviceAddress!,
                                  maxLines: 2),

                            SizedBox(height: SizeConfig.h(10)),

                            const _SectionTitle('العميل'),
                            SizedBox(height: SizeConfig.h(6)),
                            _KeyValue('👤', 'الاسم', b.customerName),

                            // ✅ بعد القبول فقط: الهاتف/الإيميل
                            if (showContactInfo) ...[
                              if (b.customerPhone != null)
                                _KeyValue('📞', 'الهاتف', b.customerPhone!),
                              if (b.customerEmail != null)
                                _KeyValue('✉️', 'الإيميل', b.customerEmail!),
                            ] else ...[
                              SizedBox(height: SizeConfig.h(10)),
                              const _PrivacyNoticeCard(
                                text:
                                    '🔒 بيانات التواصل مخفية حالياً.\nستظهر رقم الهاتف والإيميل بعد قبول الطلب.',
                              ),
                            ],

                            if (hasDesc ||
                                hasPackage ||
                                addons.isNotEmpty ||
                                hasNotes) ...[
                              SizedBox(height: SizeConfig.h(10)),
                              const _SectionTitle('تفاصيل إضافية'),
                              SizedBox(height: SizeConfig.h(6)),

                              if (hasDesc)
                                _MultiLineCard(
                                  title: 'وصف الخدمة',
                                  text: b.serviceDescription!,
                                  maxLines: 3,
                                ),

                              if (hasPackage || addons.isNotEmpty)
                                _CompactCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      if (hasPackage)
                                        _KeyValue('📦', 'الباقة',
                                            b.packageSelected!),
                                      if (addonsPreview.isNotEmpty) ...[
                                        SizedBox(height: SizeConfig.h(8)),
                                        Wrap(
                                          spacing: SizeConfig.w(8),
                                          runSpacing: SizeConfig.h(8),
                                          children: [
                                            ...addonsPreview
                                                .map((t) => _ChipPill(label: t)),
                                            if (remainingAddons > 0)
                                              _ChipPill(
                                                  label: '+$remainingAddons'),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                              if (hasNotes)
                                _MultiLineCard(
                                  title: 'ملاحظات العميل',
                                  text: b.customerNotes!,
                                  maxLines: 3,
                                ),
                            ],

                            // ✅ مسافة نهائية لطيفة داخل السكرول
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
          Text(
            icon,
            style: AppTextStyles.body14.copyWith(
              fontSize: SizeConfig.ts(14),
            ),
          ),
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
