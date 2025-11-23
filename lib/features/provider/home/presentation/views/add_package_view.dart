import 'package:beitak_app/core/constants/colors.dart';
import 'package:beitak_app/core/helpers/size_config.dart';
import 'package:beitak_app/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddPackageView extends StatefulWidget {
  const AddPackageView({super.key});

  @override
  State<AddPackageView> createState() => _AddPackageViewState();
}

class _AddPackageViewState extends State<AddPackageView> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _price = TextEditingController();
  final _desc = TextEditingController();
  final _duration = TextEditingController();
  final List<TextEditingController> _services = [TextEditingController()];

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('إنشاء حزمة خدمات'),
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
                  _label('اسم الحزمة *'),
                  _input(_name, 'مثال: باقة صيانة منزلية متكاملة'),

                  SizeConfig.v(20),
                  _label('السعر (د.أ) *'),
                  _input(_price, 'مثال: 120', keyboardType: TextInputType.number),

                  SizeConfig.v(20),
                  _label('الخدمات المشمولة *'),
                  ..._services.mapIndexed((i, controller) => Row(
                        children: [
                          Expanded(
                              child: _input(controller, 'خدمة رقم ${i + 1}')),
                          if (_services.length > 1)
                            IconButton(
                              icon: const Icon(Icons.remove_circle,
                                  color: Colors.red),
                              onPressed: () => setState(() => _services.removeAt(i)),
                            ),
                        ],
                      )),
                  TextButton.icon(
                    onPressed: () =>
                        setState(() => _services.add(TextEditingController())),
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة خدمة'),
                  ),

                  SizeConfig.v(20),
                  _label('وصف الحزمة *'),
                  _input(_desc, 'صف ما تتضمنه هذه الحزمة...', maxLines: 3),

                  SizeConfig.v(20),
                  _label('المدة / الصلاحية'),
                  _input(_duration, 'مثال: صالحة لمدة 30 يوم'),

                  SizeConfig.v(30),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.go(AppRoutes.providerHome),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
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
                          child: const Text('إنشاء الحزمة',
                              style: TextStyle(color: Colors.white)),
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
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 12),
      child: TextFormField(
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
      ),
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('تم إنشاء الحزمة بنجاح'),
        backgroundColor: AppColors.lightGreen,
      ));
      context.go(AppRoutes.providerHome);
    }
  }
}

extension<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(int index, E e) f) sync* {
    var i = 0;
    for (final e in this) {
      yield f(i++, e);
    }
  }
}
