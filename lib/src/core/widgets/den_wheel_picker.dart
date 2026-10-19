import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class DenSingleWheelPicker extends StatefulWidget {
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final double width;
  final double height;
  final Color activePillColor;
  final Color activeTextColor;
  final Color inactiveTextColor;

  const DenSingleWheelPicker({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.width = 65,
    this.height = 180,
    this.activePillColor = const Color(0xFF630ED4),
    this.activeTextColor = Colors.white,
    this.inactiveTextColor = const Color(0xFF6B7280),
  });

  @override
  State<DenSingleWheelPicker> createState() => _DenSingleWheelPickerState();
}

class _DenSingleWheelPickerState extends State<DenSingleWheelPicker> {
  FixedExtentScrollController? _scrollController;
  double _dragAccumulator = 0.0;

  FixedExtentScrollController get controller {
    if (_scrollController == null) {
      final initialIndex =
          widget.options.indexOf(widget.value).clamp(0, widget.options.length - 1);
      _scrollController =
          FixedExtentScrollController(initialItem: initialIndex);
    }
    return _scrollController!;
  }

  @override
  void didUpdateWidget(covariant DenSingleWheelPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      final newIndex =
          widget.options.indexOf(widget.value).clamp(0, widget.options.length - 1);
      if (_scrollController != null &&
          _scrollController!.hasClients &&
          _scrollController!.selectedItem != newIndex) {
        _scrollController!.jumpToItem(newIndex);
      }
    }
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  void _stepBy(int delta) {
    final currentIndex =
        widget.options.indexOf(widget.value).clamp(0, widget.options.length - 1);
    final targetIndex =
        (currentIndex + delta).clamp(0, widget.options.length - 1);
    if (targetIndex != currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onChanged(widget.options[targetIndex]);
      });
      if (controller.hasClients) {
        controller.animateToItem(
          targetIndex,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex =
        widget.options.indexOf(widget.value).clamp(0, widget.options.length - 1);

    return Listener(
      onPointerSignal: (pointerSignal) {
        if (pointerSignal is PointerScrollEvent) {
          if (pointerSignal.scrollDelta.dy > 0) {
            _stepBy(1);
          } else if (pointerSignal.scrollDelta.dy < 0) {
            _stepBy(-1);
          }
        }
      },
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          _dragAccumulator += details.primaryDelta ?? 0;
          if (_dragAccumulator.abs() > 14) {
            if (_dragAccumulator < 0) {
              _stepBy(1);
            } else {
              _stepBy(-1);
            }
            _dragAccumulator = 0;
          }
        },
        onVerticalDragEnd: (_) {
          _dragAccumulator = 0;
        },
        child: Container(
          height: widget.height,
          width: widget.width,
          color: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Center selection pill
              Container(
                height: 44,
                width: widget.width,
                decoration: BoxDecoration(
                  color: widget.activePillColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.activePillColor.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                ),
              ),

              // Wheel Scroll View
              IgnorePointer(
                child: ListWheelScrollView.useDelegate(
                  controller: controller,
                  itemExtent: 40,
                  diameterRatio: 1.2,
                  perspective: 0.003,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      widget.onChanged(widget.options[index]);
                    });
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: widget.options.length,
                    builder: (context, index) {
                      final isSelected = index == selectedIndex;
                      return Center(
                        child: Text(
                          widget.options[index],
                          style: TextStyle(
                            fontSize: isSelected ? 18 : 14,
                            fontWeight:
                                isSelected ? FontWeight.w800 : FontWeight.w500,
                            color: isSelected
                                ? widget.activePillColor
                                : widget.inactiveTextColor.withValues(alpha: 0.5),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DenDateTimePicker extends StatelessWidget {
  final DateTime date;
  final String startTime;
  final String? endTime;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<String> onStartTimeChanged;
  final ValueChanged<String?> onEndTimeChanged;

  const DenDateTimePicker({
    super.key,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.onDateChanged,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final days = List.generate(31, (i) => (i + 1).toString().padLeft(2, '0'));
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final currentYear = DateTime.now().year;
    final years = List.generate(6, (i) => (currentYear + i).toString());

    final hours = List.generate(24, (i) => i.toString().padLeft(2, '0'));
    final minutes = ['00', '15', '30', '45'];

    final selectedDay = date.day.toString().padLeft(2, '0');
    final selectedMonthIndex = (date.month - 1).clamp(0, 11);
    final selectedMonth = months[selectedMonthIndex];
    final selectedYear = date.year.toString();

    final startParts = startTime.split(':');
    final startHour = startParts.isNotEmpty ? startParts[0].padLeft(2, '0') : '20';
    final startMin = startParts.length > 1 ? startParts[1] : '00';

    final endParts = (endTime ?? '23:00').split(':');
    final endHour = endParts.isNotEmpty ? endParts[0].padLeft(2, '0') : '23';
    final endMin = endParts.length > 1 ? endParts[1] : '00';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section 1: Date Wheel
        const Text(
          'Select Date',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1C1B1B),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEAE7E7)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              DenSingleWheelPicker(
                value: selectedDay,
                options: days,
                width: 60,
                onChanged: (newDay) {
                  final d = int.tryParse(newDay) ?? date.day;
                  onDateChanged(DateTime(date.year, date.month, d));
                },
              ),
              const Text('/',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFCCC3D8))),
              DenSingleWheelPicker(
                value: selectedMonth,
                options: months,
                width: 70,
                onChanged: (newMonth) {
                  final m = months.indexOf(newMonth) + 1;
                  onDateChanged(DateTime(date.year, m, date.day));
                },
              ),
              const Text('/',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFCCC3D8))),
              DenSingleWheelPicker(
                value: selectedYear,
                options: years,
                width: 75,
                onChanged: (newYear) {
                  final y = int.tryParse(newYear) ?? date.year;
                  onDateChanged(DateTime(y, date.month, date.day));
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Section 2: Start & End Times
        Row(
          children: [
            // Start Time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Start Time',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C1B1B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 6, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFEAE7E7)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DenSingleWheelPicker(
                          value: startHour,
                          options: hours,
                          width: 45,
                          height: 150,
                          onChanged: (newHour) {
                            onStartTimeChanged('$newHour:$startMin');
                          },
                        ),
                        const Text(':',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF630ED4))),
                        DenSingleWheelPicker(
                          value: minutes.contains(startMin) ? startMin : '00',
                          options: minutes,
                          width: 45,
                          height: 150,
                          onChanged: (newMin) {
                            onStartTimeChanged('$startHour:$newMin');
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // End Time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'End Time (Optional)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1C1B1B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 6, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFEAE7E7)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DenSingleWheelPicker(
                          value: endHour,
                          options: hours,
                          width: 45,
                          height: 150,
                          onChanged: (newHour) {
                            onEndTimeChanged('$newHour:$endMin');
                          },
                        ),
                        const Text(':',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF630ED4))),
                        DenSingleWheelPicker(
                          value: minutes.contains(endMin) ? endMin : '00',
                          options: minutes,
                          width: 45,
                          height: 150,
                          onChanged: (newMin) {
                            onEndTimeChanged('$endHour:$newMin');
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
