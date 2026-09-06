import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../application/organizer_controller.dart';
import '../theme/organizer_theme.dart';

class OrganizerVerifyPhoneScreen extends ConsumerStatefulWidget {
  const OrganizerVerifyPhoneScreen({super.key});

  @override
  ConsumerState<OrganizerVerifyPhoneScreen> createState() =>
      _OrganizerVerifyPhoneScreenState();
}

class _OrganizerVerifyPhoneScreenState
    extends ConsumerState<OrganizerVerifyPhoneScreen> {
  late final TextEditingController _phoneController;
  String _selectedCountryCode = '+91';
  String _selectedFlag = '🇮🇳';

  final List<Map<String, String>> _countryCodes = [
    {'code': '+91', 'flag': '🇮🇳', 'name': 'India'},
    {'code': '+1', 'flag': '🇺🇸', 'name': 'United States'},
    {'code': '+44', 'flag': '🇬🇧', 'name': 'United Kingdom'},
    {'code': '+61', 'flag': '🇦🇺', 'name': 'Australia'},
    {'code': '+49', 'flag': '🇩🇪', 'name': 'Germany'},
    {'code': '+33', 'flag': '🇫🇷', 'name': 'France'},
    {'code': '+81', 'flag': '🇯🇵', 'name': 'Japan'},
  ];

  @override
  void initState() {
    super.initState();
    final draft = ref.read(organizerProvider).draft;
    _phoneController = TextEditingController(text: draft.phoneNumber);
    _selectedCountryCode = draft.countryCode.isNotEmpty ? draft.countryCode : '+91';
    for (final c in _countryCodes) {
      if (c['code'] == _selectedCountryCode) {
        _selectedFlag = c['flag']!;
        break;
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: OrganizerColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: OrganizerColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select Country',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: OrganizerColors.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _countryCodes.length,
                  itemBuilder: (context, index) {
                    final item = _countryCodes[index];
                    return ListTile(
                      leading: Text(item['flag']!, style: const TextStyle(fontSize: 22)),
                      title: Text(
                        item['name']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: OrganizerColors.onSurface,
                        ),
                      ),
                      trailing: Text(
                        item['code']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: OrganizerColors.primary,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedCountryCode = item['code']!;
                          _selectedFlag = item['flag']!;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onSubmit() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number')),
      );
      return;
    }

    ref.read(organizerProvider.notifier).updateDraft(
          phoneNumber: phone,
          countryCode: _selectedCountryCode,
        );

    // Complete setup and transition to organizer profile
    ref.read(organizerProvider.notifier).completeSetup();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Organizer Profile created successfully!'),
        backgroundColor: OrganizerColors.tertiaryContainer,
      ),
    );

    // Navigate to organizer profile screen
    context.go('/organizer/profile');
  }

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              // Title
              const Text(
                'Enter a phone number to verify your instagram',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: OrganizerColors.onSurface,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              const Text(
                "We'll call you soon",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: OrganizerColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 36),

              // Phone Number Input with Country Code Selector
              Container(
                height: 56,
                decoration: BoxDecoration(
                  color: OrganizerColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _showCountryPicker,
                      child: Row(
                        children: [
                          Text(_selectedFlag, style: const TextStyle(fontSize: 20)),
                          const SizedBox(width: 6),
                          Text(
                            _selectedCountryCode,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: OrganizerColors.onSurface,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.expand_more,
                            size: 18,
                            color: OrganizerColors.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 24,
                      color: OrganizerColors.surfaceDim,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(
                            _selectedCountryCode == '+91' ? 10 : 15,
                          ),
                        ],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: OrganizerColors.onSurface,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          hintText: '000 000 0000',
                          hintStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFFB0AAB9),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OrganizerColors.primary,
                    foregroundColor: OrganizerColors.onPrimary,
                    elevation: 4,
                    shadowColor: OrganizerColors.primary.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
