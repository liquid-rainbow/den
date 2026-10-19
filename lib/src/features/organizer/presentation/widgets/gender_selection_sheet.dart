import 'package:den/src/features/organizer/domain/models/create_event_draft.dart';
import 'package:den/src/features/organizer/presentation/theme/organizer_theme.dart';
import 'package:flutter/material.dart';

class GenderSelectionSheet extends StatefulWidget {
  final EventGenderRequirement selected;
  final ValueChanged<EventGenderRequirement> onSelected;

  const GenderSelectionSheet({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static Future<EventGenderRequirement?> show(
    BuildContext context, {
    required EventGenderRequirement current,
  }) {
    return showModalBottomSheet<EventGenderRequirement>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        EventGenderRequirement chosen = current;
        return GenderSelectionSheet(
          selected: chosen,
          onSelected: (val) {
            chosen = val;
          },
        );
      },
    );
  }

  @override
  State<GenderSelectionSheet> createState() => _GenderSelectionSheetState();
}

class _GenderSelectionSheetState extends State<GenderSelectionSheet> {
  late EventGenderRequirement _current;

  @override
  void initState() {
    super.initState();
    _current = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: OrganizerColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pill drag handle
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: OrganizerColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              "Choose the genders you'd like to welcome to your party",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: OrganizerColors.onSurface,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 24),

            // Option: All Genders (Hero container)
            GestureDetector(
              onTap: () => setState(() => _current = EventGenderRequirement.all),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: OrganizerColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _current == EventGenderRequirement.all
                        ? OrganizerColors.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'All genders',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: OrganizerColors.onSurface,
                      ),
                    ),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _current == EventGenderRequirement.all
                            ? OrganizerColors.primary
                            : Colors.transparent,
                        border: Border.all(
                          color: _current == EventGenderRequirement.all
                              ? OrganizerColors.primary
                              : OrganizerColors.outline,
                          width: 2,
                        ),
                      ),
                      child: _current == EventGenderRequirement.all
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Group: Specific Genders
            Container(
              decoration: BoxDecoration(
                color: OrganizerColors.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: OrganizerColors.surfaceContainerHigh),
              ),
              child: Column(
                children: [
                  _buildGenderItem(EventGenderRequirement.men, 'Men'),
                  const Divider(height: 1, color: OrganizerColors.surfaceContainerHigh),
                  _buildGenderItem(EventGenderRequirement.women, 'Women'),
                  const Divider(height: 1, color: OrganizerColors.surfaceContainerHigh),
                  _buildGenderItem(EventGenderRequirement.nonBinary, 'Non-binary'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  widget.onSelected(_current);
                  Navigator.of(context).pop(_current);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: OrganizerColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderItem(EventGenderRequirement requirement, String label) {
    final isSelected = _current == requirement;
    return InkWell(
      onTap: () => setState(() => _current = requirement),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: OrganizerColors.onSurface,
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? OrganizerColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? OrganizerColors.primary : OrganizerColors.outline,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
