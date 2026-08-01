import 'package:flutter/material.dart';
import '../theme/den_colors.dart';

Widget denPrimaryButton({
  required String label,
  required VoidCallback? onPressed,
  IconData? icon,
  bool isLoading = false,
}) {
  final labelStyle = const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1);
  final child = isLoading
      ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
        )
      : (icon == null
          ? Text(label, textAlign: TextAlign.center, style: labelStyle)
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(label, style: labelStyle),
              ],
            ));

  return SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: DenColors.primary,
        foregroundColor: Colors.white,
        elevation: 3,
        disabledBackgroundColor: DenColors.primary.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
      child: child,
    ),
  );
}

Widget denSecondaryButton({
  required String label,
  required VoidCallback onPressed,
}) {
  return SizedBox(
    width: double.infinity,
    height: 50,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: DenColors.primary, width: 1.5),
        foregroundColor: DenColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
      ),
    ),
  );
}
