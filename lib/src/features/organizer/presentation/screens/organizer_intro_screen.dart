import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/organizer_theme.dart';

class OrganizerIntroScreen extends ConsumerWidget {
  const OrganizerIntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: OrganizerColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const SizedBox.shrink(),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: OrganizerColors.onSurface),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const Spacer(),
              // Animated decorative badge/icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: OrganizerColors.primaryFixedDim.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: OrganizerColors.primary.withValues(alpha: 0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.celebration_rounded,
                    size: 56,
                    color: OrganizerColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Title
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: OrganizerColors.onSurface,
                    height: 1.2,
                  ),
                  children: [
                    TextSpan(text: "Let's create your\n"),
                    TextSpan(
                      text: "organizer profile",
                      style: TextStyle(color: OrganizerColors.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Subtitle
              const Text(
                'This lets you manage all the events, parties, sales, insights and followers all at one place',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: OrganizerColors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 2),

              // Bottom CTA
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.push('/organizer/setup'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OrganizerColors.primary,
                    foregroundColor: OrganizerColors.onPrimary,
                    elevation: 4,
                    shadowColor: OrganizerColors.primary.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Get Started',
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
