import 'package:den/src/features/organizer/application/organizer_events_controller.dart';
import 'package:den/src/features/organizer/domain/models/create_event_draft.dart';
import 'package:den/src/features/organizer/domain/models/organizer_event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_provider.dart';

class CreateEventNotifier extends Notifier<CreateEventDraft> {
  @override
  CreateEventDraft build() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return CreateEventDraft(
      date: DateTime(tomorrow.year, tomorrow.month, tomorrow.day),
    );
  }

  void setCategory(EventCategory category) {
    state = state.copyWith(category: category);
  }

  void updateBasicDetails({
    String? bannerUrl,
    String? title,
    DateTime? date,
    String? startTime,
    String? endTime,
  }) {
    state = state.copyWith(
      bannerUrl: bannerUrl,
      title: title,
      date: date,
      startTime: startTime,
      endTime: endTime,
    );
  }

  void updateDescription(String description) {
    state = state.copyWith(description: description);
  }

  void updateLocation({
    String? venueName,
    String? venueAddress,
    String? googleMapsUrl,
    EventLocationMode? locationMode,
    EventVenueVisibility? venueVisibility,
  }) {
    state = state.copyWith(
      venueName: venueName,
      venueAddress: venueAddress,
      googleMapsUrl: googleMapsUrl,
      locationMode: locationMode,
      venueVisibility: venueVisibility,
    );
  }

  void updateAudienceSettings({
    EventExclusivity? exclusivity,
    int? capacity,
    bool clearCapacity = false,
    CapacityByGender? capacityByGender,
    bool clearCapacityByGender = false,
    EventGenderRequirement? genderRequirement,
    bool? requireInstagram,
    bool? requireVerification,
    bool? alcoholAvailable,
    bool? allowCancellation,
    bool? searchEngineVisible,
  }) {
    state = state.copyWith(
      exclusivity: exclusivity,
      capacity: capacity,
      clearCapacity: clearCapacity,
      capacityByGender: capacityByGender,
      clearCapacityByGender: clearCapacityByGender,
      genderRequirement: genderRequirement,
      requireInstagram: requireInstagram,
      requireVerification: requireVerification,
      alcoholAvailable: alcoholAvailable,
      allowCancellation: allowCancellation,
      searchEngineVisible: searchEngineVisible,
    );
  }

  void setPricingType(EventPricingType type) {
    state = state.copyWith(pricingType: type);
  }

  void addTicketTier(EventTicketTier tier) {
    state = state.copyWith(
      ticketTiers: [...state.ticketTiers, tier],
    );
  }

  void updateTicketTier(EventTicketTier updatedTier) {
    state = state.copyWith(
      ticketTiers: state.ticketTiers
          .map((t) => t.id == updatedTier.id ? updatedTier : t)
          .toList(),
    );
  }

  void removeTicketTier(String tierId) {
    state = state.copyWith(
      ticketTiers: state.ticketTiers.where((t) => t.id != tierId).toList(),
    );
  }

  void addCoupon(EventCoupon coupon) {
    state = state.copyWith(
      coupons: [...state.coupons, coupon],
    );
  }

  void removeCoupon(String couponId) {
    state = state.copyWith(
      coupons: state.coupons.where((c) => c.id != couponId).toList(),
    );
  }

  void updateContactInfo(String contactInfo) {
    state = state.copyWith(contactInfo: contactInfo);
  }

  void addGalleryPhoto(String photoUrl) {
    if (state.galleryUrls.length >= 4) return;
    state = state.copyWith(
      galleryUrls: [...state.galleryUrls, photoUrl],
    );
  }

  void removeGalleryPhoto(int index) {
    if (index < 0 || index >= state.galleryUrls.length) return;
    final updated = List<String>.from(state.galleryUrls)..removeAt(index);
    state = state.copyWith(galleryUrls: updated);
  }

  Future<OrganizerEvent> publishEvent() async {
    final eventDate = state.date ?? DateTime.now();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final monthShort = months[eventDate.month - 1];
    final dayNumber = eventDate.day.toString();
    final dateLabel = '$dayNumber $monthShort \\'${eventDate.year.toString().substring(2)}';
    final timeRange = state.endTime != null ? '${state.startTime} - ${state.endTime}' : state.startTime;

    // Build the payload expected by POST /api/events
    final payload = {
      'title': state.title.isNotEmpty ? state.title : '${state.category.label} Gathering',
      'category': state.category.name,
      'description': state.description,
      'bannerUrl': state.bannerUrl,
      'galleryUrls': state.galleryUrls,
      'date': state.date?.toIso8601String(),
      'startTime': state.startTime,
      'endTime': state.endTime,
      'venueName': state.venueName.isNotEmpty ? state.venueName : 'Private Venue',
      'venueAddress': state.venueAddress.isNotEmpty ? state.venueAddress : 'New Delhi, India',
      'latitude': state.location?.latitude,
      'longitude': state.location?.longitude,
      'locationMode': 'searchedAddress', // Assuming from draft or default
      'venueVisibility': state.venueVisibility == VenueVisibility.alwaysVisible ? 'alwaysVisible' : 'approvedOnly',
      'exclusivity': 'approvedOnly', // Hardcoded as per default or state
      'capacity': state.capacity,
      'capacityByGender': {
        'men': state.genderCapacity[Gender.male],
        'women': state.genderCapacity[Gender.female],
        'nonBinary': state.genderCapacity[Gender.nonBinary],
      },
      'genderRequirement': state.openTo == OpenToRequirement.everyone ? 'all' : (state.openTo == OpenToRequirement.womenOnly ? 'womenOnly' : 'couplesOnly'),
      'requireInstagram': state.requireInstagram,
      'requireFaceVerification': state.requireVerification,
      'alcoholAvailable': true,
      'allowCancellation': false,
      'searchEngineVisible': true,
      'contactInfo': state.contactInfo,
      'pricingType': state.pricingType == PricingType.paid ? 'paid' : (state.pricingType == PricingType.free ? 'free' : 'splitBill'),
      'status': 'published',
      'ticketTiers': state.ticketTiers.map((t) => {
        'name': t.name,
        'badge': 'SINGLE',
        'note': t.note,
        'price': t.price,
        'isLimited': t.isLimited,
        'quantityLimit': t.quantity,
      }).toList(),
      'coupons': state.coupons.map((c) => {
        'code': c.code,
        'type': c.discountType == DiscountType.percentage ? 'percentage' : 'fixed',
        'value': c.value,
        'usageLimit': c.usageLimit,
      }).toList(),
    };

    final dio = ref.read(dioProvider);
    try {
      final response = await dio.post('/api/events', data: payload);
      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'Failed to publish event');
      }
      
      final eventId = response.data['event']['id'] as String;

      final newEvent = OrganizerEvent(
        id: eventId,
        title: payload['title'] as String,
        dateLabel: dateLabel,
        monthShort: monthShort,
        dayNumber: dayNumber,
        timeRange: timeRange,
        venueName: payload['venueName'] as String,
        venueAddress: payload['venueAddress'] as String,
        imageUrl: payload['bannerUrl'] as String?,
        ticketsSold: 0,
        ticketsTotal: state.capacity ?? 200,
        grossRevenue: 0.0,
        netEarnings: 0.0,
        platformFeePercent: 5.0,
        femaleDemographicPercent: 50,
        maleDemographicPercent: 45,
        otherDemographicPercent: 5,
        firstTimerPercent: 100,
        returningPercent: 0,
        attendedCount: 0,
        isUpcoming: true,
      );

      ref.read(organizerEventsProvider.notifier).addEvent(newEvent);

      // Reset draft
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      state = CreateEventDraft(
        date: DateTime(tomorrow.year, tomorrow.month, tomorrow.day),
      );

      return newEvent;
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? e.message ?? 'Network error';
      throw Exception(msg);
    } catch (e) {
      throw Exception('Failed to publish event: $e');
    }
  }
}

final createEventProvider =
    NotifierProvider<CreateEventNotifier, CreateEventDraft>(
  CreateEventNotifier.new,
);
