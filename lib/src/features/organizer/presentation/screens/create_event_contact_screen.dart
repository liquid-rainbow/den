import 'package:den/src/features/organizer/application/create_event_controller.dart';
import 'package:den/src/features/organizer/presentation/theme/organizer_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CreateEventContactScreen extends ConsumerStatefulWidget {
  const CreateEventContactScreen({super.key});

  @override
  ConsumerState<CreateEventContactScreen> createState() =>
      _CreateEventContactScreenState();
}

class _CreateEventContactScreenState
    extends ConsumerState<CreateEventContactScreen> {
  late TextEditingController _contactController;

  @override
  void initState() {
    super.initState();
    _contactController = TextEditingController(
      text: ref.read(createEventProvider).contactInfo,
    );
  }

  @override
  void dispose() {
    _contactController.dispose();
    super.dispose();
  }

  void _onContinue() {
    ref
        .read(createEventProvider.notifier)
        .updateContactInfo(_contactController.text.trim());
    context.push('/organizer/events/create/recap');
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Contact Information',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: OrganizerColors.onSurface,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'How can guests contact you for event related questions?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: OrganizerColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: OrganizerColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Your details are only visible after someone buys your ticket.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: OrganizerColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Textarea
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: OrganizerColors.surfaceContainerHigh),
                ),
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _contactController,
                  maxLines: 5,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: OrganizerColors.onSurface,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText:
                        'e.g. WhatsApp group link: chat.whatsapp.com/xyz or +91 98765 43210',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Continue CTA
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
