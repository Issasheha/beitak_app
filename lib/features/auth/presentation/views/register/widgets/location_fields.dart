// // lib/features/auth/presentation/views/widgets/location_fields.dart
// import 'package:flutter/material.dart';

// class LocationFields extends StatefulWidget {
//   final bool isProvider;
//   const LocationFields({super.key, required this.isProvider});

//   @override
//   State<LocationFields> createState() => _LocationFieldsState();
// }

// class _LocationFieldsState extends State<LocationFields> {
//   String? _country;
//   String? _city;

//   final _countries = ['الأردن'];
//   final _cities = {'الأردن': ['عمان', 'الزرقاء', 'إربد']};
//   final _areas = {
//     'عمان': ['جبل الحسين', 'الشميساني', 'عبدون'],
//     'الزرقاء': ['الرصيفة', 'الهاشمية'],
//     'إربد': ['الرمثا', 'الحصن'],
//   };

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         _buildDropdown('الدولة *', _countries, (v) => setState(() => _country = v)),
//         const SizedBox(height: 16),
//         _buildDropdown('المدينة *', _country != null ? _cities[_country]! : [], (v) => setState(() => _city = v)),
//         const SizedBox(height: 16),
//         _buildDropdown('المنطقة *', _city != null ? _areas[_city] ?? [] : [], (_) {}),
//       ],
//     );
//   }

//   Widget _buildDropdown(String label, List<String> items, ValueChanged<String?> onChanged) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
//         const SizedBox(height: 8),
//         DropdownButtonFormField<String>(
//           dropdownColor: Colors.white.withValues(alpha: 0.2),
//           value: null,
//           hint: Text('اختر $label', style: const TextStyle(color: Colors.white54)),
//           items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white)))).toList(),
//           onChanged: onChanged,
//           decoration: InputDecoration(
//             filled: true,
//             fillColor: Colors.white.withValues(alpha: 0.2),
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
//             prefixIcon: const Icon(Icons.location_on_outlined, color: Colors.white70),
//           ),
//           validator: (value) => value == null ? 'مطلوب' : null,
//         ),
//       ],
//     );
//   }
// }