// import 'package:beitak_app/core/constants/colors.dart';
// import 'package:beitak_app/core/helpers/size_config.dart';
// import 'package:beitak_app/features/user/home/presentation/views/browse/widgets/service_details_models.dart';
// import 'package:flutter/material.dart';

// class BookingDraft {
//   final DateTime date;
//   final TimeOfDay time;
//   final String address;
//   final String city;
//   final String area;
//   final String? notes;
//   final String? packageSelected;
//   final List<String> addOnsSelected;

//   const BookingDraft({
//     required this.date,
//     required this.time,
//     required this.address,
//     required this.city,
//     required this.area,
//     required this.addOnsSelected,
//     this.notes,
//     this.packageSelected,
//   });
// }

// class BookingBottomSheet extends StatefulWidget {
//   const BookingBottomSheet({
//     super.key,
//     required this.service,
//   });

//   final ServiceDetails service;

//   @override
//   State<BookingBottomSheet> createState() => _BookingBottomSheetState();
// }

// class _BookingBottomSheetState extends State<BookingBottomSheet> {
//   DateTime? _selectedDate;
//   TimeOfDay? _selectedTime;

//   final _addressCtrl = TextEditingController();
//   final _cityCtrl = TextEditingController(text: 'amman');

//   // لو مزود الخدمة عنده مناطق، بنخليها Dropdown
//   String? _selectedArea;
//   final _areaCtrl = TextEditingController();

//   final _notesCtrl = TextEditingController();

//   String? _packageSelected;
//   final Set<String> _addOns = <String>{};

//   String? _error;

//   @override
//   void initState() {
//     super.initState();

//     if (widget.service.packages.isNotEmpty) {
//       _packageSelected = widget.service.packages.first.name;
//     }

//     final areas = widget.service.provider.serviceAreas;
//     if (areas.isNotEmpty) {
//       _selectedArea = areas.first;
//       _areaCtrl.text = areas.first; // للتوافق لو بدنا نرسل string
//     }
//   }

//   @override
//   void dispose() {
//     _addressCtrl.dispose();
//     _cityCtrl.dispose();
//     _areaCtrl.dispose();
//     _notesCtrl.dispose();
//     super.dispose();
//   }

//   DateTime get _minAllowedDateTime {
//     final now = DateTime.now();
//     return now.add(Duration(hours: widget.service.minAdvanceBookingHours));
//   }

//   DateTime get _maxAllowedDateTime {
//     final now = DateTime.now();
//     return now.add(Duration(days: widget.service.maxAdvanceBookingDays));
//   }

//   bool _isAllowedDay(DateTime date) {
//     final allowed = widget.service.provider.availableDays.map((e) => e.toLowerCase()).toSet();
//     if (allowed.isEmpty) return true;
//     return allowed.contains(_weekdayKey(date.weekday));
//   }

//   String _weekdayKey(int weekday) {
//     switch (weekday) {
//       case DateTime.monday:
//         return 'monday';
//       case DateTime.tuesday:
//         return 'tuesday';
//       case DateTime.wednesday:
//         return 'wednesday';
//       case DateTime.thursday:
//         return 'thursday';
//       case DateTime.friday:
//         return 'friday';
//       case DateTime.saturday:
//         return 'saturday';
//       case DateTime.sunday:
//         return 'sunday';
//       default:
//         return 'monday';
//     }
//   }

//   TimeOfDay _parseHHmm(String hhmm) {
//     final parts = hhmm.split(':');
//     final h = int.tryParse(parts.first) ?? 0;
//     final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
//     return TimeOfDay(hour: h, minute: m);
//   }

//   bool _isWithinWorkingHours(TimeOfDay t) {
//     final start = _parseHHmm(widget.service.provider.workingHours.start);
//     final end = _parseHHmm(widget.service.provider.workingHours.end);

//     final minutes = t.hour * 60 + t.minute;
//     final startM = start.hour * 60 + start.minute;
//     final endM = end.hour * 60 + end.minute;

//     // لو النهاية أقل من البداية (دوام ليلي) نعتبره يومين - حالياً ما بندعمه، فبنرجّع false
//     if (endM < startM) return false;

//     return minutes >= startM && minutes <= endM;
//   }

//   Future<void> _pickDate() async {
//     final now = DateTime.now();
//     final first = DateTime(now.year, now.month, now.day);
//     final last = first.add(Duration(days: widget.service.maxAdvanceBookingDays));

