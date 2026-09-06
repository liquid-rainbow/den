import 'package:flutter/material.dart';

class RemoveFollowerBottomSheet extends StatefulWidget {
  final String userName;

  const RemoveFollowerBottomSheet({super.key, required this.userName});

  @override
  State<RemoveFollowerBottomSheet> createState() => _RemoveFollowerBottomSheetState();
}

class _RemoveFollowerBottomSheetState extends State<RemoveFollowerBottomSheet> {
  String _selectedOption = 'Approved'; // Default selection

  @override
  Widget build(BuildContext context) {
    const Color primaryPurple = Color(0xFF6B18D1);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            const Text(
              'Remove from',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            
            // Options
            _buildRadioOption('Approved', 'Approved'),
            _buildRadioOption('Followers', 'Followers'),
            _buildRadioOption('Both Approved and Followers', 'Both Approved and Followers'),
            
            const SizedBox(height: 24),
            
            // Cancel Button
            Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: primaryPurple,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption(String title, String value) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedOption = value;
        });
        // In a real implementation, you would trigger the removal action here or pass it back.
        // For now, we simulate the action and pop.
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            Navigator.of(context).pop(value);
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _selectedOption == value ? const Color(0xFF6B18D1) : Colors.grey.shade500,
                  width: 2,
                ),
              ),
              padding: const EdgeInsets.all(4),
              child: _selectedOption == value
                  ? Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF6B18D1),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// Helper to show the bottom sheet
Future<String?> showRemoveFollowerBottomSheet(BuildContext context, String userName) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => RemoveFollowerBottomSheet(userName: userName),
  );
}
