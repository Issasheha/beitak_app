import 'package:flutter/material.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/utils/app_text_styles.dart';

import 'service_booking_form_ui.dart';

class DatePickerSheet extends StatefulWidget {
  const DatePickerSheet({
    super.key,
    required this.initial,
    required this.first,
    required this.last,
    required this.isSelectable,
    required this.disabledReason,
  });

  final DateTime initial;
  final DateTime first;
  final DateTime last;

  final bool Function(DateTime day) isSelectable;
  final String? Function(DateTime day) disabledReason;

  static Future<DateTime?> show(
    BuildContext context, {
    required DateTime initial,
    required DateTime first,
    required DateTime last,
    required bool Function(DateTime) isSelectable,
    required String? Function(DateTime) disabledReason,
  }) {
    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          top: false,
          child: DatePickerSheet(
            initial: initial,
            first: first,
            last: last,
            isSelectable: isSelectable,
            disabledReason: disabledReason,
          ),
        ),
      ),
    );
  }

  @override
  State<DatePickerSheet> createState() => _DatePickerSheetState();
}

class _DatePickerSheetState extends State<DatePickerSheet> {
  late DateTime _month;
  DateTime? _selected;

  String? _msg;
  InlineMsgType _msgType = InlineMsgType.info;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
    _month = DateTime(widget.initial.year, widget.initial.month, 1);
  }

  void _showMsg(String text, {InlineMsgType type = InlineMsgType.info}) {
    setState(() {
      _msg = text.trim();
      _msgType = type;
    });
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _monthLabel(DateTime d) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    final m = months[(d.month - 1).clamp(0, 11)];
    return '$m ${d.year}';
  }

  bool _isBeforeMonth(DateTime a, DateTime b) {
    if (a.year != b.year) return a.year < b.year;
    return a.month < b.month;
  }

  bool _isAfterMonth(DateTime a, DateTime b) {
    if (a.year != b.year) return a.year > b.year;
    return a.month > b.month;
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    final firstDayOfMonth = DateTime(_month.year, _month.month, 1);
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;

    // Saturday=0, Sunday=1, Monday=2 ... Friday=6
    int startIndex(DateTime d) {
      final wd = d.weekday; // Mon=1..Sun=7
      if (wd == DateTime.saturday) return 0;
      if (wd == DateTime.sunday) return 1;
      return wd + 1; // Mon->2 ... Fri->6
    }

    final offset = startIndex(firstDayOfMonth);
    final totalCells = offset + daysInMonth;
    final rows = (totalCells / 7).ceil();
    final gridCount = rows * 7;

    final firstMonth = DateTime(widget.first.year, widget.first.month, 1);
    final lastMonth = DateTime(widget.last.year, widget.last.month, 1);

    final canPrev =
        !_isBeforeMonth(DateTime(_month.year, _month.month - 1, 1), firstMonth);
    final canNext =
        !_isAfterMonth(DateTime(_month.year, _month.month + 1, 1), lastMonth);

    return Container(
      margin: EdgeInsets.only(top: SizeConfig.h(120)),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: SizeConfig.h(10)),
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          SizedBox(height: SizeConfig.h(12)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'اختر التاريخ',
                    style: AppTextStyles.screenTitle.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: SizeConfig.ts(15.5),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          if (_msg != null && _msg!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: InlineBanner(
                message: _msg!,
                type: _msgType,
                onClose: () => setState(() => _msg = null),
              ),
            ),
            const SizedBox(height: 10),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: canPrev
                            ? () => setState(() {
                                  _month = DateTime(_month.year, _month.month - 1, 1);
                                })
                            : null,
                        icon: Icon(
                          Icons.chevron_right_rounded,
                          color: canPrev
                              ? AppColors.textPrimary
                              : AppColors.textSecondary.withValues(alpha: 0.35),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            _monthLabel(_month),
                            style: AppTextStyles.body.copyWith(
                              fontSize: SizeConfig.ts(13.8),
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: canNext
                            ? () => setState(() {
                                  _month = DateTime(_month.year, _month.month + 1, 1);
                                })
                            : null,
                        icon: Icon(
                          Icons.chevron_left_rounded,
                          color: canNext
                              ? AppColors.textPrimary
                              : AppColors.textSecondary.withValues(alpha: 0.35),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _Dow('س'),
                      _Dow('ح'),
                      _Dow('ن'),
                      _Dow('ث'),
                      _Dow('ر'),
                      _Dow('خ'),
                      _Dow('ج'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: gridCount,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemBuilder: (context, index) {
                      final dayNum = index - offset + 1;
                      if (dayNum < 1 || dayNum > daysInMonth) {
                        return const SizedBox.shrink();
                      }

                      final day = DateTime(_month.year, _month.month, dayNum);
                      final selectable = widget.isSelectable(day);
                      final selected = _selected != null && _sameDay(_selected!, day);

                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          if (selectable) {
                            setState(() => _selected = day);
                          } else {
                            final reason =
                                widget.disabledReason(day) ?? 'هذا اليوم غير متاح.';
                            _showMsg(reason, type: InlineMsgType.info);
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.lightGreen
                                : (selectable ? Colors.white : AppColors.background),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? AppColors.lightGreen
                                  : (selectable
                                      ? AppColors.borderLight
                                      : AppColors.borderLight.withValues(alpha: 0.35)),
                            ),
                          ),
                          child: Text(
                            '$dayNum',
                            style: AppTextStyles.body.copyWith(
                              fontSize: SizeConfig.ts(13),
                              fontWeight: FontWeight.w900,
                              color: selected
                                  ? Colors.white
                                  : (selectable
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary.withValues(alpha: 0.55)),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.borderLight),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'إلغاء',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _selected == null
                              ? null
                              : () => Navigator.pop(context, _selected),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.lightGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'تأكيد',
                            style: AppTextStyles.body.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: SizeConfig.h(14)),
        ],
      ),
    );
  }
}

class _Dow extends StatelessWidget {
  const _Dow(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: AppTextStyles.body.copyWith(
            fontSize: SizeConfig.ts(12.2),
            fontWeight: FontWeight.w900,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
