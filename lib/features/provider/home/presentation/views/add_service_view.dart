import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddServiceView extends StatefulWidget {
  const AddServiceView({super.key});

  @override
  State<AddServiceView> createState() => _AddServiceViewState();
}

class _AddServiceViewState extends State<AddServiceView> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _price = TextEditingController();
  final _categories = [
    'تنظيف', 'تكييف', 'سباكة', 'دهان', 'كهرباء', 'نجارة', 'نقل أثاث'
  ];
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('إنشاء خدمة جديدة'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
            onPressed: () => context.go(AppRoutes.providerHome),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Padding(
          padding: SizeConfig.padding(all: 20),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('اسم الخدمة *'),
                  SizeConfig.v(6),
                  _input(_name, 'مثال: تنظيف المنزل'),

                  SizeConfig.v(20),
                  _label('فئة الخدمة *'),
                  Wrap(
                    spacing: 8,
                    children: _categories.map((c) {
                      final selected = _selected.contains(c);
                      return ChoiceChip(
                        label: Text(c),
                        selected: selected,
                        selectedColor: AppColors.lightGreen,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : AppColors.textPrimary,
                        ),
                        onSelected: (v) {
                          setState(() {
                            v ? _selected.add(c) : _selected.remove(c);
                          });
                        },
                      );
                    }).toList(),
                  ),

                  SizeConfig.v(20),
                  _label('الوصف *'),
                  _input(_desc, 'اشرح تفاصيل الخدمة...', maxLines: 4),

                  SizeConfig.v(20),
                  _label('السعر (د.أ) *'),
                  _input(_price, 'مثال: 25', keyboardType: TextInputType.number),

                  SizeConfig.v(30),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.go(AppRoutes.providerHome),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: const BorderSide(color: AppColors.buttonBackground),
                          ),
                          child: const Text('إلغاء'),
                        ),
                      ),
                      SizeConfig.hSpace(12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.lightGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: SizeConfig.padding(vertical: 14),
                          ),
                          child: const Text('حفظ الخدمة', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: TextStyle(
          fontSize: SizeConfig.ts(14),
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      );

  Widget _input(TextEditingController c, String hint,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: (v) => v!.isEmpty ? 'مطلوب' : null,
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ الخدمة بنجاح'), backgroundColor: AppColors.lightGreen),
      );
      context.go(AppRoutes.providerHome);
    }
  }
}
