import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/widgets/den_masonry_grid.dart';
import '../../application/organizer_events_controller.dart';
import '../theme/organizer_theme.dart';
import '../widgets/organizer_event_card.dart';

class PublicOrganizerProfileScreen extends ConsumerStatefulWidget {
  final String username;

  const PublicOrganizerProfileScreen({super.key, required this.username});

  @override
  ConsumerState<PublicOrganizerProfileScreen> createState() =>
      _PublicOrganizerProfileScreenState();
}

class _PublicOrganizerProfileScreenState
    extends ConsumerState<PublicOrganizerProfileScreen> {
  int _selectedMediaTab = 0; // 0: Moments, 1: Events
  bool _isFollowing = false;

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
    // In a real app, you would fetch the public organizer profile using the username.
    // Here we use mock data to represent what the backend would return.
    final String displayHandle = widget.username.startsWith('@') ? widget.username : '@${widget.username}';
    
    // We will use the events from the organizer controller for display purposes
    final eventsState = ref.watch(organizerEventsProvider);
    
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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: OrganizerColors.onSurface),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              },
            ),
            title: Text(
              displayHandle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: OrganizerColors.onSurface,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined, color: OrganizerColors.onSurface, size: 22),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Profile link copied: den.app/o/${widget.username}')),
                  );
                },
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

                  // Avatar with img badge
                  Center(
                    child: Stack(
                      children: [
                        Container(
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
                            child: Image.network(
                              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.person, color: OrganizerColors.outline, size: 48),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Text(
                              'img',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Profile Name
                  Text(
                    widget.username.replaceAll('_', ' ').replaceAll('@', ''),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: OrganizerColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Followers Count Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAE5E5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _isFollowing ? '2.5k followers' : '2.5k followers',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: OrganizerColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Bio Description
                  const Text(
                    'Curating intentional spaces for deep connection and artistic expression. We host intimate gatherings designed for those who seek depth over noise.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
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
                    onTap: () => _launchInstagram(widget.username),
                  ),
                  const SizedBox(height: 12),

                  // 2. Follow Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isFollowing = !_isFollowing;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_isFollowing ? 'Following ${widget.username}' : 'Unfollowed ${widget.username}'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isFollowing ? Colors.white : const Color(0xFF361D32),
                        foregroundColor: _isFollowing ? const Color(0xFF361D32) : Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(color: _isFollowing ? const Color(0xFF361D32) : Colors.transparent),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        _isFollowing ? 'Following' : 'Follow',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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
                        onTap: () {
                          // View All action
                        },
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
                          onTap: () => context.push('/event/${event.id}/details'), // Go to standard event details for regular users
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Media Tabs Header (Text instead of icons)
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
                            child: Center(
                              child: Text(
                                'Moments',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedMediaTab == 0
                                      ? OrganizerColors.onSurface
                                      : OrganizerColors.outlineVariant,
                                ),
                              ),
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
                            child: Center(
                              child: Text(
                                'Events',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedMediaTab == 1
                                      ? OrganizerColors.onSurface
                                      : OrganizerColors.outlineVariant,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 2-Column Den Masonry Grid
                  const DenMasonryGrid(
                    photos: [
                      'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&w=400&q=80',
                      'https://images.unsplash.com/photo-1505236858219-8359eb29e329?auto=format&fit=crop&w=400&q=80',
                      'https://images.unsplash.com/photo-1540575467063-178a50c2df87?auto=format&fit=crop&w=400&q=80',
                      'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?auto=format&fit=crop&w=400&q=80',
                    ],
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

  Widget _buildOutlineActionButton({
    required String label,
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
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: OrganizerColors.onSurface,
          ),
        ),
      ),
    );
  }
}
