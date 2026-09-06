import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NotificationType {
  invite,
  request,
  approved,
  standard,
}

class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String? subtitle;
  final String timeString;
  final String? eventId;
  final String? requesterName;
  final String? iconUrl; // URL for standard/invite icons

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    required this.timeString,
    this.eventId,
    this.requesterName,
    this.iconUrl,
  });

  AppNotification copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? subtitle,
    String? timeString,
    String? eventId,
    String? requesterName,
    String? iconUrl,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      timeString: timeString ?? this.timeString,
      eventId: eventId ?? this.eventId,
      requesterName: requesterName ?? this.requesterName,
      iconUrl: iconUrl ?? this.iconUrl,
    );
  }
}

class NotificationState {
  final List<AppNotification> notifications;

  NotificationState({this.notifications = const []});

  NotificationState copyWith({List<AppNotification>? notifications}) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
    );
  }
}

class NotificationController extends Notifier<NotificationState> {
  @override
  NotificationState build() {
    return NotificationState(
      notifications: [
        AppNotification(
          id: 'n1',
          type: NotificationType.invite,
          title: "You're invited to Silent Dinner Series!",
          timeString: '1h',
          eventId: 'evt_123',
          iconUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
        ),
      ],
    );
  }

  void addRequestNotification(String eventId, String eventName, String requesterName) {
    final newNotif = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: NotificationType.request,
      title: "$requesterName has requested to join $eventName.",
      timeString: 'just now',
      eventId: eventId,
      requesterName: requesterName,
    );
    state = state.copyWith(notifications: [newNotif, ...state.notifications]);
  }

  void approveRequest(String notificationId, String eventId, String eventName) {
    // Remove the request notification
    final updatedList = state.notifications.where((n) => n.id != notificationId).toList();
    
    // Add the "Approved" notification for the user
    final approvedNotif = AppNotification(
      id: 'app_${DateTime.now().millisecondsSinceEpoch}',
      type: NotificationType.approved,
      title: "Your request to join $eventName has been approved!",
      timeString: 'just now',
      eventId: eventId,
    );
    
    state = state.copyWith(notifications: [approvedNotif, ...updatedList]);
  }

  void rejectRequest(String notificationId) {
    final updatedList = state.notifications.where((n) => n.id != notificationId).toList();
    state = state.copyWith(notifications: updatedList);
  }
}

final notificationProvider = NotifierProvider<NotificationController, NotificationState>(() {
  return NotificationController();
});
