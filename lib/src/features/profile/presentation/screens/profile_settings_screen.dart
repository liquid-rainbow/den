import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/den_colors.dart';
import '../../../profile/application/profile_controller.dart';

class ProfileSettingsScreen extends ConsumerWidget {
  const ProfileSettingsScreen({super.key});

  void _showEditPersonalDetail(
    BuildContext context,
    WidgetRef ref,
    String title,
    String currentValue,
    Function(String) onSave,
  ) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Edit $title', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(fontSize: 15, color: Color(0xFF131B2E), fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: 'Enter $title',
              hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF8E8E93)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
            ),
            ElevatedButton(
              onPressed: () {
                final val = controller.text.trim();
                if (val.isNotEmpty) {
                  onSave(val);
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: DenColors.primary,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
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
    final profile = ref.watch(profileStateProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
            }
          },
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.black,
            letterSpacing: -0.4,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // 1. Verify your profile Card (Shield Icon)
            _SettingsActionCard(
              icon: Icons.shield_outlined,
              iconColor: const Color(0xFF6B21A8),
              iconBgColor: const Color(0xFFF3E8FF),
              title: 'Verify your profile',
              trailing: profile.isFaceVerified
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('Verified', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1F7A4A))),
                    )
                  : null,
              onTap: () => context.go('/profile/face-verification'),
            ),
            const SizedBox(height: 12),

            // 2. Profile Card (Person Icon)
            _SettingsActionCard(
              icon: Icons.person_outline,
              iconColor: const Color(0xFF6B21A8),
              iconBgColor: const Color(0xFFF3E8FF),
              title: 'Profile',
              onTap: () => context.push('/profile/edit'),
            ),
            const SizedBox(height: 12),

            // 3. Following Card (Wallet / Card Icon)
            _SettingsActionCard(
              icon: Icons.account_balance_wallet_outlined,
              iconColor: const Color(0xFF6B21A8),
              iconBgColor: const Color(0xFFF3E8FF),
              title: 'Following',
              onTap: () => context.push('/profile/following'),
            ),
            const SizedBox(height: 12),

            // Geofencing Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFEFEBF5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Discovery Distance',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        '${profile.searchRadiusKm} km',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: DenColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: DenColors.primary,
                      inactiveTrackColor: const Color(0xFFEFEBF5),
                      thumbColor: DenColors.primary,
                      overlayColor: DenColors.primary.withValues(alpha: 0.1),
                    ),
                    child: Slider(
                      value: profile.searchRadiusKm.toDouble(),
                      min: 10,
                      max: 50,
                      divisions: 40,
                      onChanged: (value) {
                        ref.read(profileStateProvider.notifier).updateSearchRadius(value.toInt());
                      },
                    ),
                  ),
                  const Text(
                    'We will only show people and events within this radius.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8E8E93),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 4. Group Card for Personal Details (Age, Gender, Height)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFEFEBF5)),
              ),
              child: Column(
                children: [
                  _PersonalDetailRow(
                    label: 'Age',
                    value: profile.age > 0 ? '${profile.age}' : 'Add age',
                    hasBorder: true,
                    onTap: () {
                      _showEditPersonalDetail(context, ref, 'Age', profile.age > 0 ? '${profile.age}' : '', (val) {
                        final parsed = int.tryParse(val);
                        if (parsed != null && parsed >= 18) {
                          ref.read(profileStateProvider.notifier).updateAge(parsed);
                        }
                      });
                    },
                  ),
                  _PersonalDetailRow(
                    label: 'Gender',
                    value: profile.gender.isNotEmpty ? profile.gender : 'Add gender',
                    hasBorder: true,
                    onTap: () {
                      _showEditPersonalDetail(context, ref, 'Gender', profile.gender, (val) {
                        ref.read(profileStateProvider.notifier).updateGender(val);
                      });
                    },
                  ),
                  _PersonalDetailRow(
                    label: 'Height',
                    value: profile.heightLabel.isNotEmpty ? profile.heightLabel : 'Add height',
                    hasBorder: false,
                    onTap: () {
                      _showEditPersonalDetail(context, ref, 'Height', '${profile.heightCm}', (val) {
                        final parsed = int.tryParse(val);
                        if (parsed != null) {
                          ref.read(profileStateProvider.notifier).updateHeight(parsed);
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 5. Help Center Card (Question Mark Icon)
            _SettingsActionCard(
              icon: Icons.help_outline_rounded,
              iconColor: const Color(0xFF6B21A8),
              iconBgColor: const Color(0xFFF3E8FF),
              title: 'Help Center',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Help Center: support@den.app')),
                );
              },
            ),
            const SizedBox(height: 36),

            // 6. Delete Account Subtle Action
            Center(
              child: TextButton(
                onPressed: () => context.push('/profile/delete-account'),
                child: const Text(
                  'Delete account',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8E8E93),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SettingsActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsActionCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEFEBF5)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

class _PersonalDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool hasBorder;
  final VoidCallback onTap;

  const _PersonalDetailRow({
    required this.label,
    required this.value,
    required this.hasBorder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: hasBorder
              ? const Border(bottom: BorderSide(color: Color(0xFFF2EEF7)))
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: value.startsWith('Add') ? const Color(0xFF8E8E93) : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