//     final picked = await showDatePicker(
//       context: context,
//       firstDate: first,
//       lastDate: last,
//       initialDate: _selectedDate ?? first.add(const Duration(days: 1)),
//       builder: (ctx, child) {
//         return Theme(
//           data: Theme.of(ctx).copyWith(
//             colorScheme: ColorScheme.fromSeed(seedColor: AppColors.lightGreen),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (picked == null) return;

//     if (!_isAllowedDay(picked)) {
//       setState(() => _error = 'هذا اليوم غير متاح حسب جدول مزود الخدمة.');
//       return;
//     }

//     setState(() {
//       _selectedDate = picked;
//       _error = null;
//     });
//   }

//   Future<void> _pickTime() async {
//     final picked = await showTimePicker(
//       context: context,
//       initialTime: _selectedTime ?? const TimeOfDay(hour: 10, minute: 0),
//       builder: (ctx, child) {
//         return Theme(
//           data: Theme.of(ctx).copyWith(
//             colorScheme: ColorScheme.fromSeed(seedColor: AppColors.lightGreen),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (picked == null) return;

//     if (!_isWithinWorkingHours(picked)) {
//       setState(() => _error = 'الوقت خارج ساعات عمل مزود الخدمة.');
//       return;
//     }

//     setState(() {
//       _selectedTime = picked;
//       _error = null;
//     });
//   }

//   void _submit() {
//     final date = _selectedDate;
//     final time = _selectedTime;

//     if (date == null || time == null) {
//       setState(() => _error = 'اختر التاريخ والوقت.');
//       return;
//     }

//     final address = _addressCtrl.text.trim();
//     final city = _cityCtrl.text.trim();
//     final area = _areaCtrl.text.trim();

//     if (address.isEmpty || city.isEmpty || area.isEmpty) {
//       setState(() => _error = 'أدخل العنوان والمدينة والمنطقة.');
//       return;
//     }

//     final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);

//     if (dt.isBefore(_minAllowedDateTime)) {
//       setState(() => _error =
//           'الحجز يتطلب وقتًا مسبقًا (${widget.service.minAdvanceBookingHours} ساعة على الأقل).');
//       return;
//     }

//     if (dt.isAfter(_maxAllowedDateTime)) {
//       setState(() => _error =
//           'الحجز يجب أن يكون خلال ${widget.service.maxAdvanceBookingDays} يوم كحد أقصى.');
//       return;
//     }

//     Navigator.pop(
//       context,
//       BookingDraft(
//         date: date,
//         time: time,
//         address: address,
//         city: city,
//         area: area,
//         notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
//         packageSelected: _packageSelected,
//         addOnsSelected: _addOns.toList(),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     SizeConfig.init(context);

//     final areas = widget.service.provider.serviceAreas;

//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: Container(
//         width: double.infinity,
//         padding: EdgeInsets.only(
//           left: SizeConfig.w(16),
//           right: SizeConfig.w(16),
//           top: SizeConfig.h(12),
//           bottom: MediaQuery.of(context).viewInsets.bottom + SizeConfig.h(14),
//         ),
//         decoration: BoxDecoration(
//           color: AppColors.background,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(SizeConfig.radius(22))),
//         ),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: Container(
//                   width: 44,
//                   height: 5,
//                   decoration: BoxDecoration(
//                     color: AppColors.borderLight,
//                     borderRadius: BorderRadius.circular(999),
//                   ),
//                 ),
//               ),
//               SizedBox(height: SizeConfig.h(12)),
//               Text(
//                 'حجز الخدمة',
//                 style: TextStyle(
//                   fontSize: SizeConfig.ts(18),
//                   fontWeight: FontWeight.w900,
//                   color: AppColors.textPrimary,
//                 ),
//               ),
//               SizedBox(height: SizeConfig.h(8)),
//               _infoLine(
//                 'ساعات العمل',
//                 '${widget.service.provider.workingHours.start} - ${widget.service.provider.workingHours.end}',
//               ),
//               if (widget.service.provider.availableDays.isNotEmpty)
//                 _infoLine('الأيام المتاحة', _formatDays(widget.service.provider.availableDays)),

