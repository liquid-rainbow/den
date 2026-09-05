import 'package:flutter/foundation.dart';

enum EventCategory {
  party('Party', 'home', 'music_note', [0xFFC059FF, 0xFFF47CFF]),
  event('Event', 'theater_comedy', 'celebration', [0xFFFF5D8F, 0xFFFF8CAE]),
  fitness('Fitness', 'fitness_center', 'bolt', [0xFFD97C36, 0xFFF4A261]),
  comedyClub('Comedy Club', 'sentiment_very_satisfied', 'theater_comedy', [0xFFF03A47, 0xFFF48C06]),
  travel('Travel', 'flight', 'public', [0xFF0077B6, 0xFF00B4D8]);

  final String label;
  final String icon;
  final String watermarkIcon;
  final List<int> gradientColors;

  const EventCategory(this.label, this.icon, this.watermarkIcon, this.gradientColors);
}

enum EventExclusivity {
  approvedOnly('Approved guest only', 'Host verifies join requests manually'),
  openToAll('Open to everyone', 'Anyone can book/join directly');

  final String label;
  final String description;

  const EventExclusivity(this.label, this.description);
}

enum EventGenderRequirement {
  all('All genders'),
  men('Men only'),
  women('Women only'),
  nonBinary('Non-binary');

  final String label;

  const EventGenderRequirement(this.label);
}

enum EventPricingType {
  free('Free to join', 'Build a community you\'d like to party with'),
  paid('Add tickets', 'Add types and phases with their respective price');

  final String label;
  final String description;

  const EventPricingType(this.label, this.description);
}

enum DiscountType {
  percentage,
  fixedAmount,
}

@immutable
class EventTicketTier {
  final String id;
  final String name;
  final String badge; // 'SINGLE', 'COUPLE', 'VIP'
  final String? note;
  final double price;
  final bool isLimited;
  final int? quantityLimit;

  const EventTicketTier({
    required this.id,
    required this.name,
    this.badge = 'SINGLE',
    this.note,
    this.price = 0.0,
    this.isLimited = false,
    this.quantityLimit,
  });

  EventTicketTier copyWith({
    String? id,
    String? name,
    String? badge,
    String? note,
    double? price,
    bool? isLimited,
    int? quantityLimit,
  }) {
    return EventTicketTier(
      id: id ?? this.id,
      name: name ?? this.name,
      badge: badge ?? this.badge,
      note: note ?? this.note,
      price: price ?? this.price,
      isLimited: isLimited ?? this.isLimited,
      quantityLimit: quantityLimit ?? this.quantityLimit,
    );
  }
}

@immutable
class EventCoupon {
  final String id;
  final String code;
  final DiscountType type;
  final double value; // percentage (e.g. 20) or flat amount (e.g. 100)
  final int? usageLimit;
  final int usedCount;

  const EventCoupon({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    this.usageLimit,
    this.usedCount = 0,
  });

  String get displayDiscount => type == DiscountType.percentage ? '${value.toInt()}% Off' : '₹${value.toStringAsFixed(0)} Off';
}

@immutable
class CreateEventDraft {
  final EventCategory category;
  final String bannerUrl;
  final List<String> galleryUrls;
  final String title;
  final DateTime? date;
  final String startTime;
  final String? endTime;
  final String description;
  final String venueName;
  final String venueAddress;
  final String? googleMapsUrl;
  final EventExclusivity exclusivity;
  final int? capacity; // null = no limit
  final EventGenderRequirement genderRequirement;
  final bool requireInstagram;
  final bool requireVerification;
  final bool alcoholAvailable;
  final bool allowCancellation;
  final bool searchEngineVisible;
  final EventPricingType pricingType;
  final List<EventTicketTier> ticketTiers;
  final List<EventCoupon> coupons;
  final String contactInfo;

  const CreateEventDraft({
    this.category = EventCategory.party,
    this.bannerUrl = 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&q=80&w=1000',
    this.galleryUrls = const [],
    this.title = '',
    this.date,
    this.startTime = '20:00',
    this.endTime = '23:00',
    this.description = '',
    this.venueName = 'Vijay Nagar',
    this.venueAddress = 'Vijay Nagar, Delhi, 110009, India',
    this.googleMapsUrl,
    this.exclusivity = EventExclusivity.approvedOnly,
    this.capacity = 270,
    this.genderRequirement = EventGenderRequirement.all,
    this.requireInstagram = false,
    this.requireVerification = false,
    this.alcoholAvailable = true,
    this.allowCancellation = false,
    this.searchEngineVisible = true,
    this.pricingType = EventPricingType.paid,
    this.ticketTiers = const [
      EventTicketTier(
        id: 'tier_1',
        name: 'Single-General',
        badge: 'SINGLE',
        price: 400.0,
        isLimited: true,
        quantityLimit: 200,
      ),
    ],
    this.coupons = const [],
    this.contactInfo = '',
  });

  double get minTicketPrice {
    if (pricingType == EventPricingType.free || ticketTiers.isEmpty) return 0.0;
    return ticketTiers.map((t) => t.price).reduce((a, b) => a < b ? a : b);
  }

  double get maxTicketPrice {
    if (pricingType == EventPricingType.free || ticketTiers.isEmpty) return 0.0;
    return ticketTiers.map((t) => t.price).reduce((a, b) => a > b ? a : b);
  }

  // 5% Platform fee calculation
  double get guestEstimatedPrice => minTicketPrice > 0 ? (minTicketPrice * 1.059) : 0.0;
  double get hostEstimatedEarnings => minTicketPrice > 0 ? (minTicketPrice * 0.941) : 0.0;

  CreateEventDraft copyWith({
    EventCategory? category,
    String? bannerUrl,
    List<String>? galleryUrls,
    String? title,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? description,
    String? venueName,
    String? venueAddress,
    String? googleMapsUrl,
    EventExclusivity? exclusivity,
    int? capacity,
    bool clearCapacity = false,
    EventGenderRequirement? genderRequirement,
    bool? requireInstagram,
    bool? requireVerification,
    bool? alcoholAvailable,
    bool? allowCancellation,
    bool? searchEngineVisible,
    EventPricingType? pricingType,
    List<EventTicketTier>? ticketTiers,
    List<EventCoupon>? coupons,
    String? contactInfo,
  }) {
    return CreateEventDraft(
      category: category ?? this.category,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      galleryUrls: galleryUrls ?? this.galleryUrls,
      title: title ?? this.title,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      description: description ?? this.description,
      venueName: venueName ?? this.venueName,
      venueAddress: venueAddress ?? this.venueAddress,
      googleMapsUrl: googleMapsUrl ?? this.googleMapsUrl,
      exclusivity: exclusivity ?? this.exclusivity,
      capacity: clearCapacity ? null : (capacity ?? this.capacity),
      genderRequirement: genderRequirement ?? this.genderRequirement,
      requireInstagram: requireInstagram ?? this.requireInstagram,
      requireVerification: requireVerification ?? this.requireVerification,
      alcoholAvailable: alcoholAvailable ?? this.alcoholAvailable,
      allowCancellation: allowCancellation ?? this.allowCancellation,
      searchEngineVisible: searchEngineVisible ?? this.searchEngineVisible,
      pricingType: pricingType ?? this.pricingType,
      ticketTiers: ticketTiers ?? this.ticketTiers,
      coupons: coupons ?? this.coupons,
      contactInfo: contactInfo ?? this.contactInfo,
    );
  }
}
