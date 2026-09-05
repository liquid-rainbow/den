class OrganizerEvent {
  final String id;
  final String title;
  final String dateLabel; // e.g. "24 Aug '25" or "Oct 24"
  final String monthShort; // e.g. "Oct"
  final String dayNumber; // e.g. "24"
  final String timeRange; // e.g. "10 PM - 2 AM"
  final String venueName; // e.g. "Cyber Pier 9" or "The Glass House"
  final String venueAddress; // e.g. "Brooklyn, NY"
  final String imageUrl;
  final int ticketsSold;
  final int ticketsTotal;
  final double grossRevenue; // e.g. 204500
  final double netEarnings; // e.g. 182400
  final double platformFeePercent; // e.g. 10.0
  final int femaleDemographicPercent; // e.g. 60
  final int maleDemographicPercent; // e.g. 35
  final int otherDemographicPercent; // e.g. 5
  final int firstTimerPercent; // e.g. 58
  final int returningPercent; // e.g. 42
  final int attendedCount; // e.g. 382
  final bool isUpcoming;

  const OrganizerEvent({
    required this.id,
    required this.title,
    required this.dateLabel,
    required this.monthShort,
    required this.dayNumber,
    required this.timeRange,
    required this.venueName,
    required this.venueAddress,
    required this.imageUrl,
    required this.ticketsSold,
    required this.ticketsTotal,
    required this.grossRevenue,
    required this.netEarnings,
    this.platformFeePercent = 10.0,
    this.femaleDemographicPercent = 60,
    this.maleDemographicPercent = 35,
    this.otherDemographicPercent = 5,
    this.firstTimerPercent = 58,
    this.returningPercent = 42,
    this.attendedCount = 382,
    this.isUpcoming = true,
  });

  double get capacityPercent =>
      ticketsTotal > 0 ? (ticketsSold / ticketsTotal).clamp(0.0, 1.0) : 0.0;

  int get remainingTickets => (ticketsTotal - ticketsSold).clamp(0, ticketsTotal);
}
