import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/organizer_controller.dart';
import '../theme/organizer_theme.dart';

class OrganizerSettingsScreen extends ConsumerWidget {
  const OrganizerSettingsScreen({super.key});

  void _showBioEditDialog(BuildContext context, WidgetRef ref) {
    final profile = ref.read(organizerProvider).profile;
    final controller = TextEditingController(text: profile?.bio ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: OrganizerColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Edit Bio', style: TextStyle(fontWeight: FontWeight.w700)),
          content: TextField(
            controller: controller,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Enter organizer bio...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(organizerProvider.notifier).updateProfile(bio: controller.text.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Bio updated!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: OrganizerColors.primary,
                foregroundColor: OrganizerColors.onPrimary,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          'Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: OrganizerColors.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // Profile
            _buildSettingsTile(
              icon: Icons.person_outline,
              title: 'Profile',
              onTap: () => context.push('/organizer/edit'),
            ),
            const SizedBox(height: 12),

            // Followers
            _buildSettingsTile(
              icon: Icons.group_outlined,
              title: 'Followers',
              onTap: () => context.push('/organizer/followers'),
            ),
            const SizedBox(height: 12),

            // Payments
            _buildSettingsTile(
              icon: Icons.payments_outlined,
              title: 'Payments',
              onTap: () => context.push('/profile/wallet'),
            ),
            const SizedBox(height: 12),

            // Events
            _buildSettingsTile(
              icon: Icons.calendar_today_outlined,
              title: 'Events',
              onTap: () => context.push('/organizer/events/history'),
            ),
            const SizedBox(height: 12),

            // Bio
            _buildSettingsTile(
              icon: Icons.description_outlined,
              title: 'Bio',
              iconColor: OrganizerColors.secondaryContainer,
              iconBgColor: OrganizerColors.secondaryContainer.withValues(alpha: 0.15),
              onTap: () => _showBioEditDialog(context, ref),
            ),
            const SizedBox(height: 12),

            // Account Settings
            _buildSettingsTile(
              icon: Icons.manage_accounts_outlined,
              title: 'Account Settings',
              onTap: () => context.push('/organizer/settings/account'),
            ),
            const SizedBox(height: 12),

            // Help Center
            _buildSettingsTile(
              icon: Icons.help_outline,
              title: 'Help Center',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Help center: support@den.app')),
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? iconBgColor,
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
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconBgColor ?? OrganizerColors.primary.withValues(alpha: 0.1),
              ),
              child: Icon(
                icon,
                color: iconColor ?? OrganizerColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: OrganizerColors.onSurface,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: OrganizerColors.outline,
            ),
          ],
        ),
      ),
    );
  }
}
