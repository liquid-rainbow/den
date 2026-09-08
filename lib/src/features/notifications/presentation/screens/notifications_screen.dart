import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/notification_controller.dart';
import '../../../organizer/application/organizer_controller.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const bgSurface = Color(0xFFFAF8FF);
    const onSurface = Color(0xFF131B2E);
    const primaryColor = Color(0xFF004AC6);
    const surfaceVariant = Color(0xFFDAE2FD);

    final notificationState = ref.watch(notificationProvider);
    final isOrganizerMode = ref.watch(organizerProvider).activeMode == ProfileMode.organizer;

    // Filter notifications based on mode
    final requests = notificationState.notifications.where((n) => n.type == NotificationType.request).toList();
    final otherNotifications = notificationState.notifications.where((n) => n.type != NotificationType.request).toList();

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
                Text(
                  isOrganizerMode ? 'Aura Collective' : 'Notifications',
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: onSurface,
                  ),
                ),
                const SizedBox(height: 18),

                if (isOrganizerMode) ...[
                  // Organizer Notifications (Requests)
                  if (requests.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text('No pending requests.', style: TextStyle(color: Colors.grey)),
                    ),
                  for (final req in requests)
                    _RequestCard(notification: req),
                ] else ...[
                  // Regular User Notifications
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
                        onPressed: () {},
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

                  if (otherNotifications.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text('No recent notifications.', style: TextStyle(color: Colors.grey)),
                    ),

                  for (int i = 0; i < otherNotifications.length; i++)
                    _NotificationRow(
                      notification: otherNotifications[i],
                      hasBorder: i != otherNotifications.length - 1,
                    ),

                  const SizedBox(height: 16),
                  Divider(color: surfaceVariant.withValues(alpha: 0.5), height: 1),
                  const SizedBox(height: 16),

                  // Invites Section placeholder
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
                        onPressed: () {},
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
                  const Text('No recent invites.', style: TextStyle(color: Colors.grey)),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationRow extends ConsumerWidget {
  final AppNotification notification;
  final bool hasBorder;

  const _NotificationRow({
    required this.notification,
    required this.hasBorder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const surfaceVariant = Color(0xFFDAE2FD);
    const onSurface = Color(0xFF131B2E);
    const primaryContainer = Color(0xFF2563EB);
    const secondaryContainer = Color(0xFFD0E1FB);

    Widget iconWidget;
    if (notification.type == NotificationType.invite) {
      iconWidget = Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: primaryContainer,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.event, color: Colors.white, size: 24),
      );
    } else if (notification.type == NotificationType.approved) {
      iconWidget = Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: secondaryContainer,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.task_alt, color: Color(0xFF0B1C30), size: 24),
      );
    } else {
      iconWidget = ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.network(
          notification.iconUrl ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Center(child: Icon(Icons.person, color: Colors.black26)),
        ),
      );
    }

    return InkWell(
      onTap: () {
        if (notification.type == NotificationType.approved && notification.eventId != null) {
          // Go to ticket
          context.push('/event/${notification.eventId}/ticket');
        } else if (notification.type == NotificationType.invite && notification.eventId != null) {
          // Go to exclusive event details
          context.push('/event/${notification.eventId}?exclusive=true');
        }
      },
      child: Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: const TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: onSurface,
                    ),
                  ),
                  if (notification.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      notification.subtitle!,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              notification.timeString,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 12,
                color: Colors.black45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestCard extends ConsumerWidget {
  final AppNotification notification;

  const _RequestCard({required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  notification.title,
                  style: const TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF131B2E),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                notification.timeString,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 12,
                  color: Colors.black45,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(notificationProvider.notifier).approveRequest(
                          notification.id,
                          notification.eventId ?? 'evt_123',
                          'Silent Dinner Series',
                        );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF361D32),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text('Approve', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(notificationProvider.notifier).rejectRequest(notification.id);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF361D32),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
