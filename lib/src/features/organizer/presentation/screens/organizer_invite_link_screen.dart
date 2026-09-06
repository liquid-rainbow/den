import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/organizer_controller.dart';
import '../../application/organizer_events_controller.dart';
import '../theme/organizer_theme.dart';

class OrganizerInviteLinkScreen extends ConsumerStatefulWidget {
  const OrganizerInviteLinkScreen({super.key});

  @override
  ConsumerState<OrganizerInviteLinkScreen> createState() =>
      _OrganizerInviteLinkScreenState();
}

class _OrganizerInviteLinkScreenState
    extends ConsumerState<OrganizerInviteLinkScreen> {
  bool _copied = false;

  Future<void> _copyLink(String link) async {
    await Clipboard.setData(ClipboardData(text: link));
    setState(() => _copied = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link copied to clipboard!'),
          backgroundColor: OrganizerColors.tertiaryContainer,
        ),
      );
    }
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _copied = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventsState = ref.watch(organizerEventsProvider);
    final organizerState = ref.watch(organizerProvider);
    final handle = organizerState.profile?.username ?? 'aura_collective';

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            children: [
              // Header Icon & Description
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: OrganizerColors.primaryFixedDim.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.link,
                    size: 32,
                    color: OrganizerColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Approval Invite Link',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: OrganizerColors.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Generate a unique link to invite people to join your approved audience.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: OrganizerColors.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // Link Container Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: OrganizerColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'YOUR LINK',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: OrganizerColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Copyable link box with gradient accent
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 48,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  OrganizerColors.primary,
                                  OrganizerColors.secondaryContainer,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              eventsState.inviteLink,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: OrganizerColors.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _copyLink(eventsState.inviteLink),
                            icon: Icon(
                              _copied ? Icons.check : Icons.copy_rounded,
                              color: _copied
                                  ? OrganizerColors.tertiaryContainer
                                  : OrganizerColors.primary,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Info box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: OrganizerColors.secondaryContainer,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Share this link on your socials so people can request to join your approved audience. This link expires in 48 hours.',
                              style: TextStyle(
                                fontSize: 12,
                                color: OrganizerColors.onSurfaceVariant,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Regenerate Link CTA Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    ref
                        .read(organizerEventsProvider.notifier)
                        .regenerateInviteLink(handle);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Generated new invite link!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OrganizerColors.primary,
                    foregroundColor: OrganizerColors.onPrimary,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Regenerate Link',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
