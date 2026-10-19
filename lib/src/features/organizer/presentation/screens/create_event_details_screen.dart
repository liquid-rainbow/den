import 'dart:io';
import 'package:den/src/core/widgets/den_wheel_picker.dart';
import 'package:den/src/features/organizer/application/create_event_controller.dart';
import 'package:den/src/features/organizer/presentation/theme/organizer_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class CreateEventDetailsScreen extends ConsumerStatefulWidget {
  const CreateEventDetailsScreen({super.key});

  @override
  ConsumerState<CreateEventDetailsScreen> createState() =>
      _CreateEventDetailsScreenState();
}

class _CreateEventDetailsScreenState
    extends ConsumerState<CreateEventDetailsScreen> {
  late TextEditingController _titleController;
  late DateTime _selectedDate;
  late String _startTime;
  late String _endTime;
  String? _pickedBannerUrl;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(createEventProvider);
    _titleController = TextEditingController(text: draft.title);
    _selectedDate = draft.date ?? DateTime.now().add(const Duration(days: 1));
    _startTime = draft.startTime.isNotEmpty ? draft.startTime : '20:00';
    _endTime = draft.endTime ?? '23:00';
    _pickedBannerUrl = draft.bannerUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickBanner() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedBannerUrl = picked.path;
      });
    }
  }

  void _onContinue() {
    ref.read(createEventProvider.notifier).updateBasicDetails(
          bannerUrl: _pickedBannerUrl,
          title: _titleController.text.trim(),
          date: _selectedDate,
          startTime: _startTime,
          endTime: _endTime.isNotEmpty ? _endTime : null,
        );

    context.push('/organizer/events/create/description');
  }

  @override
  Widget build(BuildContext context) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final monthName = months[_selectedDate.month - 1];

    return Scaffold(
      backgroundColor: OrganizerColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: OrganizerColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Event Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: OrganizerColors.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upload a banner image',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: OrganizerColors.onSurface,
                ),
              ),
              const SizedBox(height: 14),

              // Banner Upload Area
              GestureDetector(
                onTap: _pickBanner,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: OrganizerColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: OrganizerColors.outlineVariant,
                      style: BorderStyle.solid,
                      width: 1.5,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_pickedBannerUrl != null &&
                          _pickedBannerUrl!.isNotEmpty)
                        Opacity(
                          opacity: 0.85,
                          child: _pickedBannerUrl!.startsWith('http')
                              ? Image.network(
                                  _pickedBannerUrl!,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const SizedBox.shrink(),
                                )
                              : Image.file(
                                  File(_pickedBannerUrl!),
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      Container(
                        color: Colors.black.withValues(alpha: 0.15),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 28,
                              color: OrganizerColors.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Upload Banner Image',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              shadows: [Shadow(blurRadius: 4, color: Colors.black45)],
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Recommended: 1200x600px',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Den Name Input
              const Text(
                'Name your den',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: OrganizerColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: OrganizerColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _titleController,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: OrganizerColors.onSurface,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter a catchy title...',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Date and Time Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: OrganizerColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Date and time',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: OrganizerColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Live Formatted Badge
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                      decoration: BoxDecoration(
                        color: OrganizerColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(
                          color: OrganizerColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        '${_selectedDate.day} $monthName ${_selectedDate.year} • $_startTime • $_endTime',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: OrganizerColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Interactive Wheel Pickers
                    DenDateTimePicker(
                      date: _selectedDate,
                      startTime: _startTime,
                      endTime: _endTime,
                      onDateChanged: (newDate) {
                        setState(() {
                          _selectedDate = newDate;
                        });
                      },
                      onStartTimeChanged: (newStartTime) {
                        setState(() {
                          _startTime = newStartTime;
                        });
                      },
                      onEndTimeChanged: (newEndTime) {
                        setState(() {
                          _endTime = newEndTime ?? '';
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Bottom Continue Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _onContinue,
                  icon: const SizedBox.shrink(),
                  label: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OrganizerColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 3,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
