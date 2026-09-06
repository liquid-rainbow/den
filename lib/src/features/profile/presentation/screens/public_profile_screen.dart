import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/profile_api_repository.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/den_masonry_grid.dart';
import '../../../profile/application/profile_controller.dart';

class PublicProfileScreen extends ConsumerStatefulWidget {
  final String username;

  const PublicProfileScreen({super.key, required this.username});

  @override
  ConsumerState<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends ConsumerState<PublicProfileScreen> {
  ProfileApiRepository get _repo => ref.read(profileApiRepositoryProvider);
  late final Future<Map<String, dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();
    final normalized = widget.username.trim().replaceAll(RegExp(r'^@'), '');
    _profileFuture = _repo.fetchPublicProfile(normalized);
  }

  @override
  Widget build(BuildContext context) {
    final currentProfile = ref.watch(profileStateProvider);
    final resolvedUsername = widget.username.trim().replaceAll(RegExp(r'^@'), '');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  leading: IconButton(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/profile');
                      }
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  ),
                ),
                body: const Center(child: CircularProgressIndicator()),
              );
            }

            final profile = snapshot.data ?? {
              'fullName': 'raghav',
              'username': resolvedUsername,
              'age': 24,
              'bio': '',
              'location': 'New Delhi, India',
              'gender': 'Male',
              'heightCm': 178,
              'instagramUsername': 'elenaspace',
              'photos': [
                'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=900&q=80',
                'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=900&q=80',
                'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?auto=format&fit=crop&w=900&q=80',
                'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=900&q=80',
              ],
              'isVerified': false,
            };

            final photos = _readPhotos(profile);
            final isSelf = resolvedUsername.toLowerCase() ==
                currentProfile.username.toLowerCase();

            return Stack(
              children: [
                // Scrollable Content
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Top Bar: Left = username, Right = Share + Three Dots
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              resolvedUsername,
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
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Profile link copied: den.app/u/$resolvedUsername')),
                                    );
                                  },
                                  icon: const Icon(Icons.share_outlined, color: Colors.black, size: 22),
                                  tooltip: 'Share Profile',
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () => _showMoreOptions(context, resolvedUsername),
                                  icon: const Icon(Icons.more_horiz, color: Colors.black, size: 26),
                                  tooltip: 'More Options',
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Circular Avatar with small dot
                      Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFE5E2EC), width: 1.5),
                              ),
                              child: ClipOval(
                                child: _buildAvatar(photos.isNotEmpty
                                    ? photos.first
                                    : 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=900&q=80'),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(right: 6, bottom: 6),
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Full Name
                      Text(
                        profile['fullName']?.toString() ?? 'raghav',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Bio
                      Text(
                        (profile['bio']?.toString().isNotEmpty == true)
                            ? profile['bio'].toString()
                            : 'Add a bio...',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: (profile['bio']?.toString().isNotEmpty == true)
                              ? Colors.black87
                              : const Color(0xFF8E8E93),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Stat row with vertical dividers: 🎂 24 | ♂ Male | 📏 5'10"
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.cake_outlined, size: 18, color: Color(0xFF555555)),
                                const SizedBox(width: 8),
                                Text(
                                  '${profile['age'] ?? 24}',
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
                            Row(
                              children: [
                                const Icon(Icons.male, size: 20, color: Color(0xFF555555)),
                                const SizedBox(width: 6),
                                Text(
                                  profile['gender']?.toString() ?? 'Male',
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
                            Row(
                              children: [
                                const Icon(Icons.straighten, size: 18, color: Color(0xFF555555)),
                                const SizedBox(width: 8),
                                Text(
                                  _heightLabel(profile['heightCm']),
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Location
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF6D6D6D)),
                          const SizedBox(width: 6),
                          Text(
                            profile['location']?.toString() ?? 'New Delhi, India',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E1E1E)),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Instagram Handle (Clean text, clickable)
                      GestureDetector(
                        onTap: () async {
                          final handle = (profile['instagramUsername']?.toString() ?? 'elenaspace').trim().replaceAll(RegExp(r'^@'), '');
                          if (handle.isNotEmpty) {
                            final uri = Uri.parse('https://instagram.com/$handle');
                            try {
                              final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
                              if (!launched && context.mounted) {
                                await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
                              }
                            } catch (_) {}
                          }
                        },
                        child: Text(
                          '@${profile['instagramUsername']?.toString() ?? "elenaspace"}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Four Squares Grid Tab Icon (⚏)
                      const Center(
                        child: Icon(Icons.grid_view_rounded, size: 24, color: Colors.black),
                      ),
                      const SizedBox(height: 16),

                      // 2-Column Den Masonry Photo Grid
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: DenMasonryGrid(photos: photos),
                      ),

                      const SizedBox(height: 120), // Padding for floating action bar
                    ],
                  ),
                ),

                // Floating Action Bar: Circular (X) + Dark Capsule Message / Invite Button (Screenshot 2)
                if (!isSelf)
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: _PublicFloatingActionBar(
                      username: resolvedUsername,
                      onDismiss: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/explore');
                        }
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _heightLabel(dynamic heightCm) {
    if (heightCm is num && heightCm > 0) {
      final feet = (heightCm / 30.48).floor();
      final inches = (((heightCm / 2.54) - (feet * 12))).round();
      return "$feet'$inches\"";
    }
    return "5'10\"";
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

  void _showMoreOptions(BuildContext context, String username) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.flag_outlined, color: Colors.redAccent),
                title: const Text('Report user', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Report submitted. Thank you for keeping DEN safe.')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.block_outlined, color: Colors.black87),
                title: const Text('Block user', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Blocked @$username')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  List<String> _readPhotos(Map<String, dynamic> profile) {
    final raw = profile['photos'];
    if (raw is List) {
      return raw.map((item) => item.toString()).toList();
    }
    return const [];
  }
}

/// Floating Bottom Action Bar matching Screenshot 2:
/// Left: Circular Cross (X) button with border
/// Right: Dark brown pill button with message input and send airplane icon
class _PublicFloatingActionBar extends StatefulWidget {
  final String username;
  final VoidCallback onDismiss;

  const _PublicFloatingActionBar({
    required this.username,
    required this.onDismiss,
  });

  @override
  State<_PublicFloatingActionBar> createState() => _PublicFloatingActionBarState();
}

class _PublicFloatingActionBarState extends State<_PublicFloatingActionBar> {
  final TextEditingController _msgController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  void _sendInvite() async {
    final text = _msgController.text.trim();
    setState(() => _isSending = true);

    await Future.delayed(const Duration(milliseconds: 350));

    if (mounted) {
      setState(() {
        _isSending = false;
        _msgController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            text.isNotEmpty
                ? 'Invite sent to @${widget.username}: "$text"'
                : 'Invite sent to @${widget.username}!',
          ),
          backgroundColor: const Color(0xFF1F7A4A),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left: Circular Cross (X) Button
          GestureDetector(
            onTap: widget.onDismiss,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE5E2EC), width: 1.5),
              ),
              child: const Icon(Icons.close, color: Colors.black87, size: 24),
            ),
          ),
          const SizedBox(width: 12),

          // Right: Dark Capsule Pill Button (Screenshot 2)
          Expanded(
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: const Color(0xFF382326), // Dark coffee brown / deep maroon
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500),
                      decoration: const InputDecoration(
                        hintText: "wanna attend 'that' event....",
                        hintStyle: TextStyle(fontSize: 14, color: Color(0xFFC7B6B9), fontWeight: FontWeight.w400),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (_) => _sendInvite(),
                    ),
                  ),
                  IconButton(
                    onPressed: _isSending ? null : _sendInvite,
                    icon: _isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    tooltip: 'Send',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(width: 32, height: 32),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
