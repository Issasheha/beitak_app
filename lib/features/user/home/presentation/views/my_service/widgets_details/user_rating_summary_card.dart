import 'package:flutter/material.dart';
import 'package:beitak_app/core/utils/number_format.dart';

class UserRatingSummaryCard extends StatelessWidget {
  final bool hasRated;
  final int? rating;
  final String review;
  final double? amountPaid;
  final String currency;
  final String? ratedAt;
  final VoidCallback? onRate;

  const UserRatingSummaryCard({
    super.key,
    required this.hasRated,
    required this.rating,
    required this.review,
    required this.amountPaid,
    required this.currency,
    required this.ratedAt,
    required this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    final r = rating ?? 0;

    final String? amountText =
        amountPaid == null ? null : NumberFormat.money(amountPaid!);

    final String? ratedAtText =
        (ratedAt == null || ratedAt!.trim().isEmpty)
            ? null
            : NumberFormat.smart(ratedAt!.trim());

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.rate_review_rounded, size: 18),
              const SizedBox(width: 8),
              const Text(
                'تقييمك للمزود',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
              ),
              const Spacer(),
              if (!hasRated)
                TextButton(
                  onPressed: onRate,
                  child: const Text(
                    'قيّم الآن',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (hasRated) ...[
            Row(
              children: List.generate(5, (i) {
                final filled = (i + 1) <= r;
                return Icon(
                  filled ? Icons.star_rounded : Icons.star_border_rounded,
                  size: 20,
                  color: filled
                      ? const Color(0xFFFFC107)
                      : const Color(0xFF9CA3AF),
                );
              }),
            ),
            if (amountText != null) ...[
              const SizedBox(height: 8),
              Text(
                'المبلغ المدفوع: $amountText $currency',
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
              ),
            ],
            if (review.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                review.trim(),
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ],
            if (ratedAtText != null) ...[
              const SizedBox(height: 8),
              Text(
                ratedAtText,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ] else ...[
            const Text(
              'لم تقم بتقييم مزود الخدمة بعد.',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
