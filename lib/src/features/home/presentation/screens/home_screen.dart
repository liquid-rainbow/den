import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/den_colors.dart';
import '../../../../core/widgets/den_logo.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with DEN Branding
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const DenLogo(
                    size: 32,
                    showBrandName: true,
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.search, color: Colors.black87),
                        onPressed: () {},
                        tooltip: 'Search Events',
                      ),
                      IconButton(
                        icon: const Icon(Icons.tune_rounded, color: Colors.black87),
                        onPressed: () => context.push('/home/filters'),
                        tooltip: 'Filter Events',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Event Feed Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                children: [
                  // Event Category Pills
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: const [
                        _EventCategoryChip(label: '🎉 All Events', isSelected: true),
                        SizedBox(width: 8),
                        _EventCategoryChip(label: '☕ Coffee Dates'),
                        SizedBox(width: 8),
                        _EventCategoryChip(label: '🧗 Outdoor & Active'),
                        SizedBox(width: 8),
                        _EventCategoryChip(label: '🎨 Art & Music'),
                        SizedBox(width: 8),
                        _EventCategoryChip(label: '🍕 Food & Drink'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Featured Event Hero
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFEFEBF5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                          child: Stack(
                            children: [
                              Image.network(
                                'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?auto=format&fit=crop&w=900&q=80',
                                height: 170,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    '🔥 POPULAR THIS WEEKEND',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text(
                                    'Rooftop Acoustic Jam & Coffee',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: const [
                                  Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF6D6D6D)),
                                  SizedBox(width: 4),
                                  Text(
                                    'Saturday, 5:00 PM • Skylight Lounge',
                                    style: TextStyle(fontSize: 12, color: Color(0xFF6D6D6D), fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    '14 verified members attending',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: DenColors.primary,
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('RSVP confirmed for Rooftop Acoustic Jam!')),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: DenColors.primary,
                                      foregroundColor: Colors.white,
                                      shape: const StadiumBorder(),
                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    child: const Text('RSVP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Upcoming Events Section
                  const Text(
                    'Upcoming Community Events',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 12),

                  const _EventCard(
                    title: 'Weekend Sunset Bowling & Bites',
                    location: 'Downtown Arena • 3.2 km away',
                    time: 'Friday, 7:00 PM',
                    attendees: '8 attending',
                    imageUrl:
                        'https://images.unsplash.com/photo-1517457373958-b7bdd4587205?auto=format&fit=crop&w=800&q=80',
                  ),
                  const SizedBox(height: 14),

                  const _EventCard(
                    title: 'Morning Pine Ridge Trail Hike',
                    location: 'Pine Ridge Trailhead • 6.4 km away',
                    time: 'Sunday, 7:30 AM',
                    attendees: '12 attending',
                    imageUrl:
                        'https://images.unsplash.com/photo-1452626038306-9aae5e071dd3?auto=format&fit=crop&w=800&q=80',
                  ),
                  const SizedBox(height: 14),

                  const _EventCard(
                    title: 'Pottery Workshop & Tea Session',
                    location: 'Studio Clay • 1.8 km away',
                    time: 'Next Tuesday, 6:00 PM',
                    attendees: '6 attending',
                    imageUrl:
                        'https://images.unsplash.com/photo-1565193566173-7a0ee3dbe261?auto=format&fit=crop&w=800&q=80',
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventCategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _EventCategoryChip({required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? DenColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? DenColors.primary : const Color(0xFFE5E2EC),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final String title;
  final String location;
  final String time;
  final String attendees;
  final String imageUrl;

  const _EventCard({
    required this.title,
    required this.location,
    required this.time,
    required this.attendees,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEFEBF5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Center(child: Icon(Icons.event, color: Colors.black26, size: 36)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: const TextStyle(fontSize: 12, color: DenColors.primary, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF6D6D6D)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    attendees,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF1F7A4A)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
