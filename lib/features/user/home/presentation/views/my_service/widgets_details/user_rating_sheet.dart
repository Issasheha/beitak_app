import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/error/error_text.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';
import 'package:beitak_app/features/user/home/presentation/views/my_service/viewmodels/service_details_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserRatingSheet extends ConsumerStatefulWidget {
  final int bookingId;
  final String serviceTitle;
  final String providerName;

  const UserRatingSheet({
    super.key,
    required this.bookingId,
    required this.serviceTitle,
    required this.providerName,
  });

  @override
  ConsumerState<UserRatingSheet> createState() => _UserRatingSheetState();
}

class _UserRatingSheetState extends ConsumerState<UserRatingSheet> {
  int rating = 0;
  final reviewCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  bool isSubmitting = false;

  final FocusNode _reviewFocus = FocusNode();
  final FocusNode _amountFocus = FocusNode();

  final GlobalKey _reviewKey = GlobalKey();
  final GlobalKey _amountKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _reviewFocus.addListener(() {
      if (_reviewFocus.hasFocus) _ensureVisible(_reviewKey);
    });

    _amountFocus.addListener(() {
      if (_amountFocus.hasFocus) _ensureVisible(_amountKey);
    });
  }

  void _ensureVisible(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        alignment: 0.15,
      );
    });
  }

  @override
  void dispose() {
    reviewCtrl.dispose();
    amountCtrl.dispose();
    _reviewFocus.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  double? _parseAmount() {
    final raw = amountCtrl.text.trim().replaceAll(',', '.');
    if (raw.isEmpty) return null;
    return double.tryParse(raw);
  }

  Future<void> _submit() async {
    if (isSubmitting) return;

    if (rating <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر التقييم أولاً')),
      );
      return;
    }

    final amount = _parseAmount();
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل مبلغاً صحيحاً')),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      await ref.read(serviceDetailsControllerProvider.notifier).submitUserRating(
            bookingId: widget.bookingId,
            rating: rating,
            amountPaid: amount,
            review: reviewCtrl.text.trim(),
          );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorText(e))),
      );
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.88,
        minChildSize: 0.55,
        maxChildSize: 0.95,
        builder: (context, sheetScrollController) {
          return Container(
            margin: EdgeInsets.only(top: SizeConfig.h(60)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(SizeConfig.radius(22))),
            ),
            child: SafeArea(
              top: false,
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: SizeConfig.padding(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'قيّم مزود الخدمة',
                              style: AppTextStyles.title18.copyWith(
                                fontSize: SizeConfig.ts(16.5),
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        controller: sheetScrollController,
                        padding: SizeConfig.padding(horizontal: 16, vertical: 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: SizeConfig.padding(horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.lightGreen.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
                                border: Border.all(
                                  color: AppColors.lightGreen.withValues(alpha: 0.18),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: SizeConfig.w(44),
                                    height: SizeConfig.w(44),
                                    decoration: BoxDecoration(
                                      color: AppColors.lightGreen.withValues(alpha: 0.12),
                                      borderRadius:
                                          BorderRadius.circular(SizeConfig.radius(14)),
                                    ),
                                    alignment: Alignment.center,
                                    child: Icon(
                                      Icons.handshake_rounded,
                                      color: AppColors.lightGreen,
                                      size: SizeConfig.w(26),
                                    ),
                                  ),
                                  SizeConfig.hSpace(10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'الخدمة: ${widget.serviceTitle}',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.body14.copyWith(
                                            fontSize: SizeConfig.ts(13.6),
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.textPrimary,
                                            height: 1.2,
                                          ),
                                        ),
                                        SizeConfig.v(2),
                                        Text(
                                          'المزود: ${widget.providerName}',
                                          style: AppTextStyles.body14.copyWith(
                                            fontSize: SizeConfig.ts(12.2),
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizeConfig.v(14),

                            Text(
                              'التقييم',
                              style: AppTextStyles.body14.copyWith(
                                fontSize: SizeConfig.ts(13.2),
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizeConfig.v(8),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (i) {
                                final idx = i + 1;
                                final filled = idx <= rating;
                                return IconButton(
                                  onPressed:
                                      isSubmitting ? null : () => setState(() => rating = idx),
                                  icon: Icon(
                                    filled ? Icons.star_rounded : Icons.star_border_rounded,
                                    size: SizeConfig.ts(34),
                                    color: filled
                                        ? const Color(0xFFFFC107)
                                        : AppColors.textSecondary,
                                  ),
                                );
                              }),
                            ),

                            SizeConfig.v(10),

                            Text(
                              'رأيك (اختياري)',
                              style: AppTextStyles.body14.copyWith(
                                fontSize: SizeConfig.ts(13.2),
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizeConfig.v(6),

                            Container(
                              key: _reviewKey,
                              child: TextField(
                                focusNode: _reviewFocus,
                                controller: reviewCtrl,
                                enabled: !isSubmitting,
                                maxLines: 3,
                                decoration: _inputDeco(
                                  hint: 'مثال: شكراً لك، مزود خدمة رائع…',
                                ),
                              ),
                            ),

                            SizeConfig.v(12),

                            Text(
                              'المبلغ المدفوع (د.أ)',
                              style: AppTextStyles.body14.copyWith(
                                fontSize: SizeConfig.ts(13.2),
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizeConfig.v(6),

                            Container(
                              key: _amountKey,
                              child: TextField(
                                focusNode: _amountFocus,
                                controller: amountCtrl,
                                enabled: !isSubmitting,
                                keyboardType:
                                    const TextInputType.numberWithOptions(decimal: true),
                                decoration: _inputDeco(hint: 'مثال: 50'),
                              ),
                            ),

                            SizeConfig.v(16),
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: SizeConfig.padding(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isSubmitting
                                  ? null
                                  : () => Navigator.of(context).pop(false),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: AppColors.borderLight.withValues(alpha: 0.9),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
                                ),
                                padding: SizeConfig.padding(vertical: 12),
                              ),
                              child: Text(
                                'إلغاء',
                                style: AppTextStyles.body14.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          SizeConfig.hSpace(10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isSubmitting ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.lightGreen,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
                                ),
                                padding: SizeConfig.padding(vertical: 12),
                              ),
                              child: isSubmitting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'إرسال التقييم',
                                      style: AppTextStyles.body14.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDeco({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.body14.copyWith(
        color: AppColors.textSecondary.withValues(alpha: 0.8),
        fontWeight: FontWeight.w400,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
        borderSide: BorderSide(color: AppColors.borderLight.withValues(alpha: 0.9)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
        borderSide: BorderSide(color: AppColors.borderLight.withValues(alpha: 0.9)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
        borderSide: BorderSide(color: AppColors.lightGreen.withValues(alpha: 0.9)),
      ),
      contentPadding: SizeConfig.padding(horizontal: 12, vertical: 10),
    );
  }
}
