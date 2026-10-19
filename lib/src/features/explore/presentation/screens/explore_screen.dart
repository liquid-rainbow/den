import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/den_colors.dart';
import '../../../../core/widgets/den_masonry_grid.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _profiles = [
    {
      'username': 'tanya_sharma',
      'fullName': 'Tanya Sharma',
      'age': 23,
      'isVerified': true,
      'bio': 'Architect by day, coffee connoisseur by night. Always down for live jazz and exploring hidden rooftop spots.',
      'location': 'South Delhi',
      'gender': 'Female',
      'heightLabel': "5'6\"",
      'instagramUsername': 'tanyasharma_arch',
      'photos': [
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=900&q=80',
        'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=800&q=80',
      ],
    },
    {
      'username': 'kabir_mehta',
      'fullName': 'Kabir Mehta',
      'age': 25,
      'isVerified': true,
      'bio': 'Product designer who loves road trips, analogue photography, and cooking authentic Italian pasta from scratch.',
      'location': 'Gurugram',
      'gender': 'Male',
      'heightLabel': "5'11\"",
      'instagramUsername': 'kabir_films',
      'photos': [
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=900&q=80',
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=800&q=80',
      ],
    },
    {
      'username': 'ananya_roy',
      'fullName': 'Ananya Roy',
      'age': 24,
      'isVerified': true,
      'bio': 'Indie music enthusiast, vinyl collector, and dog parent. Let’s find the best matcha latte in town.',
      'location': 'Hauz Khas, Delhi',
      'gender': 'Female',
      'heightLabel': "5'5\"",
      'instagramUsername': 'ananya_tunes',
      'photos': [
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=900&q=80',
        'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?auto=format&fit=crop&w=800&q=80',
      ],
    },
    {
      'username': 'rohan_kapoor',
      'fullName': 'Rohan Kapoor',
      'age': 26,
      'isVerified': false,
      'bio': 'Fitness enthusiast, techno lover, and startup founder. Looking to connect with ambitious and genuine people.',
      'location': 'Noida',
      'gender': 'Male',
      'heightLabel': "6'1\"",
      'instagramUsername': 'rohan_lifts',
      'photos': [
        'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?auto=format&fit=crop&w=900&q=80',
      ],
    },
  ];

  void _nextProfile() {
    setState(() {
      _currentIndex++;
    });
  }

  void _resetQueue() {
    setState(() {
      _currentIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasMore = _currentIndex < _profiles.length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: hasMore
            ? Stack(
                children: [
                  // Full Scrollable Single Profile View (Matching Screenshot 2)
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Top Bar: Left = username, Right = Share & More
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _profiles[_currentIndex]['username'],
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
                                        SnackBar(
                                          content: Text('Profile link copied: den.app/u/${_profiles[_currentIndex]['username']}'),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.share_outlined, color: Colors.black, size: 22),
                                    tooltip: 'Share Profile',
                                    padding: const EdgeInsets.all(4),
                                    constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () {},
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
                                  child: Image.network(
                                    (_profiles[_currentIndex]['photos'] as List<String>).first,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Center(child: Icon(Icons.person, color: Colors.black26, size: 60)),
                                  ),
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
                          _profiles[_currentIndex]['fullName'],
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Bio
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            _profiles[_currentIndex]['bio'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Stat row with dividers: 🎂 24 | ♂ Male | 📏 5'10"
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
                                    '${_profiles[_currentIndex]['age']}',
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
                                    _profiles[_currentIndex]['gender'],
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
                                    _profiles[_currentIndex]['heightLabel'],
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
                              _profiles[_currentIndex]['location'],
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E1E1E)),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Instagram Handle (Clean text, clickable)
                        GestureDetector(
                          onTap: () async {
                            final handle = (_profiles[_currentIndex]['instagramUsername']?.toString() ?? 'elenaspace').trim().replaceAll(RegExp(r'^@'), '');
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
                            '@${_profiles[_currentIndex]['instagramUsername'] ?? "elenaspace"}',
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
                          child: DenMasonryGrid(
                            photos: List<String>.from(_profiles[_currentIndex]['photos']),
                          ),
                        ),

                        const SizedBox(height: 120), // Space for floating action bar
                      ],
                    ),
                  ),

                  // Floating Bottom Action Bar (Screenshot 2)
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    child: _ExploreFloatingActionBar(
                      username: _profiles[_currentIndex]['username'],
                      onPass: _nextProfile,
                      onInviteSent: (msg) => _nextProfile(),
                    ),
                  ),
                ],
              )
            : _EmptyQueueState(onReset: _resetQueue),
      ),
    );
  }
}

class _ExploreFloatingActionBar extends StatefulWidget {
  final String username;
  final VoidCallback onPass;
  final ValueChanged<String> onInviteSent;

  const _ExploreFloatingActionBar({
    required this.username,
    required this.onPass,
    required this.onInviteSent,
  });

  @override
  State<_ExploreFloatingActionBar> createState() => _ExploreFloatingActionBarState();
}

class _ExploreFloatingActionBarState extends State<_ExploreFloatingActionBar> {
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

    await Future.delayed(const Duration(milliseconds: 300));

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

      widget.onInviteSent(text);
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
          // Left: Circular Cross (X) button to pass
          GestureDetector(
            onTap: widget.onPass,
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

class _EmptyQueueState extends StatelessWidget {
  final VoidCallback onReset;

  const _EmptyQueueState({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFF2EFF6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.people_outline, size: 40, color: DenColors.primary),
            ),
            const SizedBox(height: 20),
            const Text(
              "You're all caught up!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black),
            ),
            const SizedBox(height: 8),
            const Text(
              'No more new profiles right now. Check back soon or refresh the queue.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF6D6D6D), height: 1.4),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onReset,
              style: ElevatedButton.styleFrom(
                backgroundColor: DenColors.primary,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Start Over', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
