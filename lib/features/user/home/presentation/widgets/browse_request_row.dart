import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:flutter/material.dart';


class BrowseRequestRow extends StatefulWidget {
  const BrowseRequestRow({super.key});

  @override
  State<BrowseRequestRow> createState() => _BrowseRequestRowState();
}

class _BrowseRequestRowState extends State<BrowseRequestRow> {
  String? _selectedGovernorate;
  final List<String> _governorates = [
    'عمان', 'الزرقاء', 'البلقاء', 'مادبا', 'الكرك', 'الطفيلة', 'معان', 'العقبة', 'إربد', 'جرش', 'عجلون', 'المفرق'
  ];

  static final List<String> _popularSearches = [
    'تنظيف المنزل',
    'إصلاح التكييف',
    'خدمات النقل',
    'السباكة',
    'أعمال كهربائية',
    'الدهان',
    'عناية بالحيوانات',
    'عامل ماهر',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // شريط البحث مع اقتراحات شائعة
        RawAutocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return _popularSearches; // عرض الشائع عند التركيز
            }
            return _popularSearches.where((option) => option.contains(textEditingValue.text.toLowerCase()));
          },
          fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
  return TextField(
    controller: textEditingController,
    focusNode: focusNode,
    decoration: InputDecoration(
      hintText: 'ما هي الخدمة التي تحتاجها اليوم؟',
      hintStyle: TextStyle(fontSize: SizeConfig.ts(14), color: AppColors.textSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      filled: true,
      fillColor: AppColors.cardBackground,
      prefixIcon: const Icon(Icons.search, color: AppColors.primaryGreen),
    ),
    onSubmitted: (_) => onFieldSubmitted(),  // Fixed: Ignore String value
  );
},
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topRight,
              child: Material(
                elevation: 4,
                child: SizedBox(
                  height: SizeConfig.h(200), // حد أقصى للقائمة لتقليل scroll
                  child: ListView.builder(
                    padding: SizeConfig.padding(all: 8),
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return GestureDetector(
                        onTap: () => onSelected(option),
                        child: ListTile(
                          title: Text(option),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
        SizeConfig.v(8),
        // المحافظة
        DropdownButtonFormField<String>(
          value: _selectedGovernorate,
          hint: Text('اختر المحافظة', style: TextStyle(fontSize: SizeConfig.ts(14), color: AppColors.textSecondary)),
          items: _governorates.map((gov) => DropdownMenuItem(value: gov, child: Text(gov))).toList(),
          onChanged: (value) {
            setState(() {
              _selectedGovernorate = value;
            });
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SizeConfig.radius(12)),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            filled: true,
            fillColor: AppColors.cardBackground,
          ),
        ),
      ],
    );
  }
}