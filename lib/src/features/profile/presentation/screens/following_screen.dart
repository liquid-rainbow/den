import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/den_colors.dart';

class FollowingScreen extends StatefulWidget {
  const FollowingScreen({super.key});

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  final List<Map<String, dynamic>> _followingList = [
    {
      'username': 'tanya_sharma',
      'fullName': 'Tanya Sharma',
      'avatarUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
      'age': 23,
      'location': 'South Delhi',
      'isMatched': true,
    },
    {
      'username': 'kabir_mehta',
      'fullName': 'Kabir Mehta',
      'avatarUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80',
      'age': 25,
      'location': 'Gurugram',
      'isMatched': true,
    },
    {
      'username': 'ananya_roy',
      'fullName': 'Ananya Roy',
      'avatarUrl': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=400&q=80',
      'age': 24,
      'location': 'Hauz Khas',
      'isMatched': false,
    },
    {
      'username': 'sophia_l',
      'fullName': 'Sophia Loren',
      'avatarUrl': 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=400&q=80',
      'age': 22,
      'location': 'New York, NY',
      'isMatched': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile/settings');
            }
          },
        ),
        title: const Text(
          'Following',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.black,
            letterSpacing: -0.4,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                'Only you can see whom you follow and match with.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Divider(height: 16, color: Color(0xFFEFEBF3)),
            Expanded(
              child: _followingList.isEmpty
                  ? const Center(
                      child: Text(
                        'You are not following anyone yet.',
                        style: TextStyle(color: Colors.black45, fontSize: 14),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: _followingList.length,
                      separatorBuilder: (context, index) => const Divider(height: 20, color: Color(0xFFF0EDF5)),
                      itemBuilder: (context, index) {
                        final item = _followingList[index];
                        final isMatched = item['isMatched'] == true;

                        return Row(
                          children: [
                            GestureDetector(
                              onTap: () => context.push('/u/${item['username']}'),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Image.network(
                                  item['avatarUrl'] as String,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Center(child: Icon(Icons.person, color: Colors.black26)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => context.push('/u/${item['username']}'),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '${item['fullName']}, ${item['age']}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black,
                                          ),
                                        ),
                                        if (isMatched) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE8F5E9),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'Matched',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF1F7A4A),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '@${item['username']} • ${item['location']}',
                                      style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                context.push('/chat/chat_${item['username']}');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF2EFF6),
                                foregroundColor: DenColors.primary,
                                elevation: 0,
                                shape: const StadiumBorder(),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                visualDensity: VisualDensity.compact,
                              ),
                              child: const Text(
                                'Chat',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
