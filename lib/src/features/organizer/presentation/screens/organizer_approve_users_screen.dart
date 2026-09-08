import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/organizer_audience.dart';
import '../../application/organizer_events_controller.dart';
import '../theme/organizer_theme.dart';

class OrganizerApproveUsersScreen extends ConsumerStatefulWidget {
  const OrganizerApproveUsersScreen({super.key});

  @override
  ConsumerState<OrganizerApproveUsersScreen> createState() =>
      _OrganizerApproveUsersScreenState();
}

class _OrganizerApproveUsersScreenState
    extends ConsumerState<OrganizerApproveUsersScreen> {
  final _linkController = TextEditingController();

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  void _verifyAndApproveLink() {
    final link = _linkController.text.trim();
    if (link.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter or paste a profile link')),
      );
      return;
    }

    // Extract handle or generate approved attendee
    final handle = link.split('/').last.replaceAll('@', '');
    final name = handle.isNotEmpty ? handle : 'Verified Guest';

    final newUser = AudienceUser(
      id: 'app_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      username: handle,
      avatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
      isApproved: true,
      isFollowed: true,
    );

    ref.read(organizerEventsProvider.notifier).approveUser(newUser);

    _linkController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('User @$handle successfully approved!'),
        backgroundColor: OrganizerColors.tertiaryContainer,
      ),
    );
  }

  void _openQrScanner() {
    // Show QR scanning modal/dialog
    showModalBottomSheet(
      context: context,
      backgroundColor: OrganizerColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: OrganizerColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Scan Den Code',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: OrganizerColors.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Align the QR code within the frame to instantly approve attendee.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: OrganizerColors.onSurfaceVariant),
                ),
                const SizedBox(height: 28),
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: OrganizerColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: OrganizerColors.primary,
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.qr_code_scanner,
                      size: 80,
                      color: OrganizerColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () {
                    final scannedUser = AudienceUser(
                      id: 'app_${DateTime.now().millisecondsSinceEpoch}',
                      name: 'Scanned Guest',
                      username: 'den_guest',
                      avatarUrl:
                          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80',
                      isApproved: true,
                      isFollowed: true,
                    );
                    ref
                        .read(organizerEventsProvider.notifier)
                        .approveUser(scannedUser);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Scanned guest approved!'),
                        backgroundColor: OrganizerColors.tertiaryContainer,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OrganizerColors.primary,
                    foregroundColor: OrganizerColors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Simulate Scan Success'),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrganizerColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: OrganizerColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Approve users manually',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: OrganizerColors.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // 1. Scan QR Code Card
            GestureDetector(
              onTap: _openQrScanner,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                decoration: BoxDecoration(
                  color: OrganizerColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: OrganizerColors.primaryFixedDim.withValues(alpha: 0.35),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: OrganizerColors.primary.withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner,
                        size: 52,
                        color: OrganizerColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Scan QR Code',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: OrganizerColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Approve users instantly by scanning their unique den code.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: OrganizerColors.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Paste Link Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: OrganizerColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: OrganizerColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.link,
                          size: 26,
                          color: OrganizerColors.onSurface,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Paste Link',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: OrganizerColors.onSurface,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Approve users by pasting their shared profile link.',
                              style: TextStyle(
                                fontSize: 13,
                                color: OrganizerColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: OrganizerColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: _linkController,
                      maxLines: 3,
                      style: const TextStyle(
                        fontSize: 14,
                        color: OrganizerColors.onSurface,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: 'https://profile.link/...',
                        hintStyle: TextStyle(
                          color: Color(0xFFB0AAB9),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _verifyAndApproveLink,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: OrganizerColors.primary,
                        foregroundColor: OrganizerColors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Verify',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
