import 'package:beitak_app/core/constants/colors.dart';
import 'package:flutter/material.dart';

class PriceRangeResult {
  final bool reset;
  final double? min;
  final double? max;

  const PriceRangeResult.reset()
      : reset = true,
        min = null,
        max = null;

  const PriceRangeResult.apply({required this.min, required this.max})
      : reset = false;
}

class MarketplacePriceRangeSheet extends StatefulWidget {
  final double? initialMin;
  final double? initialMax;

  const MarketplacePriceRangeSheet({
    super.key,
    required this.initialMin,
    required this.initialMax,
  });

  @override
  State<MarketplacePriceRangeSheet> createState() =>
      _MarketplacePriceRangeSheetState();
}

class _MarketplacePriceRangeSheetState extends State<MarketplacePriceRangeSheet> {
  final _minCtrl = TextEditingController();
  final _maxCtrl = TextEditingController();

  String? _error;

  double? _parse(String s) {
    final t = s.trim();
    if (t.isEmpty) return null;
    return double.tryParse(t);
  }

  void _apply() {
    final min = _parse(_minCtrl.text);
    final max = _parse(_maxCtrl.text);

    if (min != null && min < 0) {
      setState(() => _error = 'قيمة "من" يجب أن تكون رقمًا موجبًا.');
      return;
    }
    if (max != null && max < 0) {
      setState(() => _error = 'قيمة "إلى" يجب أن تكون رقمًا موجبًا.');
      return;
    }

    // ✅ أهم QA
    if (min != null && max != null && min > max) {
      setState(() => _error = 'نطاق غير منطقي: "من" يجب أن تكون أقل أو تساوي "إلى".');
      return;
    }

    setState(() => _error = null);

    Navigator.pop(
      context,
      PriceRangeResult.apply(min: min, max: max),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialMin != null) {
      _minCtrl.text = widget.initialMin!.toStringAsFixed(0);
    }
    if (widget.initialMax != null) {
      _maxCtrl.text = widget.initialMax!.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'السعر',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _NumberField(controller: _minCtrl, hint: 'من')),
                  const SizedBox(width: 10),
                  Expanded(child: _NumberField(controller: _maxCtrl, hint: 'إلى')),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(
                  _error!,
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: AppColors.lightGreen, width: 1.2),
                        foregroundColor: AppColors.lightGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () =>
                          Navigator.pop(context, const PriceRangeResult.reset()),
                      child: const Text(
                        'إعادة تعيين',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _apply,
                      child: const Text(
                        'تطبيق',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _NumberField({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightGreen, width: 1.1),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(hintText: hint, border: InputBorder.none),
      ),
    );
  }
}
