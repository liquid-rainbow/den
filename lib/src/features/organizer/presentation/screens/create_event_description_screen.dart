import 'package:den/src/features/organizer/application/create_event_controller.dart';
import 'package:den/src/features/organizer/presentation/theme/organizer_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CreateEventDescriptionScreen extends ConsumerStatefulWidget {
  const CreateEventDescriptionScreen({super.key});

  @override
  ConsumerState<CreateEventDescriptionScreen> createState() =>
      _CreateEventDescriptionScreenState();
}

class _CreateEventDescriptionScreenState
    extends ConsumerState<CreateEventDescriptionScreen> {
  late TextEditingController _descController;
  bool _isBold = false;
  bool _isItalic = false;

  @override
  void initState() {
    super.initState();
    _descController = TextEditingController(
      text: ref.read(createEventProvider).description,
    );
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  void _onContinue() {
    ref
        .read(createEventProvider.notifier)
        .updateDescription(_descController.text.trim());
    context.push('/organizer/events/create/location');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrganizerColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: OrganizerColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: ClipRRect(
          borderRadius: BorderRadius.circular(9999),
          child: Container(
            width: 140,
            height: 6,
            color: OrganizerColors.surfaceContainerHigh,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 70,
                height: 6,
                color: OrganizerColors.primary,
              ),
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _onContinue,
            child: const Text(
              'Skip',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: OrganizerColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text(
                "Let's tell people about your den",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: OrganizerColors.onSurface,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 28),

              const Text(
                'Add description / Terms and Conditions for the guests',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: OrganizerColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),

              // Rich Text Box Container
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: OrganizerColors.surfaceContainerHigh),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    // Toolbar
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF9FAFB),
                        border: Border(
                          bottom:
                              BorderSide(color: OrganizerColors.surfaceContainerHigh),
                        ),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.format_bold,
                                size: 20,
                                color: _isBold
                                    ? OrganizerColors.primary
                                    : OrganizerColors.onSurface),
                            onPressed: () =>
                                setState(() => _isBold = !_isBold),
                            visualDensity: VisualDensity.compact,
                          ),
                          IconButton(
                            icon: Icon(Icons.format_italic,
                                size: 20,
                                color: _isItalic
                                    ? OrganizerColors.primary
                                    : OrganizerColors.onSurface),
                            onPressed: () =>
                                setState(() => _isItalic = !_isItalic),
                            visualDensity: VisualDensity.compact,
                          ),
                          IconButton(
                            icon: const Icon(Icons.format_align_left,
                                size: 20, color: OrganizerColors.onSurface),
                            onPressed: () {},
                            visualDensity: VisualDensity.compact,
                          ),
                          IconButton(
                            icon: const Icon(Icons.format_align_center,
                                size: 20, color: OrganizerColors.onSurface),
                            onPressed: () {},
                            visualDensity: VisualDensity.compact,
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.link,
                                size: 20, color: OrganizerColors.primary),
                            onPressed: () {},
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ),
                    // Editor Area
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: _descController,
                        maxLines: 8,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              _isBold ? FontWeight.w800 : FontWeight.w500,
                          fontStyle:
                              _isItalic ? FontStyle.italic : FontStyle.normal,
                          color: OrganizerColors.onSurface,
                          height: 1.4,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText:
                              'Start typing here...\n\nInclude house rules, entry requirements, dress code, or attach a T&C PDF link.',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Bottom CTA
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
                        'Save and Continue',
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
