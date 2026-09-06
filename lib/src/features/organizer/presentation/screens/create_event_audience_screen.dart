import 'package:den/src/features/organizer/application/create_event_controller.dart';
import 'package:den/src/features/organizer/domain/models/create_event_draft.dart';
import 'package:den/src/features/organizer/presentation/theme/organizer_theme.dart';
import 'package:den/src/features/organizer/presentation/widgets/gender_selection_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CreateEventAudienceScreen extends ConsumerStatefulWidget {
  const CreateEventAudienceScreen({super.key});

  @override
  ConsumerState<CreateEventAudienceScreen> createState() =>
      _CreateEventAudienceScreenState();
}

class _CreateEventAudienceScreenState
    extends ConsumerState<CreateEventAudienceScreen> {
  late EventExclusivity _exclusivity;
  late TextEditingController _capacityController;
  late EventGenderRequirement _genderRequirement;
  late bool _requireInstagram;
  late bool _alcoholAvailable;
  late bool _allowCancellation;
  late bool _searchEngineVisible;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(createEventProvider);
    _exclusivity = draft.exclusivity;
    _capacityController = TextEditingController(
      text: draft.capacity != null ? draft.capacity.toString() : 'no limit',
    );
    _genderRequirement = draft.genderRequirement;
    _requireInstagram = draft.requireInstagram;
    _alcoholAvailable = draft.alcoholAvailable;
    _allowCancellation = draft.allowCancellation;
    _searchEngineVisible = draft.searchEngineVisible;
  }

  @override
  void dispose() {
    _capacityController.dispose();
    super.dispose();
  }

  void _onContinue() {
    final capText = _capacityController.text.trim().toLowerCase();
    final cap = (capText == 'no limit' || capText.isEmpty)
        ? null
        : int.tryParse(capText);

    ref.read(createEventProvider.notifier).updateAudienceSettings(
          exclusivity: _exclusivity,
          capacity: cap,
          clearCapacity: cap == null,
          genderRequirement: _genderRequirement,
          requireInstagram: _requireInstagram,
          alcoholAvailable: _alcoholAvailable,
          allowCancellation: _allowCancellation,
          searchEngineVisible: _searchEngineVisible,
        );

    context.push('/organizer/events/create/pricing');
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
        title: ClipRRect(
          borderRadius: BorderRadius.circular(9999),
          child: Container(
            width: 140,
            height: 6,
            color: OrganizerColors.surfaceContainerHigh,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 110,
                height: 6,
                color: OrganizerColors.primary,
              ),
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Define the\nexclusivity of your\ngathering',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: OrganizerColors.onSurface,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 24),

              // Exclusivity Cards (Approved Only vs Open)
              Row(
                children: [
                  Expanded(
                    child: _buildExclusivityCard(
                      EventExclusivity.approvedOnly,
                      'Approved\nguest only',
                      Icons.shield_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildExclusivityCard(
                      EventExclusivity.openToAll,
                      'Open to\neveryone',
                      Icons.public,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Capacity Section
              const Text(
                'What is the capacity of your den?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: OrganizerColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: OrganizerColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: OrganizerColors.surfaceContainerHigh),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.people_outline,
                        color: OrganizerColors.onSurfaceVariant),
                    const SizedBox(width: 12),
                    Container(
                      width: 1,
                      height: 24,
                      color: OrganizerColors.outlineVariant,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _capacityController,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: OrganizerColors.onSurface,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'no limit',
                          hintStyle: TextStyle(
                            fontSize: 15,
                            color: OrganizerColors.outline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Open To? Gender Selector Card
              InkWell(
                onTap: () async {
                  final chosen = await GenderSelectionSheet.show(
                    context,
                    current: _genderRequirement,
                  );
                  if (chosen != null) {
                    setState(() => _genderRequirement = chosen);
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: OrganizerColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: OrganizerColors.surfaceContainerHigh),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline,
                          color: OrganizerColors.onSurface),
                      const SizedBox(width: 12),
                      const Text(
                        'Open to?',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: OrganizerColors.onSurface,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _genderRequirement.label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: OrganizerColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down,
                          size: 20, color: OrganizerColors.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Requirement Checkboxes
              Container(
                decoration: BoxDecoration(
                  color: OrganizerColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: OrganizerColors.surfaceContainerHigh),
                ),
                child: Column(
                  children: [
                    _buildCheckboxTile(
                      title: 'Profiles with Instagram linked',
                      subtitle:
                          'Guests need to add their Instagram before they can join.',
                      value: _requireInstagram,
                      onChanged: (val) =>
                          setState(() => _requireInstagram = val ?? false),
                    ),
                    const Divider(
                        height: 1, color: OrganizerColors.surfaceContainerHigh),
                    _buildCheckboxTile(
                      title: 'Verified profiles only',
                      subtitle:
                          'Guests need to verify their profile before they can join.',
                      badge: 'Coming soon',
                      value: false,
                      onChanged: null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Policy Toggles Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: OrganizerColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: OrganizerColors.surfaceContainerHigh),
                ),
                child: Column(
                  children: [
                    // Alcohol availability
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Alcohol availability',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: OrganizerColors.onSurface,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Is alcohol available at the venue?',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: _alcoholAvailable,
                          onChanged: (val) =>
                              setState(() => _alcoholAvailable = val),
                          activeThumbColor: OrganizerColors.primary,
                        ),
                      ],
                    ),
                    const Divider(
                        height: 24, color: OrganizerColors.surfaceContainerHigh),
                    // Cancellation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Allow guests to cancel',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: OrganizerColors.onSurface,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'When off, bookings are non-refundable.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _allowCancellation,
                          onChanged: (val) =>
                              setState(() => _allowCancellation = val),
                          activeThumbColor: OrganizerColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _onContinue,
                  icon: const SizedBox.shrink(),
                  label: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Save and Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OrganizerColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 3,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExclusivityCard(
      EventExclusivity exclusivity, String title, IconData icon) {
    final isSelected = _exclusivity == exclusivity;
    return GestureDetector(
      onTap: () => setState(() => _exclusivity = exclusivity),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? OrganizerColors.primary.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? OrganizerColors.primary : OrganizerColors.surfaceContainerHigh,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? OrganizerColors.primary
                    : OrganizerColors.surfaceContainerHigh,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : OrganizerColors.onSurfaceVariant,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? OrganizerColors.primary
                    : OrganizerColors.onSurface,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required String subtitle,
    String? badge,
    required bool value,
    required ValueChanged<bool?>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: OrganizerColors.onSurface,
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: OrganizerColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: OrganizerColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: OrganizerColors.primary,
            checkColor: Colors.white,
            side: BorderSide(
              color: value ? OrganizerColors.primary : const Color(0xFF6B7280),
              width: 1.8,
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          ),
        ],
      ),
    );
  }
}
