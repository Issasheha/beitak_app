import 'package:flutter/material.dart';
import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';

class CancelBookingDialogResult {
  final bool confirmed;
  final String? category;
  final String? note;

  const CancelBookingDialogResult({
    required this.confirmed,
    required this.category,
    required this.note,
  });
}

class CancelBookingDialog {
  CancelBookingDialog._();

  static Future<CancelBookingDialogResult?> show(BuildContext context) async {
    final noteCtrl = TextEditingController();

    const categories = <String>[
      'تغيير الموعد',
      'لم أعد بحاجة للخدمة',
      'وجدت مزود خدمة آخر',
      'سعر غير مناسب',
      'سبب آخر',
    ];

    String? selectedCategory;

    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (ctx, setState) {
              return AlertDialog(
                title: Row(
                  children: [
                    Icon(Icons.cancel_rounded, color: Colors.red.shade700),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'تأكيد إلغاء الطلب',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      tooltip: 'إغلاق',
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(ctx).pop(false),
                    ),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'اختر سبب الإلغاء:',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: categories.map((c) {
                          final isSelected = selectedCategory == c;
                          return InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () => setState(() => selectedCategory = c),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.red.withValues(alpha: 0.12)
                                    : Colors.grey.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.red.withValues(alpha: 0.55)
                                      : Colors.grey.withValues(alpha: 0.20),
                                  width: 1.2,
                                ),
                              ),
                              child: Text(
                                c,
                                style: TextStyle(
                                  fontSize: SizeConfig.ts(12),
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? Colors.red.shade700
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'ملاحظات إضافية (اختياري):',
                        style: TextStyle(
                          fontSize: SizeConfig.ts(13),
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: noteCtrl,
                        maxLines: 2,
                        textDirection: TextDirection.rtl,
                        decoration: InputDecoration(
                          hintText: 'مثلاً: أريد تأجيل الموعد إلى يوم آخر...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: Colors.red.withValues(alpha: 0.55),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text(
                      'رجوع',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('تأكيد الإلغاء'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    final note = noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim();
    noteCtrl.dispose();

    if (ok != true) {
      return const CancelBookingDialogResult(
        confirmed: false,
        category: null,
        note: null,
      );
    }

    return CancelBookingDialogResult(
      confirmed: true,
      category: selectedCategory,
      note: note,
    );
  }
}
