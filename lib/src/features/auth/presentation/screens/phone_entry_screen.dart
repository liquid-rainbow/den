import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/den_buttons.dart';
import '../../../../core/widgets/den_logo.dart';
import '../../../../core/widgets/mobile_device_shell.dart';
import '../controllers/auth_controller.dart';

class CountryCodeOption {
  final String code;
  final String label;

  const CountryCodeOption(this.code, this.label);
}

const countryCodes = [
  CountryCodeOption('+91', '+91 🇮🇳'),
  CountryCodeOption('+1', '+1 🇺🇸'),
  CountryCodeOption('+44', '+44 🇬🇧'),
  CountryCodeOption('+971', '+971 🇦🇪'),
  CountryCodeOption('+61', '+61 🇦🇺'),
  CountryCodeOption('+65', '+65 🇸🇬'),
  CountryCodeOption('+49', '+49 🇩🇪'),
  CountryCodeOption('+33', '+33 🇫🇷'),
];

class PhoneEntryScreen extends ConsumerStatefulWidget {
  const PhoneEntryScreen({super.key});

  @override
  ConsumerState<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends ConsumerState<PhoneEntryScreen> {
  // Popup Modal for Terms and Conditions
  void _showTermsDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: const BoxDecoration(
          color: Color(0xFF1B111D),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: Colors.white24)),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'DEN Terms and Conditions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(color: Colors.white10),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: const [
                  Text(
                    'Placeholder Legal Terms:\n\n'
                    '1. Acceptance of Terms\nBy creating a DEN account, you agree to comply with and be bound by these Terms & Conditions.\n\n'
                    '2. User Obligations\nYou represent that all registration information you submit is truthful and accurate.\n\n'
                    '3. Community Conduct\nRespect all members of the DEN community. Zero tolerance for harassment or scraping.\n\n'
                    '4. Modifications\nDEN reserves the right to update these terms at any time. (Edit text later in code as needed).',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D1E2F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('CLOSE', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Popup Modal for Privacy Policy
  void _showPrivacyDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: const BoxDecoration(
          color: Color(0xFF1B111D),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: Colors.white24)),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'DEN Privacy Policy',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(color: Colors.white10),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: const [
                  Text(
                    'Placeholder Privacy Policy:\n\n'
                    '🔒 Data Privacy & Security\nYour digital footprint is locked down. Profiles cannot be scraped, and personal details remain encrypted.\n\n'
                    '📸 Event Media Highlights\nBy participating in DEN physical showcase events, you consent to being recorded and photographed for edited highlights.\n\n'
                    'Edit legal text later in code as needed.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D1E2F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('CLOSE', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authFlowProvider);
    final notifier = ref.read(authFlowProvider.notifier);

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
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 12),

                  Column(
                    children: const [
                      DenLogo(size: 68),
                      SizedBox(height: 12),
                      Text(
                        'Den',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.5,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "for the wild",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Login or sign up',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            children: [
                              DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: state.countryCode,
                                  dropdownColor: const Color(0xFF140D15),
                                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 20),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  onChanged: (value) {
                                    if (value != null) {
                                      notifier.setCountryCode(value);
                                    }
                                  },
                                  items: countryCodes.map((c) {
                                    return DropdownMenuItem<String>(
                                      value: c.code,
                                      child: Text(c.label),
                                    );
                                  }).toList(),
                                ),
                              ),
                              Container(
                                height: 24,
                                width: 1,
                                color: Colors.white30,
                                margin: const EdgeInsets.symmetric(horizontal: 12),
                              ),
                              Expanded(
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(
                                      state.countryCode == '+91' ? 10 : 15,
                                    ),
                                  ],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  onChanged: notifier.setPhone,
                                  decoration: const InputDecoration(
                                    hintText: 'Enter phone number',
                                    hintStyle: TextStyle(color: Colors.white38),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (state.error != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            state.error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFFDA4AF),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),

                        denPrimaryButton(
                          label: 'CONTINUE',
                          isLoading: state.isSubmitting,
                          onPressed: state.isSubmitting
                              ? null
                              : () async {
                                  final success = await notifier.sendOtp();
                                  if (success && context.mounted) {
                                    notifier.resetOtp();
                                    context.go('/auth/otp');
                                  }
                                },
                        ),

                        const SizedBox(height: 16),

                        // Hyperlinked Terms & Privacy Notice
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.6),
                              height: 1.4,
                            ),
                            children: [
                              const TextSpan(text: 'By continuing, you agree to our '),
                              TextSpan(
                                text: 'Terms and Conditions',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()..onTap = _showTermsDialog,
                              ),
                              const TextSpan(text: '\nand '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()..onTap = _showPrivacyDialog,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
