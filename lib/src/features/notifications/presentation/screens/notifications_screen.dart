import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bgSurface = Color(0xFFFAF8FF);
    const onSurface = Color(0xFF131B2E);
    const primaryColor = Color(0xFF004AC6);
    const primaryContainer = Color(0xFF2563EB);
    const secondaryContainer = Color(0xFFD0E1FB);
    const surfaceVariant = Color(0xFFDAE2FD);

    return Scaffold(
      backgroundColor: bgSurface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Header
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: onSurface,
                  ),
                ),
                const SizedBox(height: 18),

                // Section 1: Recent Notifications
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: onSurface,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.push('/notifications/recent');
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Recent Notification Items (Top 4 items)
                _RecentRow(
                  iconWidget: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.event, color: Colors.white, size: 24),
                  ),
                  text: 'You are invited to the event',
                  hasBorder: true,
                ),

                _RecentRow(
                  iconWidget: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.task_alt, color: Color(0xFF0B1C30), size: 24),
                  ),
                  text: 'Your request has been approved',
                  hasBorder: true,
                ),

                _RecentRow(
                  iconWidget: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(child: Icon(Icons.person, color: Colors.black26)),
                    ),
                  ),
                  text: 'New comment on your post',
                  hasBorder: true,
                ),

                _RecentRow(
                  iconWidget: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(child: Icon(Icons.person, color: Colors.black26)),
                    ),
                  ),
                  text: 'New match connected with Kabir',
                  hasBorder: false,
                ),

                const SizedBox(height: 16),
                Divider(color: surfaceVariant.withValues(alpha: 0.5), height: 1),
                const SizedBox(height: 16),

                // Section 2: Invites
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Invites',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: onSurface,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.push('/notifications/all?tab=invites');
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 2-Column Grid of Latest Invites (Top 4)
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 0.70,
                  children: const [
                    _InviteCard(
                      imageProvider: NetworkImage(
                        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
                      ),
                      badgeText: 'Party Night',
                      message: 'Hey, are you free this weekend?',
                      nameAge: 'Sophia, 24',
                    ),
                    _InviteCard(
                      imageProvider: NetworkImage(
                        'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=400&q=80',
                      ),
                      badgeText: 'Dinner Date',
                      message: 'Let’s check out that new rooftop place.',
                      nameAge: 'Emma, 22',
                    ),
                    _InviteCard(
                      imageProvider: NetworkImage(
                        'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=400&q=80',
                      ),
                      badgeText: 'Coffee Hangout',
                      message: 'Coffee date this Friday?',
                      nameAge: 'Olivia, 25',
                    ),
                    _InviteCard(
                      imageProvider: NetworkImage(
                        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80',
                      ),
                      badgeText: 'Live Concert',
                      message: 'Got an extra ticket for acoustic night!',
                      nameAge: 'Alex, 26',
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentRow extends StatelessWidget {
  final Widget iconWidget;
  final String text;
  final bool hasBorder;

  const _RecentRow({
    required this.iconWidget,
    required this.text,
    required this.hasBorder,
  });

  @override
  Widget build(BuildContext context) {
    const surfaceVariant = Color(0xFFDAE2FD);
    const onSurface = Color(0xFF131B2E);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: hasBorder
            ? Border(bottom: BorderSide(color: surfaceVariant.withValues(alpha: 0.35)))
            : null,
      ),
      child: Row(
        children: [
          iconWidget,
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InviteCard extends StatelessWidget {
  final ImageProvider imageProvider;
  final String badgeText;
  final String message;
  final String nameAge;

  const _InviteCard({
    required this.imageProvider,
    required this.badgeText,
    required this.message,
    required this.nameAge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: imageProvider,
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Gradient Scrim
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.4, 0.6, 1.0],
              ),
            ),
          ),

          // Event Badge
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badgeText,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Message & Details
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                      bottomRight: Radius.circular(14),
                      bottomLeft: Radius.circular(4),
                    ),
                  ),
                  child: Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF131B2E),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  nameAge,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
