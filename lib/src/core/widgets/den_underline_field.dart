import 'package:flutter/material.dart';
import '../theme/den_colors.dart';

Widget denDynamicUnderlineField({
  required String value,
  required String hint,
  required ValueChanged<String> onChanged,
  String? prefix,
  bool autofocus = false,
  TextStyle? style,
}) {
  return DenDynamicUnderlineField(
    value: value,
    hint: hint,
    onChanged: onChanged,
    prefix: prefix,
    autofocus: autofocus,
    style: style,
  );
}

class DenDynamicUnderlineField extends StatefulWidget {
  final String value;
  final String hint;
  final ValueChanged<String> onChanged;
  final String? prefix;
  final bool autofocus;
  final TextStyle? style;

  const DenDynamicUnderlineField({
    super.key,
    required this.value,
    required this.hint,
    required this.onChanged,
    this.prefix,
    this.autofocus = false,
    this.style,
  });

  @override
  State<DenDynamicUnderlineField> createState() => _DenDynamicUnderlineFieldState();
}

class _DenDynamicUnderlineFieldState extends State<DenDynamicUnderlineField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant DenDynamicUnderlineField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      final newValue = widget.value;
      _controller.value = TextEditingValue(
        text: newValue,
        selection: TextSelection.collapsed(offset: newValue.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = widget.style ??
        const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: DenColors.ink);
    final displayText = widget.value.isEmpty ? widget.hint : widget.value;

    final painter = TextPainter(
      text: TextSpan(text: displayText, style: textStyle),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    return LayoutBuilder(
      builder: (context, constraints) {
        double prefixWidth = 0.0;
        if (widget.prefix != null) {
          final prefixPainter = TextPainter(
            text: TextSpan(text: widget.prefix, style: textStyle),
            maxLines: 1,
            textDirection: TextDirection.ltr,
          )..layout();
          prefixWidth = prefixPainter.size.width + 2.0;
        }

        final maxAllowedWidth = (constraints.maxWidth * 0.85 - prefixWidth).clamp(60.0, 600.0);
        final fieldWidth = (painter.size.width + 12.0).clamp(28.0, maxAllowedWidth);

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.prefix != null) ...[
              Text(widget.prefix!, style: textStyle),
              const SizedBox(width: 2),
            ],
            AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOutCubic,
              width: fieldWidth,
              child: TextField(
                controller: _controller,
                autofocus: widget.autofocus,
                textAlign: TextAlign.center,
                style: textStyle,
                scrollPadding: EdgeInsets.zero,
                maxLines: 1,
                decoration: InputDecoration(
                  hintText: widget.hint,
                  hintStyle: textStyle.copyWith(color: DenColors.hint),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: DenColors.primary, width: 2),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: DenColors.primary, width: 3),
                  ),
                ),
                onChanged: widget.onChanged,
              ),
            ),
          ],
        );
      },
    );
  }
}
