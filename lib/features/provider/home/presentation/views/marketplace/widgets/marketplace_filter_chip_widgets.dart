import 'package:beitak_app/core/constants/colors.dart';
import 'package:flutter/material.dart';

class MenuItem {
  final String label;
  final VoidCallback onTap;
  const MenuItem({required this.label, required this.onTap});
}

class MenuChip extends StatelessWidget {
  final String label;
  final String? value;
  final bool selected;
  final List<MenuItem> items;
  final VoidCallback onOpened;

  const MenuChip({
    super.key,
    required this.label,
    required this.selected,
    required this.items,
    required this.onOpened,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColors.lightGreen : Colors.white;
    final fg = selected ? Colors.white : const Color(0xFF111827);
    final border = selected ? AppColors.lightGreen : const Color(0xFFE5E7EB);

    final v = (value == null || value!.trim().isEmpty) ? null : value!.trim();

    return PopupMenuButton<String>(
      tooltip: '',
      onOpened: onOpened,
      onSelected: (String value) {
        final item = items.firstWhere((e) => e.label == value);
        item.onTap();
      },
      itemBuilder: (context) => items
          .map((e) => PopupMenuItem<String>(
                value: e.label,
                child: Text(e.label),
              ))
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: border, width: 1.1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: fg,
              ),
            ),
            if (v != null) ...[
              const SizedBox(width: 8),
              Text(
                v,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: fg,
                ),
              ),
            ],
            const SizedBox(width: 8),
            Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: fg),
          ],
        ),
      ),
    );
  }
}

class ActionChipX extends StatelessWidget {
  final String label;
  final String? value;
  final bool selected;
  final VoidCallback onTap;

  const ActionChipX({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColors.lightGreen : Colors.white;
    final fg = selected ? Colors.white : const Color(0xFF111827);
    final border = selected ? AppColors.lightGreen : const Color(0xFFE5E7EB);

    final v = (value == null || value!.trim().isEmpty) ? null : value!.trim();

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: border, width: 1.1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: fg,
              ),
            ),
            if (v != null) ...[
              const SizedBox(width: 8),
              Text(
                v,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: fg,
                ),
              ),
            ],
            const SizedBox(width: 8),
            Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: fg),
          ],
        ),
      ),
    );
  }
}

class ToggleChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const ToggleChip({
    super.key,
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColors.lightGreen : Colors.white;
    final fg = selected ? Colors.white : const Color(0xFF111827);
    final border = selected ? AppColors.lightGreen : const Color(0xFFE5E7EB);

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: border, width: 1.1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: fg,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
