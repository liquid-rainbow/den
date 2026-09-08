import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EventAttendeesScreen extends StatefulWidget {
  final String eventId;

  const EventAttendeesScreen({super.key, required this.eventId});

  @override
  State<EventAttendeesScreen> createState() => _EventAttendeesScreenState();
}

class _EventAttendeesScreenState extends State<EventAttendeesScreen> {
  // Toggle this to see the list or the blurred view.
  // For now, we default to false to match the provided screenshots.
  bool _hasAccess = false;

  final List<Map<String, String>> _dummyAttendees = [
    {
      'name': 'Neon Pulse Collective',
      'image': 'https://images.unsplash.com/photo-1549490349-8643362247b5?w=100&fit=crop',
    },
    {
      'name': 'Alex Johnson',
      'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&fit=crop',
    },
    {
      'name': 'Samantha Lee',
      'image': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&fit=crop',
    },
    {
      'name': 'David Kim',
      'image': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&fit=crop',
    },
    {
      'name': 'Jessica Smith',
      'image': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&fit=crop',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFD), // Very light purple-tinted white
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Attendees',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _hasAccess ? Icons.lock_open : Icons.lock_outline,
              color: Colors.grey.shade400,
            ),
            tooltip: 'Toggle Access (Dev)',
            onPressed: () {
              setState(() {
                _hasAccess = !_hasAccess;
              });
            },
          ),
        ],
      ),
      body: _hasAccess ? _buildAttendeesList() : _buildNoAccessView(),
    );
  }

  Widget _buildNoAccessView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Blurred purple circle
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 250,
                height: 250,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFD2ABF7), // Soft purple
                ),
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Text(
            'no peeking...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              "Join the event to see other people, discover who's coming and start connecting!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF4A4A4A),
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildAttendeesList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: _dummyAttendees.length,
      itemBuilder: (context, index) {
        final attendee = _dummyAttendees[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(attendee['image']!),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  attendee['name']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
