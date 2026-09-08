import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:den/src/core/widgets/den_image.dart';
import '../../application/organizer_controller.dart';
import '../theme/organizer_theme.dart';

class OrganizerAccountSettingsScreen extends ConsumerStatefulWidget {
  const OrganizerAccountSettingsScreen({super.key});

  @override
  ConsumerState<OrganizerAccountSettingsScreen> createState() =>
      _OrganizerAccountSettingsScreenState();
}

class _OrganizerAccountSettingsScreenState
    extends ConsumerState<OrganizerAccountSettingsScreen> {
  bool _confirmedDelete = false;

  void _onDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: OrganizerColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Confirm Deletion', style: TextStyle(fontWeight: FontWeight.w700)),
          content: const Text(
            'Are you sure you want to delete your organizer profile? All active events, followers, and organizer data will be permanently removed.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(organizerProvider.notifier).deleteOrganizerProfile();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Organizer profile deleted.')),
                );
                context.go('/profile');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: OrganizerColors.error,
                foregroundColor: OrganizerColors.onPrimary,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(organizerProvider).profile;

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
          'Account Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: OrganizerColors.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Organizer Info Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: OrganizerColors.surfaceContainer,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: DenImage(
                        pathOrUrl: profile?.avatarUrl,
                        fit: BoxFit.cover,
                        errorWidget: const Icon(Icons.business, size: 40),
                        placeholder: const Icon(Icons.business, size: 40),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      profile?.name ?? 'Aura Collective',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: OrganizerColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile?.displayHandle ?? '@aura_collective',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: OrganizerColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Warning 1: Transfer earnings notice
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: OrganizerColors.errorContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: OrganizerColors.errorContainer,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(
                      Icons.info_outline,
                      color: OrganizerColors.error,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Please make sure all your earnings has been transfered to your bank accont otherwise it'll be lost.",
                        style: TextStyle(
                          fontSize: 13,
                          color: OrganizerColors.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Warning 2: Deletion is permanent
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: OrganizerColors.errorContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: OrganizerColors.errorContainer,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: OrganizerColors.error,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Account deletion is permanent and cannot be undone.',
                        style: TextStyle(
                          fontSize: 13,
                          color: OrganizerColors.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Checkbox confirmation
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _confirmedDelete,
                    activeColor: OrganizerColors.primary,
                    onChanged: (val) =>
                        setState(() => _confirmedDelete = val ?? false),
                  ),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Text(
                      'I understand and I want to delete my account',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: OrganizerColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Delete Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _confirmedDelete ? _onDeleteAccount : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OrganizerColors.errorContainer,
                    foregroundColor: OrganizerColors.onErrorContainer,
                    disabledBackgroundColor:
                        OrganizerColors.surfaceContainerHigh,
                    disabledForegroundColor: OrganizerColors.outline,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.delete_forever_outlined, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Delete My Account',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
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