//               SizedBox(height: SizeConfig.h(14)),
//               _sectionTitle('التاريخ والوقت'),
//               Row(
//                 children: [
//                   Expanded(
//                     child: _pillButton(
//                       label: _selectedDate == null ? 'اختر تاريخ' : _fmtDate(_selectedDate!),
//                       icon: Icons.calendar_month,
//                       onTap: _pickDate,
//                     ),
//                   ),
//                   SizedBox(width: SizeConfig.w(10)),
//                   Expanded(
//                     child: _pillButton(
//                       label: _selectedTime == null ? 'اختر وقت' : _fmtTime(_selectedTime!),
//                       icon: Icons.access_time,
//                       onTap: _pickTime,
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: SizeConfig.h(10)),
//               Text(
//                 'مدة الخدمة: ${widget.service.durationHours.toStringAsFixed(0)} ساعة',
//                 style: TextStyle(
//                   fontSize: SizeConfig.ts(13),
//                   color: AppColors.textSecondary,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),

//               SizedBox(height: SizeConfig.h(16)),
//               _sectionTitle('العنوان'),
//               _textField(_addressCtrl, hint: 'العنوان التفصيلي'),
//               SizedBox(height: SizeConfig.h(10)),
//               Row(
//                 children: [
//                   Expanded(child: _textField(_cityCtrl, hint: 'المدينة (مثلاً: amman)', ltr: true)),
//                   SizedBox(width: SizeConfig.w(10)),
//                   Expanded(
//                     child: areas.isEmpty ? _textField(_areaCtrl, hint: 'المنطقة (مثلاً: abdoun)', ltr: true) : _areaDropdown(areas),
//                   ),
//                 ],
//               ),

//               SizedBox(height: SizeConfig.h(16)),
//               if (widget.service.packages.isNotEmpty) ...[
//                 _sectionTitle('الباقات'),
//                 ...widget.service.packages.map((p) {
//                   return RadioListTile<String>(
//                     value: p.name,
//                     groupValue: _packageSelected,
//                     onChanged: (v) => setState(() => _packageSelected = v),
//                     title: Text(
//                       '${p.name} (${p.price.toStringAsFixed(0)} د.أ)',
//                       style: TextStyle(
//                         fontWeight: FontWeight.w900,
//                         fontSize: SizeConfig.ts(14),
//                         color: AppColors.textPrimary,
//                       ),
//                     ),
//                     subtitle: p.description.isEmpty
//                         ? null
//                         : Text(
//                             p.description,
//                             style: TextStyle(color: AppColors.textSecondary, fontSize: SizeConfig.ts(12.5)),
//                           ),
//                     activeColor: AppColors.lightGreen,
//                     contentPadding: EdgeInsets.zero,
//                   );
//                 }),
//                 SizedBox(height: SizeConfig.h(10)),
//               ],

//               if (widget.service.addOns.isNotEmpty) ...[
//                 _sectionTitle('إضافات'),
//                 ...widget.service.addOns.map((a) {
//                   final checked = _addOns.contains(a.name);
//                   return CheckboxListTile(
//                     value: checked,
//                     onChanged: (v) {
//                       setState(() {
//                         if (v == true) {
//                           _addOns.add(a.name);
//                         } else {
//                           _addOns.remove(a.name);
//                         }
//                       });
//                     },
//                     title: Text(
//                       '${a.name} (+${a.price.toStringAsFixed(0)} د.أ)',
//                       style: TextStyle(fontWeight: FontWeight.w900, fontSize: SizeConfig.ts(14), color: AppColors.textPrimary),
//                     ),
//                     subtitle: a.description.isEmpty
//                         ? null
//                         : Text(a.description, style: TextStyle(color: AppColors.textSecondary, fontSize: SizeConfig.ts(12.5))),
//                     activeColor: AppColors.lightGreen,
//                     contentPadding: EdgeInsets.zero,
//                     controlAffinity: ListTileControlAffinity.leading,
//                   );
//                 }),
//                 SizedBox(height: SizeConfig.h(10)),
//               ],

//               _sectionTitle('ملاحظات (اختياري)'),
//               _textField(_notesCtrl, hint: 'اكتب أي تفاصيل تساعد المزود…', maxLines: 3),

//               if (_error != null) ...[
//                 SizedBox(height: SizeConfig.h(12)),
//                 Text(
//                   _error!,
//                   style: TextStyle(
//                     color: Colors.red,
//                     fontWeight: FontWeight.w900,
//                     fontSize: SizeConfig.ts(13),
//                   ),
//                 ),
//               ],

