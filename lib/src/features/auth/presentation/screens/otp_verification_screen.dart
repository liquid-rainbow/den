import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app.dart';
import '../../../../core/widgets/den_buttons.dart';
import '../../../../core/widgets/mobile_device_shell.dart';
import '../controllers/auth_controller.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final FocusNode _hiddenFocusNode = FocusNode();
  late final TextEditingController _otpController;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController(text: ref.read(authFlowProvider).otpCode);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hiddenFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _hiddenFocusNode.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authFlowProvider);
    final notifier = ref.read(authFlowProvider.notifier);

    if (state.otpCode != _otpController.text) {
      final newValue = state.otpCode;
      _otpController.value = TextEditingValue(
        text: newValue,
        selection: TextSelection.collapsed(offset: newValue.length),
      );
    }

    return MobileDeviceShell(
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF2D1E2F),
                Color(0xFF140D15),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white70, size: 26),
                        onPressed: () {
                          notifier.resetOtp();
                          context.go('/auth/phone');
                        },
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Verify your number',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        state.fullPhoneNumber,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          notifier.resetOtp();
                          context.go('/auth/phone');
                        },
                        child: const Icon(Icons.edit, color: Colors.white70, size: 18),
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),

                  // Boxless Dot-to-Number OTP Display
                  GestureDetector(
                    onTap: () => _hiddenFocusNode.requestFocus(),
                    behavior: HitTestBehavior.opaque,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Opacity(
                          opacity: 0,
                          child: TextField(
                            controller: _otpController,
                            focusNode: _hiddenFocusNode,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            onChanged: notifier.setOtpCode,
                            decoration: const InputDecoration(
                              counterText: '',
                            ),
                          ),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(6, (index) {
                            final code = state.otpCode;
                            final isFilled = index < code.length;
                            final char = isFilled ? code[index] : '';
                            final isCurrent = index == code.length || (code.length == 6 && index == 5);

                            return SizedBox(
                              width: 44,
                              height: 56,
                              child: Center(
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  transitionBuilder: (Widget child, Animation<double> animation) {
                                    return ScaleTransition(scale: animation, child: child);
                                  },
                                  child: isFilled
                                      ? Text(
                                          char,
                                          key: ValueKey('digit_${index}_$char'),
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                            shadows: [
                                              Shadow(
                                                color: Colors.white.withValues(alpha: 0.6),
                                                blurRadius: 10,
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container(
                                          key: ValueKey('dot_$index'),
                                          width: isCurrent ? 12 : 8,
                                          height: isCurrent ? 12 : 8,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isCurrent
                                                ? Colors.white.withValues(alpha: 0.9)
                                                : Colors.white24,
                                            boxShadow: isCurrent
                                                ? [
                                                    BoxShadow(
                                                      color: Colors.white.withValues(alpha: 0.6),
                                                      blurRadius: 8,
                                                      spreadRadius: 2,
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                        ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),

                  if (state.error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      state.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFFDA4AF),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${state.timerSeconds}s ',
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      TextButton(
                        onPressed: state.timerSeconds == 0 ? notifier.resendOtp : null,
                        child: Text(
                          'Resend OTP',
                          style: TextStyle(
                            color: state.timerSeconds == 0 ? Colors.white : Colors.white38,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Simple Continue Button
                  denPrimaryButton(
                    label: 'CONTINUE',
                    isLoading: state.isSubmitting,
                    onPressed: (state.otpCode.length != 6 || state.isSubmitting)
                        ? null
                        : () async {
                            final success = await notifier.verifyOtp();
                            if (success && context.mounted) {
                              ref.read(authStateProvider.notifier).updateAuth(
                                    isAuthenticated: true,
                                    hasAcceptedGuardrail: true,
                                    isOnboardingComplete: false,
                                  );
                            }
                          },
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
