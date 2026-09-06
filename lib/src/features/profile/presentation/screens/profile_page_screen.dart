import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/den_masonry_grid.dart';
import '../../../../core/widgets/image_crop_adjust_dialog.dart';
import '../../../organizer/application/organizer_controller.dart';
import '../../../profile/application/profile_controller.dart';
import '../widgets/profile_event_ticket_card.dart';

class ProfilePageScreen extends ConsumerWidget {
  const ProfilePageScreen({super.key});

  Future<void> _pickAndAddPhoto(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (!context.mounted || image == null) return;

    final adjustedImage = await ImageCropAdjustDialog.show(context, image);
    if (adjustedImage != null) {
      final profile = ref.read(profileStateProvider);
      final updatedPhotos = [...profile.photoUrls, adjustedImage.path];
      ref.read(profileStateProvider.notifier).updatePhotos(updatedPhotos);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo added to profile!')),
        );
      }
    }
  }

  Future<void> _changeAvatarPhoto(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (!context.mounted || image == null) return;

    final adjustedImage = await ImageCropAdjustDialog.show(context, image);
    if (adjustedImage != null) {
      final profile = ref.read(profileStateProvider);
      final updatedPhotos = [adjustedImage.path, ...profile.photoUrls.skip(1)];
      ref.read(profileStateProvider.notifier).updatePhotos(updatedPhotos);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile photo updated!')),
        );
      }
    }
  }

  Future<void> _launchInstagram(BuildContext context, String instagramHandle) async {
    final handle = instagramHandle.trim().replaceAll(RegExp(r'^@'), '');
    if (handle.isEmpty) return;

    final uri = Uri.parse('https://instagram.com/$handle');
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open Instagram profile: @$handle')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileStateProvider);
    final organizerState = ref.watch(organizerProvider);
    final hasOrganizer = organizerState.hasOrganizerProfile;
    final username = profile.username.isNotEmpty ? profile.username : 'username';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Bar: Left = username, Right = + and Pencil icon
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => _pickAndAddPhoto(context, ref),
                          icon: const Icon(Icons.add, color: Colors.black, size: 28),
                          tooltip: 'Add Photo',
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => context.go('/profile/settings'),
                          icon: const Icon(Icons.edit, color: Colors.black, size: 22),
                          tooltip: 'Settings',
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Circular Avatar with small edit pencil & status dot
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomRight,
                  children: [
                    GestureDetector(
                      onTap: () => _changeAvatarPhoto(context, ref),
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE5E2EC), width: 1.5),
                        ),
                        child: ClipOval(
                          child: _buildAvatar(profile.photoUrls.isNotEmpty
                              ? profile.photoUrls.first
                              : 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=900&q=80'),
                        ),
                      ),
                    ),
                    // Small status dot
                    Positioned(
                      right: 6,
                      bottom: 6,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    // Small pencil icon to change profile photo
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _changeAvatarPhoto(context, ref),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE5E2EC)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.edit, size: 15, color: Colors.black87),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Full Name (e.g. raghav)
              Text(
                profile.fullName.isNotEmpty ? profile.fullName : 'raghav',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),

              // Add a bio... / actual bio
              Text(
                profile.bio.isNotEmpty ? profile.bio : 'Add a bio...',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: profile.bio.isNotEmpty ? Colors.black87 : const Color(0xFF8E8E93),
                ),
              ),

              const SizedBox(height: 24),

              // Single Row Info with Dividers: 🎂 24 | ♂ Male | 📏 5'10"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Age
                    Row(
                      children: [
                        const Icon(Icons.cake_outlined, size: 18, color: Color(0xFF555555)),
                        const SizedBox(width: 8),
                        Text(
                          '${profile.age > 0 ? profile.age : 24}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        height: 20,
                        child: VerticalDivider(color: Color(0xFFDCD8E3), thickness: 1.2),
                      ),
                    ),

                    // Gender
                    Row(
                      children: [
                        const Icon(Icons.male, size: 20, color: Color(0xFF555555)),
                        const SizedBox(width: 6),
                        Text(
                          profile.gender.isNotEmpty ? profile.gender : 'Male',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        height: 20,
                        child: VerticalDivider(color: Color(0xFFDCD8E3), thickness: 1.2),
                      ),
                    ),

                    // Height
                    Row(
                      children: [
                        const Icon(Icons.straighten, size: 18, color: Color(0xFF555555)),
                        const SizedBox(width: 8),
                        Text(
                          profile.heightLabel.isNotEmpty ? profile.heightLabel : "5'10\"",
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Location: 📍 New Delhi, India
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF6D6D6D)),
                  const SizedBox(width: 6),
                  Text(
                    profile.location.isNotEmpty ? profile.location : 'New Delhi, India',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Instagram Handle (Clickable, clean text without camera icon box)
              GestureDetector(
                onTap: () => _launchInstagram(context, profile.instagramUsername.isNotEmpty ? profile.instagramUsername : 'elenaspace'),
                child: Text(
                  '@${profile.instagramUsername.isNotEmpty ? profile.instagramUsername : "elenaspace"}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Booked Event Ticket Card
              ProfileEventTicketCard(
                eventId: 'evt_123',
                eventName: 'Neon Nights Festival',
                date: "24 Aug '25",
                time: "10:00 PM",
                location: "Cyber Pier 9",
                userName: profile.fullName.isNotEmpty ? profile.fullName : 'Raghav',
                ticketCount: 2,
                passType: 'VIP',
                onTap: () {
                  context.push('/event/evt_123/ticket');
                },
              ),

              const SizedBox(height: 28),

              // Action Buttons: 2 in top row, 1 wide button below
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            label: 'Share Profile',
                            onTap: () => context.push('/profile/share'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            label: 'Wallet',
                            onTap: () => context.push('/profile/wallet'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _ActionButton(
                      label: hasOrganizer
                          ? 'Switch to Organizer Profile'
                          : 'Create an Event/Organization Profile',
                      onTap: () {
                        if (hasOrganizer) {
                          ref.read(organizerProvider.notifier).switchMode(ProfileMode.organizer);
                          context.push('/organizer/profile');
                        } else {
                          context.push('/organizer/intro');
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Four Squares Grid Tab Icon (⚏)
              const Center(
                child: Icon(Icons.grid_view_rounded, size: 24, color: Colors.black),
              ),
              const SizedBox(height: 16),

              // 2-Column Den Masonry Photo Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: DenMasonryGrid(
                  photos: profile.photoUrls,
                ),
              ),

              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String url) {
    if (url.startsWith('http://') || url.startsWith('https://') || url.startsWith('blob:')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Center(child: Icon(Icons.person, color: Colors.black26, size: 60)),
      );
    } else {
      return Image.file(
        File(url),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Center(child: Icon(Icons.person, color: Colors.black26, size: 60)),
      );
    }
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE6E5EA)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
