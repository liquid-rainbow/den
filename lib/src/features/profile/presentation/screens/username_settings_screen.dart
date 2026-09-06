import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/profile_api_repository.dart';
import 'package:go_router/go_router.dart';

import '../../../../app.dart';
import '../../../../core/widgets/mobile_device_shell.dart';
import '../../../profile/application/profile_controller.dart';

class UsernameSettingsScreen extends ConsumerStatefulWidget {
  const UsernameSettingsScreen({super.key});

  @override
  ConsumerState<UsernameSettingsScreen> createState() => _UsernameSettingsScreenState();
}

class _UsernameSettingsScreenState extends ConsumerState<UsernameSettingsScreen> {
  ProfileApiRepository get _repo => ref.read(profileApiRepositoryProvider);
  late final TextEditingController _controller;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(profileStateProvider).username);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileStateProvider);

    return MobileDeviceShell(
      outerBackgroundColor: const Color(0xFFF3F2F0),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/profile');
                        }
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Username',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE6E3E1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Public handle',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.black),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This is the username other people will see on your profile.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black.withValues(alpha: 0.6),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          prefixText: '@',
                          hintText: 'your_username',
                          border: UnderlineInputBorder(),
                        ),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Current preview: @${profile.username}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF6D6D6D)),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isSaving
                              ? null
                              : () async {
                                  final nextValue = _controller.text.trim().replaceAll(RegExp(r'^@'), '');
                                  if (nextValue.isEmpty) return;

                                  final token = ref.read(authStateProvider).sessionToken;
                                  if (token == null || token.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Please sign in again.')),
                                    );
                                    return;
                                  }

                                  setState(() => _isSaving = true);
                                  try {
                                    final user = await _repo.updateProfile(
                                      sessionToken: token,
                                      payload: {'username': nextValue},
                                    );
                                    if (!context.mounted) return;
                                    ref.read(profileStateProvider.notifier).updateUsername(
                                          user['instagramUsername']?.toString() ?? nextValue,
                                        );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Username updated')),
                                    );
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Could not save username: $e')),
                                    );
                                  } finally {
                                    if (mounted) {
                                      setState(() => _isSaving = false);
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3E2723),
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Save username'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
