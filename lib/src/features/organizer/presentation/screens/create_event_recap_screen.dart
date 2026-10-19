import 'dart:io';
import 'package:den/src/features/organizer/application/create_event_controller.dart';
import 'package:den/src/features/organizer/application/organizer_controller.dart';
import 'package:den/src/features/organizer/domain/models/create_event_draft.dart';
import 'package:den/src/features/organizer/presentation/theme/organizer_theme.dart';
import 'package:den/src/features/organizer/presentation/widgets/event_editorial_ticket_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class CreateEventRecapScreen extends ConsumerWidget {
  const CreateEventRecapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(createEventProvider);
    final organizer = ref.watch(organizerProvider).profile;

    final eventDate = draft.date ?? DateTime.now();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    final monthShort = months[eventDate.month - 1];
    final dayNumber = eventDate.day.toString();
    final yearShort = eventDate.year.toString().substring(2);
    final weekdayName = weekdays[eventDate.weekday - 1];
    final timeStr = draft.endTime != null
        ? '${draft.startTime} - ${draft.endTime}'
        : draft.startTime;

    return Scaffold(
      backgroundColor: OrganizerColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: OrganizerColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              draft.category.label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: OrganizerColors.onSurface,
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => context.push('/organizer/events/create/category'),
              child: const Icon(Icons.edit_outlined,
                  size: 16, color: OrganizerColors.outline),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Gallery Section
              const Text(
                'Banner Image',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: OrganizerColors.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Add up to 4 photos or videos',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 12),

              // Main Banner
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  height: 190,
                  width: double.infinity,
                  color: OrganizerColors.surfaceContainerLow,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: draft.bannerUrl.isNotEmpty
                            ? (draft.bannerUrl.startsWith('http')
                                ? Image.network(
                                    draft.bannerUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Center(
                                      child: Icon(Icons.celebration,
                                          size: 48,
                                          color: OrganizerColors.primary),
                                    ),
                                  )
                                : Image.file(
                                    File(draft.bannerUrl),
                                    fit: BoxFit.cover,
                                  ))
                            : const Center(
                                child: Icon(Icons.celebration,
                                    size: 48, color: OrganizerColors.primary),
                              ),
                      ),
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: GestureDetector(
                          onTap: () async {
                            final picker = ImagePicker();
                            final picked = await picker.pickImage(source: ImageSource.gallery);
                            if (picked != null) {
                              ref.read(createEventProvider.notifier).updateBasicDetails(bannerUrl: picked.path);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: OrganizerColors.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.edit,
                                size: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 3 Mini Gallery Slots
              Row(
                children: List.generate(3, (index) {
                  final hasPhoto = index < draft.galleryUrls.length;
                  final photoUrl = hasPhoto ? draft.galleryUrls[index] : null;

                  return Expanded(
                    child: Container(
                      height: 90,
                      margin: EdgeInsets.only(right: index < 2 ? 10 : 0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: OrganizerColors.surfaceContainerHigh,
                          style: BorderStyle.solid,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: hasPhoto
                          ? Stack(
                              children: [
                                Positioned.fill(
                                  child: photoUrl!.startsWith('http')
                                      ? Image.network(
                                          photoUrl,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          File(photoUrl),
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      ref
                                          .read(createEventProvider.notifier)
                                          .removeGalleryPhoto(index);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close,
                                          size: 12, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : InkWell(
                              onTap: () async {
                                final picker = ImagePicker();
                                final picked = await picker.pickImage(
                                    source: ImageSource.gallery);
                                if (picked != null) {
                                  ref
                                      .read(createEventProvider.notifier)
                                      .addGalleryPhoto(picked.path);
                                }
                              },
                              child: const Center(
                                child: Icon(Icons.add,
                                    color: OrganizerColors.primary, size: 26),
                              ),
                            ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),

              // Basic Info Card (Name)
              _buildRecapCard(
                title: 'NAME',
                content: Text(
                  draft.title.isNotEmpty
                      ? draft.title
                      : '${draft.category.label} Gathering',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: OrganizerColors.primary,
                  ),
                ),
                onEdit: () =>
                    context.push('/organizer/events/create/details'),
              ),
              const SizedBox(height: 14),

              // Date & Time Cards
              Row(
                children: [
                  Expanded(
                    child: _buildDateTimeCard(
                      title: 'Date',
                      primary: "$dayNumber $monthShort '$yearShort",
                      secondary: weekdayName,
                      icon: Icons.calendar_today_outlined,
                      onTap: () => context
                          .push('/organizer/events/create/details'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDateTimeCard(
                      title: 'Time',
                      primary: timeStr,
                      secondary: 'Starts promptly',
                      icon: Icons.schedule,
                      onTap: () => context
                          .push('/organizer/events/create/details'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Venue Card
              _buildRecapCard(
                title: 'VENUE',
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      draft.venueName.isNotEmpty
                          ? draft.venueName
                          : 'Vijay Nagar',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: OrganizerColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      draft.venueAddress.isNotEmpty
                          ? draft.venueAddress
                          : 'Vijay Nagar, Delhi, 110009, India',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                actionWidget: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: OrganizerColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.location_on,
                      size: 18, color: Colors.white),
                ),
                onEdit: () =>
                    context.push('/organizer/events/create/location'),
              ),
              const SizedBox(height: 14),

              // Capacity & Gender Target Card
              _buildRecapCard(
                title: 'CAPACITY & CROWD',
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      draft.genderRequirement.label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: OrganizerColors.onSurface,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: OrganizerColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        draft.capacity != null
                            ? '${draft.capacity} spots'
                            : 'No limit',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: OrganizerColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                onEdit: () =>
                    context.push('/organizer/events/create/audience'),
              ),
              const SizedBox(height: 14),

              // Exclusivity Card
              _buildRecapCard(
                title: 'EXCLUSIVITY',
                content: Text(
                  draft.exclusivity == EventExclusivity.approvedOnly
                      ? 'Approved audience only'
                      : 'Open to everyone',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: OrganizerColors.onSurface,
                  ),
                ),
                onEdit: () =>
                    context.push('/organizer/events/create/audience'),
              ),
              const SizedBox(height: 14),

              // Additional Settings Toggles Summary
              _buildRecapCard(
                title: 'ADDITIONAL SETTINGS',
                content: Column(
                  children: [
                    _buildSettingSummaryRow(
                      'Profiles with Instagram linked',
                      draft.requireInstagram,
                    ),
                    const Divider(height: 16),
                    _buildSettingSummaryRow(
                      'Alcohol permitted',
                      draft.alcoholAvailable,
                    ),
                    const Divider(height: 16),
                    _buildSettingSummaryRow(
                      'Allow guests to cancel',
                      draft.allowCancellation,
                    ),
                  ],
                ),
                onEdit: () =>
                    context.push('/organizer/events/create/audience'),
              ),
              const SizedBox(height: 14),

              // Pricing Details & Platform Fee
              _buildRecapCard(
                title: 'PRICING DETAILS',
                content: Column(
                  children: [
                    if (draft.pricingType == EventPricingType.free)
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Free Event',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: OrganizerColors.primary,
                          ),
                        ),
                      )
                    else ...[
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: OrganizerColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Guest pays',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF6B7280)),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '₹${draft.guestEstimatedPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      color: OrganizerColors.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: OrganizerColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'You get',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF6B7280)),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '₹${draft.hostEstimatedEarnings.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      color: OrganizerColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Host Platform fee',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B7280)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: OrganizerColors.primary
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '5%',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: OrganizerColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                onEdit: () =>
                    context.push('/organizer/events/create/pricing'),
              ),
              const SizedBox(height: 14),

              // Description Card
              _buildRecapCard(
                title: 'DESCRIPTION & RULES',
                content: Text(
                  draft.description.isNotEmpty
                      ? draft.description
                      : 'No description provided.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4B5563),
                    height: 1.4,
                  ),
                ),
                onEdit: () =>
                    context.push('/organizer/events/create/description'),
              ),
              const SizedBox(height: 36),

              // Publish Event Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final createdEvent = ref
                        .read(createEventProvider.notifier)
                        .publishEvent();

                    EventEditorialTicketDialog.show(
                      context,
                      event: createdEvent,
                      organizerName: organizer?.name ?? 'Organizer',
                      organizerAvatarUrl: organizer?.avatarUrl ?? '',
                    );

                    context.go('/organizer/profile');
                  },
                  icon: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4ADE80),
                      shape: BoxShape.circle,
                    ),
                  ),
                  label: const Text(
                    'Publish Event',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OrganizerColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecapCard({
    required String title,
    required Widget content,
    Widget? actionWidget,
    required VoidCallback onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: OrganizerColors.surfaceContainerHigh),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: Color(0xFF9CA3AF),
                ),
              ),
              GestureDetector(
                onTap: onEdit,
                child: const Icon(Icons.edit_outlined,
                    size: 16, color: OrganizerColors.outline),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: content),
              ?actionWidget,
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeCard({
    required String title,
    required String primary,
    required String secondary,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: OrganizerColors.surfaceContainerHigh),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: OrganizerColors.onSurface,
                  ),
                ),
                Icon(icon, size: 16, color: OrganizerColors.outline),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              primary,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: OrganizerColors.onSurface,
              ),
            ),
            Text(
              secondary,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingSummaryRow(String label, bool active) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: OrganizerColors.onSurface,
          ),
        ),
        Container(
          width: 32,
          height: 18,
          decoration: BoxDecoration(
            color: active
                ? OrganizerColors.primary
                : OrganizerColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(9999),
          ),
          child: Align(
            alignment: active ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 14,
              height: 14,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
