import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Text(
                          'Delhi',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down, color: Colors.black, size: 20),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add, color: Colors.black87, size: 20),
                      label: const Text(
                        'Create',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Stories / People
            SliverToBoxAdapter(
              child: SizedBox(
                height: 96,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: const [
                    _StoryAvatar(name: 'Rohan', imageUrl: 'https://images.unsplash.com/photo-1522529599102-193c0d76b5b6?w=200&h=200&fit=crop'),
                    SizedBox(width: 16),
                    _StoryAvatar(name: 'Priya', imageUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=200&h=200&fit=crop'),
                    SizedBox(width: 16),
                    _StoryAvatar(name: 'Ananya', imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop'),
                    SizedBox(width: 16),
                    _StoryAvatar(name: 'Vikram', imageUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200&h=200&fit=crop'),
                  ],
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey.shade600, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Search people, events or vibes...',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // Filter Chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: const [
                    _FilterChip(label: 'All'),
                    SizedBox(width: 8),
                    _FilterChip(label: 'House Party'),
                    SizedBox(width: 8),
                    _FilterChip(label: 'Event'),
                    SizedBox(width: 8),
                    _FilterChip(label: 'Fitness'),
                    SizedBox(width: 8),
                    // Arrow button at end
                    _ArrowButton(),
                  ],
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Events List
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const _VerticalEventCard(
                    title: 'Rooftop Neon House Party',
                    dateStr: "12 Oct '24",
                    timeStr: '9:00 PM',
                    locationStr: 'Mission District',
                    joinedCountText: '+42',
                    statsText: '45 Joined • 15 Spots Left',
                    imageUrl: 'https://images.unsplash.com/photo-1566737236500-c8ac43014a67?auto=format&fit=crop&w=1200&q=80',
                  ),
                  const SizedBox(height: 24),
                  const _VerticalEventCard(
                    title: 'Underground Warehouse Rave',
                    dateStr: "18 Oct '24",
                    timeStr: '11:00 PM',
                    locationStr: 'SOMA',
                    joinedCountText: '+120',
                    statsText: '122 Joined • 8 Spots Left',
                    imageUrl: 'https://images.unsplash.com/photo-1540039155732-68ee23e15b51?auto=format&fit=crop&w=1200&q=80',
                  ),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryAvatar extends StatelessWidget {
  final String name;
  final String imageUrl;

  const _StoryAvatar({required this.name, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFA133FF), width: 2),
          ),
          child: CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(imageUrl),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black87,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;

  const _FilterChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade800,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Center(
        child: Icon(Icons.chevron_right, color: Colors.black54, size: 20),
      ),
    );
  }
}

class _VerticalEventCard extends StatelessWidget {
  final String title;
  final String dateStr;
  final String timeStr;
  final String locationStr;
  final String joinedCountText;
  final String statsText;
  final String imageUrl;

  const _VerticalEventCard({
    required this.title,
    required this.dateStr,
    required this.timeStr,
    required this.locationStr,
    required this.joinedCountText,
    required this.statsText,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/event/123');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image top
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Image.network(
              imageUrl,
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$dateStr • $timeStr',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '•',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black38,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.location_on_outlined, size: 14, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text(
                      locationStr,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Avatars
                    SizedBox(
                      width: 72,
                      height: 28,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 13,
                                backgroundImage: const NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&fit=crop'),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 20,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 13,
                                backgroundImage: const NetworkImage('https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&fit=crop'),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 40,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 13,
                                backgroundColor: Colors.grey.shade100,
                                child: Text(
                                  joinedCountText,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      statsText,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
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

