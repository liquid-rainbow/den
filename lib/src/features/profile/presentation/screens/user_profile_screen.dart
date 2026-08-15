import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('[NAV_LOGCAT] Rendered UserProfileScreen (Route: /profile)');
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'USER PROFILE: My Profile (Editable)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                debugPrint('[NAV_LOGCAT] Navigating from Profile to Settings (/settings)');
                context.go('/settings');
              },
              icon: const Icon(Icons.settings),
              label: const Text('Go to Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
