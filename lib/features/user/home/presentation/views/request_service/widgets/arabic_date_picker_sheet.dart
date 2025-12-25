// lib/features/user/home/presentation/views/request_service/widgets/arabic_date_picker_sheet.dart

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';

Future<DateTime?> showArabicDatePickerSheet({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) async {
  final init = DateTime(initialDate.year, initialDate.month, initialDate.day);
  final first = DateTime(firstDate.year, firstDate.month, firstDate.day);
  final last = DateTime(lastDate.year, lastDate.month, lastDate.day);

  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true, // ✅ مهم لمنع overflow
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (_) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: _ArabicDatePickerSheet(
          initialDate: init,
          firstDate: first,
          lastDate: last,
        ),
      );
    },
  );
}

class _ArabicDatePickerSheet extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const _ArabicDatePickerSheet({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<_ArabicDatePickerSheet> createState() => _ArabicDatePickerSheetState();
}

class _ArabicDatePickerSheetState extends State<_ArabicDatePickerSheet> {
  static const _monthsAr = <String>[
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
    'ديسمبر',
  ];

  // أسبوع يبدأ الأحد
  static const _weekdaysAr = <String>['ح', 'ن', 'ث', 'ر', 'خ', 'ج', 'س'];

  late DateTime _month; // أول يوم بالشهر
  DateTime? _selected;

  @override
  void initState() {
    super.initState();
    _selected = _clamp(widget.initialDate);
    _month = DateTime(_selected!.year, _selected!.month, 1);
  }

  DateTime _clamp(DateTime d) {
    if (d.isBefore(widget.firstDate)) return widget.firstDate;
    if (d.isAfter(widget.lastDate)) return widget.lastDate;
    return d;
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  int _daysInMonth(DateTime m) {
    final next = DateTime(m.year, m.month + 1, 1);
    return next.subtract(const Duration(days: 1)).day;
  }

  // Dart weekday: Mon=1..Sun=7
  // نحتاج offset لأسبوع يبدأ الأحد: Sun=0, Mon=1...Sat=6
  int _startOffsetSunFirst(DateTime firstDayOfMonth) {
    final wd = firstDayOfMonth.weekday;
    if (wd == DateTime.sunday) return 0;
    return wd; // Mon=1..Sat=6
  }

  bool _monthAllowed(DateTime monthStart) {
    final monthEnd = DateTime(monthStart.year, monthStart.month + 1, 1)
        .subtract(const Duration(days: 1));
    return !(monthEnd.isBefore(widget.firstDate) || monthStart.isAfter(widget.lastDate));
  }

  void _prevMonth() {
    final prev = DateTime(_month.year, _month.month - 1, 1);
    if (_monthAllowed(prev)) setState(() => _month = prev);
  }

  void _nextMonth() {
    final next = DateTime(_month.year, _month.month + 1, 1);
    if (_monthAllowed(next)) setState(() => _month = next);
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.60,
      minChildSize: 0.45,
      maxChildSize: 0.85,
      builder: (ctx, scrollController) {
        final canPrev = _monthAllowed(DateTime(_month.year, _month.month - 1, 1));
        final canNext = _monthAllowed(DateTime(_month.year, _month.month + 1, 1));

        final header = '${_monthsAr[_month.month - 1]} ${_month.year}';

        // grid prep
        final daysCount = _daysInMonth(_month);
        final offset = _startOffsetSunFirst(_month);
        const totalCells = 42;

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        return SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 22,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: CustomScrollView(
              controller: scrollController, // ✅ يصير سكرول بدل overflow
              slivers: [
                // handle
                SliverToBoxAdapter(
                  child: Padding(
                    padding: SizeConfig.padding(top: 10, bottom: 8),
                    child: Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),

                // header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: SizeConfig.padding(horizontal: 12, vertical: 4),
                    child: Row(
                      children: [
                        // في RTL: السهم اليمين عادة "الشهر التالي"
                        IconButton(
                          onPressed: canNext ? _nextMonth : null,
                          icon: const Icon(Icons.chevron_right),
                          color: canNext
                              ? AppColors.textPrimary
                              : AppColors.textSecondary.withValues(alpha: 0.35),
                        ),
                        Expanded(
                          child: Text(
                            header,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: SizeConfig.ts(15),
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: canPrev ? _prevMonth : null,
                          icon: const Icon(Icons.chevron_left),
                          color: canPrev
                              ? AppColors.textPrimary
                              : AppColors.textSecondary.withValues(alpha: 0.35),
                        ),
                      ],
                    ),
                  ),
                ),

                // weekdays
                SliverToBoxAdapter(
                  child: Padding(
                    padding: SizeConfig.padding(horizontal: 14, vertical: 6),
                    child: Row(
                      children: [
                        for (final w in _weekdaysAr)
                          Expanded(
                            child: Center(
                              child: Text(
                                w,
                                style: TextStyle(
                                  fontSize: SizeConfig.ts(12),
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // days grid
                SliverPadding(
                  padding: SizeConfig.padding(horizontal: 14, vertical: 6),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, idx) {
                        final dayNum = idx - offset + 1;
                        if (dayNum < 1 || dayNum > daysCount) {
                          return const SizedBox.shrink();
                        }

                        final date = DateTime(_month.year, _month.month, dayNum);

                        final disabled =
                            date.isBefore(widget.firstDate) || date.isAfter(widget.lastDate);

                        final selected =
                            (_selected != null) && _sameDay(date, _selected!);

                        final isToday = _sameDay(date, today);

                        Color bg = Colors.transparent;
                        Color border = AppColors.borderLight;
                        Color txt = AppColors.textPrimary;

                        if (disabled) {
                          txt = AppColors.textSecondary.withValues(alpha: 0.35);
                          border = AppColors.borderLight.withValues(alpha: 0.6);
                        } else if (selected) {
                          bg = AppColors.lightGreen;
                          border = AppColors.lightGreen;
                          txt = Colors.white;
                        } else if (isToday) {
                          bg = AppColors.lightGreen.withValues(alpha: 0.12);
                          border = AppColors.lightGreen.withValues(alpha: 0.60);
                        }

                        return InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: disabled
                              ? null
                              : () => setState(() => _selected = date),
                          child: Container(
                            decoration: BoxDecoration(
                              color: bg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: border),
                            ),
                            child: Center(
                              child: Text(
                                '$dayNum',
                                style: TextStyle(
                                  fontSize: SizeConfig.ts(12),
                                  fontWeight: FontWeight.w900,
                                  color: txt,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: totalCells,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.05, // ✅ يعطي شكل مربعات مرتبة
                    ),
                  ),
                ),

                // actions
                SliverToBoxAdapter(
                  child: Padding(
                    padding: SizeConfig.padding(horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(null),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.borderLight),
                              padding: SizeConfig.padding(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'إلغاء',
                              style: TextStyle(
                                fontSize: SizeConfig.ts(13),
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: SizeConfig.w(10)),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _selected == null
                                ? null
                                : () => Navigator.of(context).pop(_selected),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.lightGreen,
                              padding: SizeConfig.padding(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              'موافق',
                              style: TextStyle(
                                fontSize: SizeConfig.ts(13),
                                fontWeight: FontWeight.w900,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: SizeConfig.padding(bottom: 12),
                    child: Center(
                      child: TextButton(
                        onPressed: () {
                          final d = _clamp(today);
                          setState(() {
                            _selected = d;
                            _month = DateTime(d.year, d.month, 1);
                          });
                        },
                        child: Text(
                          'اختيار اليوم',
                          style: TextStyle(
                            fontSize: SizeConfig.ts(12),
                            fontWeight: FontWeight.w900,
                            color: AppColors.lightGreen,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
