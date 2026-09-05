import 'package:den/src/features/organizer/application/create_event_controller.dart';
import 'package:den/src/features/organizer/domain/models/create_event_draft.dart';
import 'package:den/src/features/organizer/presentation/theme/organizer_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CreateEventCategoryScreen extends ConsumerWidget {
  const CreateEventCategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: OrganizerColors.surfaceContainer,
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
              const Text(
                'Select the type of den you want to create',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: OrganizerColors.onSurface,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 28),

              // 2-Column Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.82,
                children: [
                  _buildCategoryCard(
                    context,
                    ref,
                    category: EventCategory.party,
                    icon: Icons.home,
                    watermark: Icons.music_note,
                  ),
                  _buildCategoryCard(
                    context,
                    ref,
                    category: EventCategory.event,
                    icon: Icons.theater_comedy,
                    watermark: Icons.celebration,
                  ),
                  _buildCategoryCard(
                    context,
                    ref,
                    category: EventCategory.fitness,
                    icon: Icons.fitness_center,
                    watermark: Icons.bolt,
                  ),
                  _buildCategoryCard(
                    context,
                    ref,
                    category: EventCategory.comedyClub,
                    icon: Icons.sentiment_very_satisfied,
                    watermark: Icons.theater_comedy,
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Spanning Travel Card
              Center(
                child: SizedBox(
                  width: (MediaQuery.of(context).size.width - 54) / 2,
                  height: ((MediaQuery.of(context).size.width - 54) / 2) / 0.82,
                  child: _buildCategoryCard(
                    context,
                    ref,
                    category: EventCategory.travel,
                    icon: Icons.flight,
                    watermark: Icons.public,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    WidgetRef ref, {
    required EventCategory category,
    required IconData icon,
    required IconData watermark,
  }) {
    final colors = category.gradientColors.map((c) => Color(c)).toList();
    return GestureDetector(
      onTap: () {
        ref.read(createEventProvider.notifier).setCategory(category);
        context.push('/organizer/events/create/details');
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Translucent Watermark Icon
            Positioned(
              top: -10,
              right: -10,
              child: Icon(
                watermark,
                size: 80,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            // Card Content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    category.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
