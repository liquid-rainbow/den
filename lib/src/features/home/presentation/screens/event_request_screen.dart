import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../notifications/application/notification_controller.dart';
import '../../../profile/application/profile_controller.dart';

class EventRequestScreen extends ConsumerWidget {
  final String eventId;

  const EventRequestScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryPurple = const Color(0xFF6B18D1);
    
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Request to Join',
          style: TextStyle(color: Colors.black87, fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Illustration Stack
            SizedBox(
              height: 260,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Main Illustration Box
                  Container(
                    width: 280,
                    height: 160,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F4EB), // Soft beige/cream
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE8D4FB).withValues(alpha: 0.5),
                          blurRadius: 60,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.mark_email_read_outlined, size: 80, color: Color(0xFFBEA6EC)), // Placeholder for envelope
                  ),
                  
                  // Exclusive Badge (Rotated)
                  Positioned(
                    top: 20,
                    right: 10,
                    child: Transform.rotate(
                      angle: 0.2, // slight rotation
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE4CC), // Peach color
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Exclusive',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5A3E26)),
                        ),
                      ),
                    ),
                  ),
                  
                  // Invite Only Badge
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA5F4D1), // Mint green
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock, size: 14, color: Colors.black87),
                          SizedBox(width: 6),
                          Text(
                            'Invite Only',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            const Text(
              "This is an exclusive den. We'll notify you when the organizer accepts your invite. Keep an eye on your notifications tab.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF4A4A52),
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Form Section
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Who is coming along?',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Enter the den username of the person who's coming with you.",
                    style: TextStyle(fontSize: 15, color: Color(0xFF4A4A52)),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person_outline, color: Colors.black54),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: '@username',
                            hintStyle: TextStyle(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.w500),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 48),
            
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final requesterName = ref.read(profileStateProvider).fullName;
                    ref.read(notificationProvider.notifier).addRequestNotification(
                          eventId,
                          'Silent Dinner Series', // hardcoded for UI purposes
                          requesterName,
                        );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Request sent successfully!')),
                    );
                    // Return to home as requested
                    context.go('/');
                  },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPurple,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Drop a request',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
