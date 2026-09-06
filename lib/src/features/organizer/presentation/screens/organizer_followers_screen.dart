import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/remove_follower_bottom_sheet.dart';

class OrganizerFollowersScreen extends StatefulWidget {
  const OrganizerFollowersScreen({super.key});

  @override
  State<OrganizerFollowersScreen> createState() => _OrganizerFollowersScreenState();
}

class _OrganizerFollowersScreenState extends State<OrganizerFollowersScreen> {
  int _selectedTab = 0; // 0 for Followers, 1 for Approved

  // Mock data for followers
  final List<Map<String, dynamic>> _followers = [
    {
      'name': 'Aarav Sharma',
      'handle': '@aarav_s',
      'imageUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80',
      'isFollowingBack': true,
    },
    {
      'name': 'Maya Patel',
      'handle': '@maya_p',
      'imageUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80',
      'isFollowingBack': false,
    },
    {
      'name': 'Chen Wei',
      'handle': '@chen_wei99',
      'imageUrl': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=150&q=80',
      'isFollowingBack': true,
    },
    {
      'name': 'Sarah Jenkins',
      'handle': '@sarah_jinks',
      'imageUrl': 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=150&q=80',
      'isFollowingBack': false,
    },
  ];

  // Mock data for approved users
  final List<Map<String, dynamic>> _approved = [
    {
      'name': 'John Doe',
      'handle': '@john_d',
      'imageUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=150&q=80',
      'isFollowingBack': true,
    },
  ];

  void _removeUser(String userName) async {
    final result = await showRemoveFollowerBottomSheet(context, userName);
    if (!mounted) return;
    
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$userName removed from $result')),
      );
      // In a real app, you would remove them from the list here.
    }
  }

  void _toggleFollow(int index) {
    setState(() {
      if (_selectedTab == 0) {
        _followers[index]['isFollowingBack'] = !_followers[index]['isFollowingBack'];
      } else {
        _approved[index]['isFollowingBack'] = !_approved[index]['isFollowingBack'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color bgSurface = Color(0xFFFAF8FF);
    const Color onSurface = Color(0xFF131B2E);
    const Color primaryPurple = Color(0xFF6B18D1);

    final currentList = _selectedTab == 0 ? _followers : _approved;

    return Scaffold(
      backgroundColor: bgSurface,
      appBar: AppBar(
        backgroundColor: bgSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Column(
              children: [
                // Approve users manually button
                InkWell(
                  onTap: () => context.push('/organizer/approve-manually'),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Approve users manually',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: onSurface,
                          ),
                        ),
                        Icon(Icons.chevron_right, color: Colors.black54),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Approval invite link button
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Invite link copied to clipboard')),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Approval invite link',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: onSurface,
                          ),
                        ),
                        Icon(Icons.chevron_right, color: Colors.black54),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Tabs
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F2F0), // light beige/grey background
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTab = 0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _selectedTab == 0 ? primaryPurple : Colors.transparent,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Center(
                              child: Text(
                                'Followers',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedTab == 0 ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTab = 1),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _selectedTab == 1 ? primaryPurple : Colors.transparent,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Center(
                              child: Text(
                                'Approved',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedTab == 1 ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          
          // List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              itemCount: currentList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final user = currentList[index];
                final bool isFollowingBack = user['isFollowingBack'];
                
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.network(
                          user['imageUrl'],
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.person, color: Colors.grey, size: 48),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['name'],
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: onSurface,
                              ),
                            ),
                            Text(
                              user['handle'],
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (isFollowingBack)
                        GestureDetector(
                          onTap: () => _removeUser(user['name']),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5E2DC),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(Icons.close, size: 20, color: Colors.black87),
                          ),
                        )
                      else
                        ElevatedButton(
                          onPressed: () => _toggleFollow(index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryPurple,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('Follow', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
