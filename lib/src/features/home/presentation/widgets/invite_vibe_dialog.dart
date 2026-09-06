import 'package:flutter/material.dart';
import 'share_event_bottom_sheet.dart';

class InviteVibeDialog extends StatelessWidget {
  const InviteVibeDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (context) => const InviteVibeDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "who's your vibe?",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 40,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(
                    Icons.close,
                    color: Colors.black87,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: _VibeCard(
                    iconData: Icons.person_add_alt_1_outlined, // Placeholder for person + chat
                    title: 'Invite a\nstranger',
                    isDark: false,
                    onTap: () {
                      Navigator.of(context).pop();
                      // Handle stranger invite
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _VibeCard(
                    iconData: Icons.people_alt_outlined,
                    title: 'Invite your\nfriend',
                    isDark: true,
                    onTap: () {
                      Navigator.of(context).pop();
                      ShareEventBottomSheet.show(context);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Divider(
              color: Colors.grey.shade200,
              height: 1,
              thickness: 1,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _VibeCard extends StatelessWidget {
  final IconData iconData;
  final String title;
  final bool isDark;
  final VoidCallback onTap;

  const _VibeCard({
    required this.iconData,
    required this.title,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final darkBg = const Color(0xFF261F2C);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        decoration: BoxDecoration(
          color: isDark ? darkBg : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isDark ? null : Border.all(color: Colors.black87, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                iconData,
                color: isDark ? Colors.white : Colors.black87,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
