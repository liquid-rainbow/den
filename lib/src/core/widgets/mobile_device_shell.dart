import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MobileDeviceShell extends StatelessWidget {
  final Widget child;
  final Color outerBackgroundColor;

  const MobileDeviceShell({
    super.key,
    required this.child,
    this.outerBackgroundColor = const Color(0xFF120A14),
  });

  @override
  Widget build(BuildContext context) {
    final isDesktopOrWeb = kIsWeb ||
        Theme.of(context).platform == TargetPlatform.windows ||
        Theme.of(context).platform == TargetPlatform.macOS ||
        Theme.of(context).platform == TargetPlatform.linux;

    if (isDesktopOrWeb) {
      return Scaffold(
        backgroundColor: outerBackgroundColor,
        body: Center(
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 430,
              maxHeight: 900,
            ),
            margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.7),
                  blurRadius: 60,
                  spreadRadius: 8,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(38),
              child: child,
            ),
          ),
        ),
      );
    }

    return child;
  }
}
