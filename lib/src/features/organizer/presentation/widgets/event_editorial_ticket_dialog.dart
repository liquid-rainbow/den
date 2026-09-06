import 'package:den/src/core/widgets/den_image.dart';
import 'package:den/src/features/organizer/domain/models/organizer_event.dart';
import 'package:den/src/features/organizer/presentation/theme/organizer_theme.dart';
import 'package:flutter/material.dart';

class EventEditorialTicketDialog extends StatelessWidget {
  final OrganizerEvent event;
  final String organizerName;
  final String organizerAvatarUrl;

  const EventEditorialTicketDialog({
    super.key,
    required this.event,
    this.organizerName = 'Organizer',
    this.organizerAvatarUrl = '',
  });

  static Future<void> show(
    BuildContext context, {
    required OrganizerEvent event,
    String organizerName = 'Organizer',
    String organizerAvatarUrl = '',
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => EventEditorialTicketDialog(
        event: event,
        organizerName: organizerName,
        organizerAvatarUrl: organizerAvatarUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 360),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 8),

                // Event Title
                Text(
                  event.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 20),

                // Banner image
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: OrganizerColors.surfaceContainer,
                    ),
                    child: DenImage(
                      pathOrUrl: event.imageUrl,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                      placeholder: const Center(
                        child: Icon(Icons.celebration,
                            size: 48, color: OrganizerColors.primary),
                      ),
                      errorWidget: const Center(
                        child: Icon(Icons.celebration,
                            size: 48, color: OrganizerColors.primary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Metadata row: Date • Time • Venue
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF8FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        event.dateLabel.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text('•', style: TextStyle(color: Color(0xFF9CA3AF))),
                      ),
                      Text(
                        event.timeRange.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Text('•', style: TextStyle(color: Color(0xFF9CA3AF))),
                      ),
                      Flexible(
                        child: Text(
                          event.venueName.toUpperCase(),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const Divider(height: 1, color: Color(0xFFF3F4F6)),
                const SizedBox(height: 16),

                // Footer with Host info and DEN watermark
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: OrganizerColors.surfaceContainer,
                          backgroundImage: organizerAvatarUrl.isNotEmpty
                              ? denImageProvider(organizerAvatarUrl)
                              : null,
                          child: organizerAvatarUrl.isEmpty
                              ? const Icon(Icons.person,
                                  size: 16, color: OrganizerColors.primary)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'HOSTED BY',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                            Text(
                              organizerName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Text(
                      'DEN',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: OrganizerColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Share / Done Action
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Event published! Share link ready.'),
                          backgroundColor: OrganizerColors.primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text(
                      'Share Event Ticket',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: OrganizerColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Close button
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
