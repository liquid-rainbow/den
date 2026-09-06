import 'package:flutter/material.dart';
import '../theme/den_colors.dart';

class DenLogo extends StatelessWidget {
  final double size;
  final bool showBrandName;
  final TextStyle? brandStyle;

  const DenLogo({
    super.key,
    this.size = 36,
    this.showBrandName = false,
    this.brandStyle,
  });

  @override
  Widget build(BuildContext context) {
    final logoWidget = SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/images/den_logo.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Graceful fallback for test environments without asset bundles
          return Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              color: DenColors.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              'D',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: size * 0.5,
              ),
            ),
          );
        },
      ),
    );

    if (!showBrandName) {
      return logoWidget;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        logoWidget,
        const SizedBox(width: 8),
        Text(
          'DEN',
          style: brandStyle ??
              const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: DenColors.primary,
              ),
        ),
      ],
    );
  }
}
