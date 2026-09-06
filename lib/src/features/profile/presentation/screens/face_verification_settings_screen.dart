import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/mobile_device_shell.dart';
import '../../../profile/application/profile_controller.dart';
import '../../../onboarding/data/repositories/face_verification_repository_impl.dart';

class FaceVerificationSettingsScreen extends ConsumerStatefulWidget {
  const FaceVerificationSettingsScreen({super.key});

  @override
  ConsumerState<FaceVerificationSettingsScreen> createState() =>
      _FaceVerificationSettingsScreenState();
}

class _FaceVerificationSettingsScreenState extends ConsumerState<FaceVerificationSettingsScreen> {
  FaceVerificationRepositoryImpl get _repository => ref.read(faceVerificationRepositoryProvider);
  bool _isLoading = false;
  String? _statusMessage;
  String? _errorMessage;

  Future<void> _startVerification() async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
      _errorMessage = null;
    });

    try {
      final sessionId = await _repository.createLivenessSession();
      final isLive = await _repository.verifyFace(sessionId: sessionId);
      if (!mounted) return;
      if (isLive) {
        ref.read(profileStateProvider.notifier).updateFaceVerification(true);
        setState(() {
          _statusMessage = 'Face verification completed successfully.';
        });
      } else {
        setState(() {
          _errorMessage = 'Face verification did not pass.';
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Verification could not start because the backend is unavailable: ${error.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
                      'Face verification',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F4F2),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFE6E3E1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3E2723),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(Icons.face_retouching_natural, color: Colors.white),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        profile.isFaceVerified ? 'Verified' : 'Not verified yet',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Users can finish this later from settings if they skipped onboarding.',
                                        style: TextStyle(fontSize: 12, color: Color(0xFF6D6D6D), height: 1.35),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'This page reuses the same AWS Rekognition liveness flow the onboarding step uses. If the backend is not deployed yet, the request will fail honestly instead of faking a success.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black.withValues(alpha: 0.68),
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _startVerification,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3E2723),
                                  foregroundColor: Colors.white,
                                  shape: const StadiumBorder(),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.4,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Verify now'),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton(
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                        context.go('/profile/settings');
                                      },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.black87,
                                  side: const BorderSide(color: Color(0xFFE0E0E0)),
                                  shape: const StadiumBorder(),
                                ),
                                child: const Text('Back to settings'),
                              ),
                            ),
                            if (_statusMessage != null) ...[
                              const SizedBox(height: 14),
                              Text(
                                _statusMessage!,
                                style: const TextStyle(
                                  color: Color(0xFF1F7A4A),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 14),
                              Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Color(0xFFB00020),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
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
