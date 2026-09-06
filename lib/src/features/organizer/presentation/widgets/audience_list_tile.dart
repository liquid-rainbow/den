import 'package:den/src/core/widgets/den_image.dart';
import 'package:flutter/material.dart';
import '../../domain/models/organizer_audience.dart';
import '../theme/organizer_theme.dart';

class AudienceListTile extends StatelessWidget {
  final AudienceUser user;
  final bool isApprovedView;
  final VoidCallback onActionTap;
  final VoidCallback? onSecondaryActionTap;

  const AudienceListTile({
    super.key,
    required this.user,
    required this.isApprovedView,
    required this.onActionTap,
    this.onSecondaryActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: OrganizerColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: DenImage(
              pathOrUrl: user.avatarUrl,
              fit: BoxFit.cover,
              errorWidget: Container(
                color: OrganizerColors.surfaceContainerHigh,
                child: const Icon(Icons.person, color: OrganizerColors.outline),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name and Username
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: OrganizerColors.onSurface,
                        ),
                      ),
                    ),
                    if (user.isApproved) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: OrganizerColors.tertiaryContainer,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  user.displayHandle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: OrganizerColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Action button
          if (isApprovedView) ...[
            GestureDetector(
              onTap: onActionTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: OrganizerColors.errorContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Revoke',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: OrganizerColors.onErrorContainer,
                  ),
                ),
              ),
            ),
          ] else ...[
            if (user.isFollowed)
              IconButton(
                onPressed: onSecondaryActionTap ?? onActionTap,
                icon: const Icon(Icons.close, size: 20, color: OrganizerColors.onSurfaceVariant),
                style: IconButton.styleFrom(
                  backgroundColor: OrganizerColors.surfaceContainerHighest,
                  shape: const CircleBorder(),
                ),
              )
            else
              GestureDetector(
                onTap: onActionTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: OrganizerColors.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: OrganizerColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Follow',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: OrganizerColors.onPrimary,
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
