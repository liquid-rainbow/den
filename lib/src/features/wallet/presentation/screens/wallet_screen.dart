import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/den_colors.dart';
import '../../../../core/widgets/den_qr_code.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tickets = [
      {
        'id': 'TKT-DEN-94821',
        'eventTitle': 'Rooftop Acoustic Jam & Coffee',
        'date': 'Saturday, Aug 22',
        'time': '5:00 PM',
        'venue': 'Skylight Lounge, South Delhi',
        'ticketType': 'VIP Access Pass',
        'status': 'Confirmed',
      },
      {
        'id': 'TKT-DEN-73194',
        'eventTitle': 'Weekend Sunset Bowling & Bites',
        'date': 'Friday, Aug 28',
        'time': '7:00 PM',
        'venue': 'Downtown Arena, Gurugram',
        'ticketType': 'General Mixer Ticket',
        'status': 'Confirmed',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
            }
          },
        ),
        title: const Text(
          'Wallet & Bookings',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.black,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // Balance Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF382326), // Dark wine tone
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'DEN WALLET BALANCE',
                        style: TextStyle(
                          color: Color(0xFFD5C4C7),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Icon(Icons.account_balance_wallet_outlined, color: Colors.white70, size: 20),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '₹0.00',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Payment gateway top-up coming soon!')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text('Add Funds', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white38),
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          visualDensity: VisualDensity.compact,
                        ),
                        child: const Text('History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Booked Event Passes Section
            const Text(
              'My Event Passes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.black,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 12),

            ...tickets.map((tkt) => _buildTicketCard(context, tkt)),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketCard(BuildContext context, Map<String, dynamic> tkt) {
    final ticketId = tkt['id'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEFEBF5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        tkt['status'] as String,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1F7A4A),
                        ),
                      ),
                    ),
                    Text(
                      ticketId,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  tkt['eventTitle'] as String,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 14, color: DenColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      '${tkt['date']} • ${tkt['time']}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: DenColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF757575)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        tkt['venue'] as String,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF757575)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Dashed Divider
          const Divider(height: 1, color: Color(0xFFEFEBF5), thickness: 1),

          // QR Code Scanner Area with centered 'den' logo
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E2EC)),
                  ),
                  child: DenQrCode(
                    data: 'https://den.app/pass/$ticketId',
                    size: 90,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Entry Pass QR Code',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Show this at the event entrance for quick check-in.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6D6D6D),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tkt['ticketType'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF382326),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
