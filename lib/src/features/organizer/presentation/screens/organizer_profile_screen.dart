import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/widgets/den_masonry_grid.dart';
import '../../../../core/widgets/image_crop_adjust_dialog.dart';
import '../../application/organizer_controller.dart';
import '../../application/organizer_events_controller.dart';
import '../theme/organizer_theme.dart';
import '../widgets/organizer_event_card.dart';

class OrganizerProfileScreen extends ConsumerStatefulWidget {
  const OrganizerProfileScreen({super.key});

  @override
  ConsumerState<OrganizerProfileScreen> createState() =>
      _OrganizerProfileScreenState();
}

class _OrganizerProfileScreenState extends ConsumerState<OrganizerProfileScreen> {
  int _selectedMediaTab = 0; // 0: Photos, 1: Videos

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (!mounted || image == null) return;

    final adjustedImage = await ImageCropAdjustDialog.show(context, image);
    if (adjustedImage != null) {
      ref.read(organizerProvider.notifier).updateProfile(avatarUrl: adjustedImage.path);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Organizer avatar updated!')),
        );
      }
    }
  }

  Future<void> _launchInstagram(String handle) async {
    final clean = handle.trim().replaceAll(RegExp(r'^@'), '');
    if (clean.isEmpty) return;
    final uri = Uri.parse('https://instagram.com/$clean');
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final organizerState = ref.watch(organizerProvider);
    final eventsState = ref.watch(organizerEventsProvider);
    final profile = organizerState.profile;

    if (profile == null) {
      return Scaffold(
        backgroundColor: OrganizerColors.surface,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: OrganizerColors.onSurface),
            onPressed: () => context.go('/profile'),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.business_center_outlined, size: 64, color: OrganizerColors.outline),
                const SizedBox(height: 16),
                const Text(
                  'No Organizer Profile Found',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Create an organizer profile to manage events, ticket sales, and approved audiences.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: OrganizerColors.onSurfaceVariant),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.push('/organizer/intro'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OrganizerColors.primary,
                    foregroundColor: OrganizerColors.onPrimary,
                  ),
                  child: const Text('Create Profile'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: OrganizerColors.surface,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: OrganizerColors.surface.withValues(alpha: 0.95),
            elevation: 0,
            floating: true,
            pinned: true,
            leading: const SizedBox.shrink(),
            title: Text(
              profile.displayHandle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: OrganizerColors.onSurface,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined, color: OrganizerColors.onSurface, size: 22),
                onPressed: () => context.push('/profile/share'),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: OrganizerColors.onSurface, size: 22),
                onPressed: () => context.push('/organizer/settings'),
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Main Profile Header Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // Avatar with add/edit button
                  Center(
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: _pickAvatar,
                          child: Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFFE0E0E0), Color(0xFFBDBDBD)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(3),
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: _buildAvatar(profile.avatarUrl),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 18,
                              color: OrganizerColors.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Profile Name
                  Text(
                    profile.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: OrganizerColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Followers Count Pill
                  GestureDetector(
                    onTap: () => context.push('/organizer/followers'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAE5E5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        profile.followerCountLabel,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: OrganizerColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Bio Description
                  if (profile.bio.isNotEmpty)
                    Text(
                      profile.bio,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: OrganizerColors.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Action Buttons Group
                  // 1. Instagram button
                  _buildOutlineActionButton(
                    label: 'Instagram',
                    icon: Icons.camera_alt_outlined,
                    onTap: () => _launchInstagram(
                      profile.instagramHandle.isNotEmpty
                          ? profile.instagramHandle
                          : 'auracollective',
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 2. Create Post & Create Event
                  Row(
                    children: [
                      Expanded(
                        child: _buildOutlineActionButton(
                          label: 'Create a Post',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Create a post coming soon!')),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            context.push('/organizer/events/create/category');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF361D32),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'Create Event',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 3. Switch to User Profile Button
                  _buildOutlineActionButton(
                    label: 'User',
                    icon: Icons.person_outline,
                    onTap: () {
                      ref.read(organizerProvider.notifier).switchMode(ProfileMode.user);
                      context.go('/profile');
                    },
                  ),
                  const SizedBox(height: 32),

                  // Upcoming Events Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Upcoming',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: OrganizerColors.onSurface,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/organizer/events/history'),
                        child: const Text(
                          'View All',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: OrganizerColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Upcoming Events Horizontal List
                  SizedBox(
                    height: 260,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: eventsState.upcomingEvents.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final event = eventsState.upcomingEvents[index];
                        return OrganizerEventCard(
                          event: event,
                          onTap: () => context.push('/organizer/events/${event.id}/dashboard'),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Media Tabs Header (Image Icon vs Video Icon)
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedMediaTab = 0),
                          child: Container(
                            padding: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: _selectedMediaTab == 0
                                      ? OrganizerColors.onSurface
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Icon(
                              Icons.image_outlined,
                              size: 26,
                              color: _selectedMediaTab == 0
                                  ? OrganizerColors.onSurface
                                  : OrganizerColors.outlineVariant,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedMediaTab = 1),
                          child: Container(
                            padding: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: _selectedMediaTab == 1
                                      ? OrganizerColors.onSurface
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Icon(
                              Icons.play_circle_outline,
                              size: 26,
                              color: _selectedMediaTab == 1
                                  ? OrganizerColors.onSurface
                                  : OrganizerColors.outlineVariant,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 2-Column Den Masonry Grid
                  DenMasonryGrid(
                    photos: _selectedMediaTab == 0
                        ? profile.photoUrls
                        : (profile.videoThumbnails.isNotEmpty
                            ? profile.videoThumbnails
                            : profile.photoUrls),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.person, color: OrganizerColors.outline, size: 48),
      );
    } else if (url.isNotEmpty) {
      return Image.file(
        File(url),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.person, color: OrganizerColors.outline, size: 48),
      );
    }
    return const Icon(Icons.person, color: OrganizerColors.outline, size: 48);
  }

  Widget _buildOutlineActionButton({
    required String label,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD1D1D1)),
          color: OrganizerColors.surfaceContainerLowest,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: OrganizerColors.onSurface),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: OrganizerColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
