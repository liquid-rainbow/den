import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RecentNotificationsScreen extends StatelessWidget {
  const RecentNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bgSurface = Color(0xFFFAF8FF);
    const onSurface = Color(0xFF131B2E);
    const primaryContainer = Color(0xFF2563EB);
    const secondaryContainer = Color(0xFFD0E1FB);

    final recentItems = [
      {
        'type': 'icon',
        'icon': Icons.event,
        'bgColor': primaryContainer,
        'iconColor': Colors.white,
        'title': 'You are invited to the event',
        'subtitle': 'Weekend Sunset Bowling by Alex Rivera',
        'time': '10m ago',
        'isUnread': true,
      },
      {
        'type': 'icon',
        'icon': Icons.task_alt,
        'bgColor': secondaryContainer,
        'iconColor': const Color(0xFF0B1C30),
        'title': 'Your request has been approved',
        'subtitle': 'Verified badge approved by community team',
        'time': '1h ago',
        'isUnread': true,
      },
      {
        'type': 'image',
        'imageUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
        'title': 'New comment on your post',
        'subtitle': 'Tanya Sharma: "Love this rooftop spot!"',
        'time': '3h ago',
        'isUnread': false,
      },
      {
        'type': 'image',
        'imageUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
        'title': 'New match connected',
        'subtitle': 'You and Kabir Mehta matched on DEN',
        'time': 'Yesterday',
        'isUnread': false,
      },
      {
        'type': 'icon',
        'icon': Icons.favorite,
        'bgColor': const Color(0xFFFDE8E8),
        'iconColor': const Color(0xFFE02424),
        'title': 'Someone liked your profile photo',
        'subtitle': 'A member in South Delhi sent you a spark',
        'time': '2d ago',
        'isUnread': false,
      },
      {
        'type': 'icon',
        'icon': Icons.notifications_active_outlined,
        'bgColor': const Color(0xFFEDF2F7),
        'iconColor': const Color(0xFF4A5568),
        'title': 'Welcome to DEN community!',
        'subtitle': 'Complete your profile to unlock all social mixers',
        'time': '3d ago',
        'isUnread': false,
      },
    ];

    return Scaffold(
      backgroundColor: bgSurface,
      appBar: AppBar(
        backgroundColor: bgSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: onSurface),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/notifications');
            }
          },
        ),
        title: const Text(
          'Recent Notifications',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: onSurface,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          itemCount: recentItems.length,
          separatorBuilder: (context, index) => const Divider(height: 20, color: Color(0xFFE8E5EE)),
          itemBuilder: (context, index) {
            final item = recentItems[index];
            final isUnread = item['isUnread'] == true;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item['type'] == 'icon')
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: item['bgColor'] as Color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item['icon'] as IconData, color: item['iconColor'] as Color, size: 24),
                  )
                else
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.network(
                      item['imageUrl'] as String,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(child: Icon(Icons.person, color: Colors.black26)),
                    ),
                  ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item['title'] as String,
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 14,
                                fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                                color: onSurface,
                              ),
                            ),
                          ),
                          if (isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2563EB),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item['subtitle'] as String,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 12,
                          color: Color(0xFF6D6D6D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['time'] as String,
                        style: const TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 11,
                          color: Color(0xFFA0A0A0),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
