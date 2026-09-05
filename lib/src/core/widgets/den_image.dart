import 'dart:io';
import 'package:flutter/material.dart';

ImageProvider denImageProvider(String? pathOrUrl, {String defaultFallback = ''}) {
  final target = (pathOrUrl != null && pathOrUrl.isNotEmpty) ? pathOrUrl : defaultFallback;
  if (target.isEmpty) {
    return const AssetImage('assets/images/placeholder.png'); // safe fallback
  }

  if (target.startsWith('http://') || target.startsWith('https://')) {
    return NetworkImage(target);
  }

  final cleanPath = target.startsWith('file://') ? target.replaceFirst('file://', '') : target;
  return FileImage(File(cleanPath));
}

class DenImage extends StatelessWidget {
  final String? pathOrUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const DenImage({
    super.key,
    required this.pathOrUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final src = pathOrUrl?.trim() ?? '';

    Widget imageWidget;
    if (src.isEmpty) {
      imageWidget = placeholder ??
          Container(
            width: width,
            height: height,
            color: const Color(0xFFF3F0F7),
            child: const Icon(Icons.image_outlined, color: Color(0xFF9CA3AF), size: 28),
          );
    } else if (src.startsWith('http://') || src.startsWith('https://')) {
      imageWidget = Image.network(
        src,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ??
            Container(
              width: width,
              height: height,
              color: const Color(0xFFF3F0F7),
              child: const Icon(Icons.broken_image_outlined, color: Color(0xFF9CA3AF), size: 28),
            ),
      );
    } else {
      final cleanPath = src.startsWith('file://') ? src.replaceFirst('file://', '') : src;
      imageWidget = Image.file(
        File(cleanPath),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ??
            Container(
              width: width,
              height: height,
              color: const Color(0xFFF3F0F7),
              child: const Icon(Icons.broken_image_outlined, color: Color(0xFF9CA3AF), size: 28),
            ),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