//               SizedBox(height: SizeConfig.h(14)),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _submit,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.lightGreen,
//                     padding: EdgeInsets.symmetric(vertical: SizeConfig.h(12)),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(SizeConfig.radius(16)),
//                     ),
//                   ),
//                   child: Text(
//                     'تأكيد الحجز',
//                     style: TextStyle(
//                       fontSize: SizeConfig.ts(15),
//                       fontWeight: FontWeight.w900,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _areaDropdown(List<String> areas) {
//     return DropdownButtonFormField<String>(
//       value: _selectedArea,
//       items: areas
//           .map((a) => DropdownMenuItem<String>(
//                 value: a,
//                 child: Text(a, textDirection: TextDirection.ltr),
//               ))
//           .toList(),
//       onChanged: (v) {
//         setState(() {
//           _selectedArea = v;
//           _areaCtrl.text = v ?? '';
//         });
//       },
//       decoration: InputDecoration(
//         hintText: 'اختر المنطقة',
//         filled: true,
//         fillColor: AppColors.cardBackground,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: const BorderSide(color: AppColors.borderLight),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: const BorderSide(color: AppColors.borderLight),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: const BorderSide(color: AppColors.lightGreen, width: 1.5),
//         ),
//       ),
//       iconEnabledColor: AppColors.textSecondary,
//     );
//   }

//   Widget _infoLine(String label, String value) {
//     return Padding(
//       padding: EdgeInsets.only(top: SizeConfig.h(4)),
//       child: Row(
//         children: [
//           Text(
//             '$label: ',
//             style: TextStyle(
//               color: AppColors.textSecondary,
//               fontWeight: FontWeight.w800,
//               fontSize: SizeConfig.ts(12.5),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: TextStyle(
//                 color: AppColors.textPrimary,
//                 fontWeight: FontWeight.w900,
//                 fontSize: SizeConfig.ts(12.5),
//               ),
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _fmtDate(DateTime d) =>
//       '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

//   String _fmtTime(TimeOfDay t) =>
//       '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

//   String _formatDays(List<String> days) {
//     // عرض عربي سريع (ممكن نطوره لاحقاً)
//     const map = {
//       'monday': 'الاثنين',
//       'tuesday': 'الثلاثاء',
//       'wednesday': 'الأربعاء',
//       'thursday': 'الخميس',
//       'friday': 'الجمعة',
//       'saturday': 'السبت',
//       'sunday': 'الأحد',
//     };
//     return days.map((d) => map[d] ?? d).join('، ');
//   }

//   Widget _sectionTitle(String t) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: SizeConfig.h(8)),
//       child: Text(
//         t,
//         style: TextStyle(
//           fontSize: SizeConfig.ts(14),
//           fontWeight: FontWeight.w900,
//           color: AppColors.textPrimary,
//         ),
//       ),
//     );
//   }

//   Widget _textField(
//     TextEditingController c, {
//     required String hint,
//     int maxLines = 1,
//     bool ltr = false,
//   }) {
//     return TextField(
//       controller: c,
//       maxLines: maxLines,
//       textDirection: ltr ? TextDirection.ltr : TextDirection.rtl,
//       style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle: const TextStyle(color: AppColors.textSecondary),
//         filled: true,
//         fillColor: AppColors.cardBackground,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: const BorderSide(color: AppColors.borderLight),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: const BorderSide(color: AppColors.borderLight),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: const BorderSide(color: AppColors.lightGreen, width: 1.5),
//         ),
//       ),
//     );
//   }

//   Widget _pillButton({
//     required String label,
//     required IconData icon,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(16),
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: SizeConfig.w(12), vertical: SizeConfig.h(12)),
//         decoration: BoxDecoration(
//           color: AppColors.cardBackground,
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: AppColors.borderLight),
//         ),
//         child: Row(
//           children: [
//             Icon(icon, size: 18, color: AppColors.textSecondary),
//             SizedBox(width: SizeConfig.w(8)),
//             Expanded(
//               child: Text(
//                 label,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//                 style: TextStyle(
//                   fontSize: SizeConfig.ts(13),
//                   fontWeight: FontWeight.w900,
//                   color: AppColors.textPrimary,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
