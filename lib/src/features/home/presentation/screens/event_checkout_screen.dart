import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EventCheckoutScreen extends StatelessWidget {
  final String eventId;
  final String total;

  const EventCheckoutScreen({super.key, required this.eventId, this.total = 'Free'});

  @override
  Widget build(BuildContext context) {
    final darkBrownPurple = const Color(0xFF4A2B3D); // Matches the text/button color in the mockup

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Get your tickets',
          style: TextStyle(color: darkBrownPurple, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 12, bottom: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time, color: darkBrownPurple, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '04:35',
                    style: TextStyle(color: darkBrownPurple, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secure your place',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: darkBrownPurple,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'These details will be displayed on your invoice',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Name Field
                const Text(
                  'Name',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Text(
                  'Evelyn Vane',
                  style: TextStyle(fontSize: 20, color: darkBrownPurple, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 32),
                
                // Email Field
                const Text(
                  'Email Address',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Text(
                  'evelyn@ethereal.com',
                  style: TextStyle(fontSize: 20, color: darkBrownPurple, fontWeight: FontWeight.w500),
                ),
                
                const SizedBox(height: 40),
                Divider(color: Colors.grey.shade300, thickness: 1),
                const SizedBox(height: 24),
                
                Text(
                  "If your profile or dress code doesn't match with the vibe of the event or you are using someone else's photos or Instagram then the organizer can still cancel your entry at the venue.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TICKET PRICE',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              total,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: darkBrownPurple,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.keyboard_arrow_down, color: darkBrownPurple),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // After booking, go to the ticket screen we made earlier
                        context.go('/event/$eventId/ticket');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkBrownPurple,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Book',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
