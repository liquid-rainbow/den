import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/organizer_events_controller.dart';
import '../theme/organizer_theme.dart';
import '../widgets/audience_list_tile.dart';

class OrganizerFollowersScreen extends ConsumerStatefulWidget {
  const OrganizerFollowersScreen({super.key});

  @override
  ConsumerState<OrganizerFollowersScreen> createState() =>
      _OrganizerFollowersScreenState();
}

class _OrganizerFollowersScreenState
    extends ConsumerState<OrganizerFollowersScreen> {
  int _activeTab = 0; // 0: Followers, 1: Approved

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(organizerEventsProvider);

    return Scaffold(
      backgroundColor: OrganizerColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: OrganizerColors.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: [
            // Action card 1: Approve users manually
            _buildNavigationCard(
              title: 'Approve users manually',
              onTap: () => context.push('/organizer/approve'),
            ),
            const SizedBox(height: 12),

            // Action card 2: Approval invite link
            _buildNavigationCard(
              title: 'Approval invite link',
              onTap: () => context.push('/organizer/invite-link'),
            ),
            const SizedBox(height: 24),

            // Segmented Pill Tabs (Followers vs Approved)
            Container(
              decoration: BoxDecoration(
                color: OrganizerColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTab = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _activeTab == 0
                              ? OrganizerColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: _activeTab == 0
                              ? [
                                  BoxShadow(
                                    color: OrganizerColors.primary
                                        .withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          'Followers',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _activeTab == 0
                                ? OrganizerColors.onPrimary
                                : OrganizerColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTab = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _activeTab == 1
                              ? OrganizerColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: _activeTab == 1
                              ? [
                                  BoxShadow(
                                    color: OrganizerColors.primary
                                        .withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          'Approved',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _activeTab == 1
                                ? OrganizerColors.onPrimary
                                : OrganizerColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // List of followers or approved users
            if (_activeTab == 0) ...[
              if (state.followers.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'No followers yet',
                      style: TextStyle(color: OrganizerColors.onSurfaceVariant),
                    ),
                  ),
                )
              else
                ...state.followers.map(
                  (user) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AudienceListTile(
                      user: user,
                      isApprovedView: false,
                      onActionTap: () => ref
                          .read(organizerEventsProvider.notifier)
                          .toggleFollow(user.id),
                      onSecondaryActionTap: () => ref
                          .read(organizerEventsProvider.notifier)
                          .removeFollower(user.id),
                    ),
                  ),
                ),
            ] else ...[
              if (state.approvedUsers.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text(
                      'No approved users yet',
                      style: TextStyle(color: OrganizerColors.onSurfaceVariant),
                    ),
                  ),
                )
              else
                ...state.approvedUsers.map(
                  (user) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AudienceListTile(
                      user: user,
                      isApprovedView: true,
                      onActionTap: () => ref
                          .read(organizerEventsProvider.notifier)
                          .revokeApproval(user.id),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationCard({
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: OrganizerColors.onSurface,
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: OrganizerColors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
