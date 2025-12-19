import 'package:flutter/material.dart';
import 'package:beitak_app/core/helpers/size_config.dart';

class CancelButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const CancelButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: SizeConfig.padding(top: 12),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade700,
            foregroundColor: Colors.white,
            padding: SizeConfig.padding(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'إلغاء الحجز',
                  style: TextStyle(
                    fontSize: SizeConfig.ts(13),
                    fontWeight: FontWeight.w900,
                  ),
                ),
        ),
      ),
    );
  }
}
