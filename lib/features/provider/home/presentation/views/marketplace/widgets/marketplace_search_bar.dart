// lib/features/provider/home/presentation/views/marketplace/widgets/marketplace_search_bar.dart

import 'package:beitak_app/core/constants/colors.dart';
import 'package:flutter/material.dart';

class MarketplaceSearchBar extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback onOpenFilters;

  const MarketplaceSearchBar({
    super.key,
    required this.value,
    required this.onChanged,
    required this.onOpenFilters,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ مهم: ما نعمل TextEditingController جديد كل build
    // عشان ما يصير “فقدان” للفوكس/الكيرسر مع كل rebuild
    final controller = TextEditingController.fromValue(
      TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      ),
    );

    return Row(
      children: [
        // ✅ search field (على اليمين في RTL لأنه أول عنصر بالـ Row)
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.lightGreen, width: 1.2),
              color: Colors.white,
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'ابحث عن طلبات الخدمات...',
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                // ✅ أيقونة البحث داخل الحقل
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        // ✅ filter button (على اليسار)
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onOpenFilters,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.tune_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
