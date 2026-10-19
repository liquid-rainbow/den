import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/organizer_controller.dart';
import '../theme/organizer_theme.dart';

class OrganizerConnectInstagramScreen extends ConsumerStatefulWidget {
  const OrganizerConnectInstagramScreen({super.key});

  @override
  ConsumerState<OrganizerConnectInstagramScreen> createState() =>
      _OrganizerConnectInstagramScreenState();
}

class _OrganizerConnectInstagramScreenState
    extends ConsumerState<OrganizerConnectInstagramScreen> {
  late final TextEditingController _igController;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(organizerProvider).draft;
    _igController = TextEditingController(text: draft.instagramHandle);
  }

  @override
  void dispose() {
    _igController.dispose();
    super.dispose();
  }

  void _onContinue({bool isSkip = false}) {
    if (!isSkip) {
      final handle = _igController.text.trim().replaceAll(RegExp(r'^@'), '');
      ref.read(organizerProvider.notifier).updateDraft(instagramHandle: handle);
    }
    context.push('/organizer/verify-phone');
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
        actions: [
          TextButton(
            onPressed: () => _onContinue(isSkip: true),
            child: const Text(
              'Skip',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: OrganizerColors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              // Instagram Icon badge
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: OrganizerColors.primary.withValues(alpha: 0.08),
                ),
                child: const Center(
                  child: Icon(
                    Icons.camera_alt_outlined,
                    size: 48,
                    color: OrganizerColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Title
              const Text(
                'Instagram of your event page?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: OrganizerColors.onSurface,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              const Text(
                'Sharing your Instagram builds trust and helps you grow faster.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: OrganizerColors.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 36),

              // Input field with '@' prefix pill design
              Container(
                decoration: BoxDecoration(
                  color: OrganizerColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(28),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: TextField(
                  controller: _igController,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: OrganizerColors.onSurface,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    icon: Text(
                      '@',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: OrganizerColors.outline,
                      ),
                    ),
                    hintText: 'yourhandle',
                    hintStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF9E9AA7),
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Bottom Continue CTA
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _onContinue(isSkip: false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OrganizerColors.primary,
                    foregroundColor: OrganizerColors.onPrimary,
                    elevation: 4,
                    shadowColor: OrganizerColors.primary.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
