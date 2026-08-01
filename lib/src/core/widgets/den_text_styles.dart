import 'package:flutter/material.dart';
import '../theme/den_colors.dart';

Widget denStepHeadline(String text, {double fontSize = 28, Color? color}) {
  return Text(
    text,
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      color: color ?? DenColors.ink,
    ),
  );
}

Widget denStepSubtext(String text, {double fontSize = 13, Color? color}) {
  return Text(
    text,
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: fontSize,
      color: color ?? DenColors.muted,
    ),
  );
}
