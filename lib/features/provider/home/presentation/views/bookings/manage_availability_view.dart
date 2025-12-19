// lib/features/provider/home/presentation/views/bookings/manage_availability_view.dart
import 'package:flutter/material.dart';

import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';

import 'package:beitak_app/features/provider/home/presentation/views/bookings/viewmodels/provider_availability_viewmodel.dart';

class ProviderManageAvailabilityView extends StatefulWidget {
  const ProviderManageAvailabilityView({
    super.key,
    required this.onClose,
    this.scrollController,
  });

  final VoidCallback onClose;
  final ScrollController? scrollController;

  @override
  State<ProviderManageAvailabilityView> createState() =>
      _ProviderManageAvailabilityViewState();
}

class _ProviderManageAvailabilityViewState
    extends State<ProviderManageAvailabilityView> {
  late final ProviderAvailabilityViewModel _vm;

  int _tabIndex = 0; // 0 = أيام العمل, 1 = التقويم

  DateTime _focusedMonth =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _selectedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  @override
  void initState() {
    super.initState();
    _vm = ProviderAvailabilityViewModel();
    // ✅ تحميل البيانات من الباك-إند أول ما تفتح الشاشة
    _vm.loadFromApi();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  int _minutes(TimeOfDay t) => t.hour * 60 + t.minute;

  Future<TimeRange?> _pickRange({
    required TimeOfDay initialStart,
    required TimeOfDay initialEnd,
  }) async {
    final start =
        await showTimePicker(context: context, initialTime: initialStart);
    if (!mounted || start == null) return null;

    final end =
        await showTimePicker(context: context, initialTime: initialEnd);
    if (!mounted || end == null) return null;

    if (_minutes(end) <= _minutes(start)) {
      _snack('وقت النهاية يجب أن يكون بعد وقت البداية.');
      return null;
    }
    return TimeRange(start: start, end: end);
  }

  // ---------------- Calendar helpers ----------------

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isInFocusedMonth(DateTime d) =>
      d.year == _focusedMonth.year && d.month == _focusedMonth.month;

  bool _isToday(DateTime d) =>
      _isSameDate(_dateOnly(d), _dateOnly(DateTime.now()));

  List<DateTime> _buildCalendarCells(DateTime monthFirstDay) {
    // الأسبوع يبدأ من الأحد
    final first = DateTime(monthFirstDay.year, monthFirstDay.month, 1);
    final shift = first.weekday % 7; // Sunday => 0
    final start = first.subtract(Duration(days: shift));
    return List.generate(42, (i) => start.add(Duration(days: i)));
  }

  String _monthTitle(DateTime d) {
    const monthsAr = <String>[
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
    return '${monthsAr[d.month - 1]} ${d.year}';
  }

  String _fullDateLabel(DateTime d) {
    const monthsAr = <String>[
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
    return '${d.year} ${monthsAr[d.month - 1]} ${d.day}';
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return AnimatedBuilder(
      animation: _vm,
      builder: (context, _) {
        return Column(
          children: [
            _header(),
            SizedBox(height: SizeConfig.h(6)),
            Padding(
              padding: SizeConfig.padding(horizontal: 16),
              child: _segmentedTabs(),
            ),
            SizedBox(height: SizeConfig.h(10)),
            Expanded(
              child: ListView(
                controller: widget.scrollController,
                padding: SizeConfig.padding(horizontal: 16, vertical: 12),
                children: [
                  if (_tabIndex == 0)
                    _weeklyTemplate()
                  else
                    _calendarTab(),
                  SizedBox(height: SizeConfig.h(18)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _header() {
    return Padding(
      padding: SizeConfig.padding(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'إدارة التوفر',
              style: TextStyle(
                fontSize: SizeConfig.ts(16.8),
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (_vm.isSaving)
            Padding(
              padding: EdgeInsetsDirectional.only(end: SizeConfig.w(4)),
              child: SizedBox(
                width: 18,
                height: 18,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          IconButton(
            onPressed: () async {
              final ok = await _vm.saveToApi();
              if (!mounted) return;
              if (ok) {
                _snack('تم حفظ التوفر بنجاح.');
              } else {
                _snack('تعذر حفظ التوفر، حاول مرة أخرى.');
              }
              widget.onClose();
            },
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }

  Widget _segmentedTabs() {
    Widget chip(String label, bool selected, VoidCallback onTap) {
      final bg = selected ? AppColors.lightGreen : Colors.white;
      final fg = selected ? Colors.white : AppColors.textPrimary;
      final border = selected ? AppColors.lightGreen : AppColors.borderLight;

      return Expanded(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
            child: Container(
              padding: SizeConfig.padding(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
                border: Border.all(color: border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: fg,
                    fontWeight: FontWeight.w900,
                    fontSize: SizeConfig.ts(12.8),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        chip('أيام العمل', _tabIndex == 0, () => setState(() => _tabIndex = 0)),
        SizedBox(width: SizeConfig.w(10)),
        chip('التقويم', _tabIndex == 1, () => setState(() => _tabIndex = 1)),
      ],
    );
  }

  // =======================
  // 1) Weekly Template UI
  // =======================

  Widget _weeklyTemplate() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'ساعات العمل',
            style: TextStyle(
              fontSize: SizeConfig.ts(14.2),
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: SizeConfig.h(4)),
          Text(
            'حدد أيام وأوقات عملك',
            style: TextStyle(
              fontSize: SizeConfig.ts(12.4),
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: SizeConfig.h(12)),
          _weeklyRow(7, 'الأحد'),
          _divider(),
          _weeklyRow(1, 'الإثنين'),
          _divider(),
          _weeklyRow(2, 'الثلاثاء'),
          _divider(),
          _weeklyRow(3, 'الأربعاء'),
          _divider(),
          _weeklyRow(4, 'الخميس'),
          _divider(),
          _weeklyRow(5, 'الجمعة'),
          _divider(),
          _weeklyRow(6, 'السبت'),
        ],
      ),
    );
  }

  Widget _weeklyRow(int weekday, String label) {
    final day = _vm.weekly[weekday];
    final available = day?.available ?? false;
    final range = day?.range;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: SizeConfig.ts(13.5),
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Switch(
          value: available,
          activeColor: AppColors.lightGreen,
          onChanged: (v) => _vm.toggleWeeklyDay(weekday, v),
        ),
        SizedBox(width: SizeConfig.w(6)),
        if (available)
          InkWell(
            onTap: () async {
              final initial = range ??
                  const TimeRange(
                    start: TimeOfDay(hour: 9, minute: 0),
                    end: TimeOfDay(hour: 17, minute: 0),
                  );

              final picked = await _pickRange(
                initialStart: initial.start,
                initialEnd: initial.end,
              );
              if (picked == null) return;
              _vm.setWeeklyRange(weekday, picked);
            },
            borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.lightGreen.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(SizeConfig.radius(14)),
                border: Border.all(
                  color: AppColors.lightGreen.withValues(alpha: 0.35),
                ),
              ),
              child: Text(
                range == null ? 'تحديد الوقت' : range.format(context),
                style: TextStyle(
                  fontSize: SizeConfig.ts(12),
                  fontWeight: FontWeight.w900,
                  color: AppColors.lightGreen,
                ),
              ),
            ),
          )
        else
          Text(
            'غير متاح',
            style: TextStyle(
              fontSize: SizeConfig.ts(12),
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
            ),
          ),
      ],
    );
  }

  Widget _divider() => Padding(
        padding: EdgeInsets.symmetric(vertical: SizeConfig.h(8)),
        child: Container(
          height: 1,
          color: AppColors.borderLight.withValues(alpha: 0.7),
        ),
      );

  // =======================
  // 2) Calendar UI (closed days only)
  // =======================

  Widget _calendarTab() {
    final cells = _buildCalendarCells(_focusedMonth);

    final closedDays = _vm.exceptions.entries
        .where((e) => e.value.type == AvailabilityExceptionType.closedDay)
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final currentException = _vm.exceptionOf(_selectedDate);
    final isSelectedClosed =
        currentException?.type == AvailabilityExceptionType.closedDay;

    return Column(
      children: [
        // ====== Calendar card ======
        _card(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => setState(() {
                      _focusedMonth = DateTime(
                        _focusedMonth.year,
                        _focusedMonth.month - 1,
                        1,
                      );
                      final first = DateTime(
                        _focusedMonth.year,
                        _focusedMonth.month,
                        1,
                      );
                      _selectedDate = _dateOnly(first);
                    }),
                    icon: const Icon(Icons.chevron_right),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        _monthTitle(_focusedMonth),
                        style: TextStyle(
                          fontSize: SizeConfig.ts(14.8),
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() {
                      _focusedMonth = DateTime(
                        _focusedMonth.year,
                        _focusedMonth.month + 1,
                        1,
                      );
                      final first = DateTime(
                        _focusedMonth.year,
                        _focusedMonth.month,
                        1,
                      );
                      _selectedDate = _dateOnly(first);
                    }),
                    icon: const Icon(Icons.chevron_left),
                  ),
                ],
              ),
              SizedBox(height: SizeConfig.h(6)),
              const Row(
                children: [
                  _Weekday('أحد'),
                  _Weekday('إثن'),
                  _Weekday('ثلا'),
                  _Weekday('أرب'),
                  _Weekday('خم'),
                  _Weekday('جمع'),
                  _Weekday('سبت'),
                ],
              ),
              SizedBox(height: SizeConfig.h(10)),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: cells.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemBuilder: (_, i) {
                  final d = cells[i];
                  final inMonth = _isInFocusedMonth(d);
                  final isSelected = _isSameDate(d, _selectedDate);
                  final isToday = _isToday(d);

                  final ex = _vm.exceptionOf(d);
                  final isClosed = ex?.type ==
                      AvailabilityExceptionType.closedDay;

                  final bg = inMonth ? Colors.white : AppColors.background;
                  Color border =
                      AppColors.borderLight.withValues(alpha: 0.9);

                  if (isSelected) {
                    border = AppColors.lightGreen;
                  }

                  final textColor = inMonth
                      ? AppColors.textPrimary
                      : AppColors.textSecondary.withValues(alpha: 0.35);

                  Widget dayChild = Text(
                    '${d.day}',
                    style: TextStyle(
                      fontSize: SizeConfig.ts(12.6),
                      fontWeight: FontWeight.w900,
                      color: textColor,
                    ),
                  );

                  // اليوم المغلق → دائرة حمراء حول الرقم
                  if (inMonth && isClosed) {
                    dayChild = Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.red,
                          width: 1.6,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${d.day}',
                        style: TextStyle(
                          fontSize: SizeConfig.ts(12.4),
                          fontWeight: FontWeight.w900,
                          color: Colors.red.shade800,
                        ),
                      ),
                    );
                  }

                  return InkWell(
                    onTap: inMonth
                        ? () =>
                            setState(() => _selectedDate = _dateOnly(d))
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: border,
                          width: isSelected ? 1.8 : 1.0,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Center(child: dayChild),
                          if (isToday)
                            Positioned(
                              bottom: 5,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.lightGreen,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: SizeConfig.h(12)),
              const Row(
                children: [
                  _LegendDot(
                    color: Colors.red,
                    label: 'اليوم المغلق (دائرة حمراء)',
                  ),
                  SizedBox(width: 10),
                  _LegendDot(
                    color: AppColors.lightGreen,
                    label: 'اليوم الحالي',
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: SizeConfig.h(12)),

        // ====== Toggle close / open day ======
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (isSelectedClosed) {
                // فتح اليوم
                _vm.clearException(_selectedDate);
              } else {
                // إغلاق اليوم
                _vm.setExceptionClosed(_selectedDate);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isSelectedClosed ? AppColors.lightGreen : Colors.red,
              padding: SizeConfig.padding(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  SizeConfig.radius(14),
                ),
              ),
            ),
            child: Text(
              isSelectedClosed ? 'إلغاء الإغلاق' : 'إغلاق اليوم',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: SizeConfig.ts(12.8),
              ),
            ),
          ),
        ),

        SizedBox(height: SizeConfig.h(12)),

        // ====== Closed days list ======
        _closedDaysCard(closedDays),
      ],
    );
  }

  Widget _closedDaysCard(
    List<MapEntry<DateTime, AvailabilityException>> closedDays,
  ) {
    return Container(
      padding: SizeConfig.padding(all: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'الأيام المغلقة',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: SizeConfig.ts(13.5),
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: SizeConfig.h(8)),
          if (closedDays.isEmpty)
            Text(
              'لا توجد أيام مغلقة حتى الآن.',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: SizeConfig.ts(12),
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            )
          else
            ...closedDays.map(
              (e) => Padding(
                padding: EdgeInsets.only(bottom: SizeConfig.h(6)),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => _vm.clearException(e.key),
                      icon: const Icon(
                        Icons.close,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        _fullDateLabel(e.key),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: SizeConfig.ts(12.5),
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.block,
                      size: 18,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ---------------- small UI helpers ----------------

  Widget _card({required Widget child}) {
    return Container(
      padding: SizeConfig.padding(all: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeConfig.radius(18)),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Weekday extends StatelessWidget {
  const _Weekday(this.t);
  final String t;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          t,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
