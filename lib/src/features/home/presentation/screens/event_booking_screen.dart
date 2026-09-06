import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EventBookingScreen extends StatefulWidget {
  final String eventId;

  const EventBookingScreen({super.key, required this.eventId});

  @override
  State<EventBookingScreen> createState() => _EventBookingScreenState();
}

class _EventBookingScreenState extends State<EventBookingScreen> {
  bool _acceptedTerms = false;
  
  // Mock ticket counts
  int _singleMaleCount = 0;
  int _singleFemaleCount = 0;
  int _coupleCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Get Your tickets',
              style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Moon Light Sufi Night - Bu...',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8, bottom: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: Color(0xFFA133FF), size: 12),
                      const SizedBox(width: 4),
                      const Text(
                        '09:47',
                        style: TextStyle(color: Color(0xFFA133FF), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Reserved for you',
                  style: TextStyle(color: Color(0xFFA133FF), fontSize: 10),
                ),
              ],
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 150), // Space for bottom bar
            child: Column(
              children: [
                // Venue Layout Card
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Venue Layout',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Divider(height: 1, color: Colors.grey.shade200),
                      Container(
                        height: 250,
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                        ),
                        alignment: Alignment.center,
                        child: const Text('img', style: TextStyle(color: Colors.black54)),
                      ),
                    ],
                  ),
                ),

                // Tickets Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          "Early Bird (ends on 23 aug'26)",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Divider(height: 1, color: Colors.grey.shade200),
                      
                      // Ticket Items
                      _buildTicketItem(
                        title: 'Single-Male',
                        price: '₹222 / per person',
                        count: _singleMaleCount,
                        passesLeft: '4 passes left',
                        onAdd: () => setState(() => _singleMaleCount++),
                        onRemove: () => setState(() {
                          if (_singleMaleCount > 0) _singleMaleCount--;
                        }),
                      ),
                      Divider(height: 1, color: Colors.grey.shade200),
                      _buildTicketItem(
                        title: 'Single-Female',
                        price: '• ₹111',
                        count: _singleFemaleCount,
                        tags: ['Early Bird', 'Pass of 1', 'Available'],
                        onAdd: () => setState(() => _singleFemaleCount++),
                        onRemove: () => setState(() {
                          if (_singleFemaleCount > 0) _singleFemaleCount--;
                        }),
                      ),
                      Divider(height: 1, color: Colors.grey.shade200),
                      _buildTicketItem(
                        title: 'Couple',
                        price: '• ₹334',
                        count: _coupleCount,
                        onAdd: () => setState(() => _coupleCount++),
                        onRemove: () => setState(() {
                          if (_coupleCount > 0) _coupleCount--;
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Fixed Bottom Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _acceptedTerms,
                            activeColor: const Color(0xFFA133FF),
                            onChanged: (value) {
                              setState(() {
                                _acceptedTerms = value ?? false;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'By accepting this invite, I confirm that I am 21 or older and legally permitted to consume alcohol.',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _acceptedTerms && (_singleMaleCount > 0 || _singleFemaleCount > 0 || _coupleCount > 0)
                            ? () {
                                int calculatedTotal = (_singleMaleCount * 222) + (_singleFemaleCount * 111) + (_coupleCount * 334);
                                String totalStr = calculatedTotal > 0 ? calculatedTotal.toString() : 'Free';
                                context.push('/event/${widget.eventId}/checkout?total=$totalStr');
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA133FF),
                          disabledBackgroundColor: Colors.grey.shade300,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
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

  Widget _buildTicketItem({
    required String title,
    required String price,
    required int count,
    required VoidCallback onAdd,
    required VoidCallback onRemove,
    String? passesLeft,
    List<String>? tags,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      price,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (count == 0)
                GestureDetector(
                  onTap: onAdd,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '+ Add',
                      style: TextStyle(color: Color(0xFFA133FF), fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.remove, size: 16),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '$count',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: onAdd,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFA133FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (passesLeft != null || (tags != null && tags.isNotEmpty)) const SizedBox(height: 12),
          if (passesLeft != null)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                passesLeft,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ),
          if (tags != null && tags.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags.map((tag) {
                final isPurple = tag == 'Early Bird';
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPurple ? const Color(0xFFF3E8FF) : Colors.white,
                    border: Border.all(color: isPurple ? const Color(0xFFA133FF) : Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: isPurple ? const Color(0xFFA133FF) : Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
