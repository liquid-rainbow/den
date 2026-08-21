import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AllNotificationsScreen extends StatefulWidget {
  final String? initialTab;

  const AllNotificationsScreen({super.key, this.initialTab});

  @override
  State<AllNotificationsScreen> createState() => _AllNotificationsScreenState();
}

class _AllNotificationsScreenState extends State<AllNotificationsScreen> {
  late String _selectedFilter;

  @override
  void initState() {
    super.initState();
    if (widget.initialTab == 'invites') {
      _selectedFilter = 'Invites';
    } else if (widget.initialTab == 'verified') {
      _selectedFilter = 'Verified';
    } else {
      _selectedFilter = 'All';
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgSurface = Color(0xFFFAF8FF);
    const onSurface = Color(0xFF131B2E);

    return Scaffold(
      backgroundColor: bgSurface,
      appBar: AppBar(
        backgroundColor: bgSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: onSurface),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/notifications');
            }
          },
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: onSurface,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Pills
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  _PillFilter(
                    label: 'All',
                    isSelected: _selectedFilter == 'All',
                    onTap: () => setState(() => _selectedFilter = 'All'),
                  ),
                  const SizedBox(width: 10),
                  _PillFilter(
                    label: 'Verified',
                    isSelected: _selectedFilter == 'Verified',
                    onTap: () => setState(() => _selectedFilter = 'Verified'),
                  ),
                  const SizedBox(width: 10),
                  _PillFilter(
                    label: 'Invites',
                    isSelected: _selectedFilter == 'Invites',
                    onTap: () => setState(() => _selectedFilter = 'Invites'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Card Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                childAspectRatio: 0.70,
                children: [
                  if (_selectedFilter == 'All' || _selectedFilter == 'Invites') ...[
                    const _CardWithActions(
                      name: 'Riya',
                      message: 'Do you want to go bowling',
                      imageUrl:
                          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=400&q=80',
                      isPrimaryBubble: true,
                    ),
                    const _CardWithActions(
                      name: 'Alex',
                      message: 'says hey',
                      imageUrl:
                          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80',
                      isPrimaryBubble: false,
                    ),
                    const _CardWithActions(
                      name: 'Maya',
                      message: 'Coffee at Skylight?',
                      imageUrl:
                          'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=400&q=80',
                      isPrimaryBubble: true,
                    ),
                    const _CardWithActions(
                      name: 'David',
                      message: 'Hiking meetup this Sat?',
                      imageUrl:
                          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=400&q=80',
                      isPrimaryBubble: false,
                    ),
                  ] else ...[
                    const _CardWithActions(
                      name: 'Riya',
                      message: 'Verified Member',
                      imageUrl:
                          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=400&q=80',
                      isPrimaryBubble: true,
                    ),
                    const _CardWithActions(
                      name: 'Alex',
                      message: 'Verified Member',
                      imageUrl:
                          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80',
                      isPrimaryBubble: false,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PillFilter extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PillFilter({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF004AC6);
    const surfaceContainer = Color(0xFFEAEDFF);
    const onSurfaceVariant = Color(0xFF434655);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : surfaceContainer,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? Colors.white : onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _CardWithActions extends StatefulWidget {
  final String name;
  final String message;
  final String imageUrl;
  final bool isPrimaryBubble;

  const _CardWithActions({
    required this.name,
    required this.message,
    required this.imageUrl,
    required this.isPrimaryBubble,
  });

  @override
  State<_CardWithActions> createState() => _CardWithActionsState();
}

class _CardWithActionsState extends State<_CardWithActions> {
  bool? isAccepted;

  @override
  Widget build(BuildContext context) {
    const onSurface = Color(0xFF131B2E);
    const primaryColor = Color(0xFF004AC6);
    const primaryContainer = Color(0xFF2563EB);
    const surfaceContainer = Color(0xFFEAEDFF);
    const onSurfaceVariant = Color(0xFF434655);
    const surfaceVariant = Color(0xFFDAE2FD);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: surfaceVariant),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name
          Text(
            widget.name,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 8),

          // Message bubble
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: widget.isPrimaryBubble ? primaryContainer : surfaceVariant,
              borderRadius: widget.isPrimaryBubble
                  ? const BorderRadius.only(
                      topRight: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                      bottomRight: Radius.circular(14),
                    )
                  : const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                      bottomRight: Radius.circular(14),
                    ),
            ),
            child: Text(
              widget.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: widget.isPrimaryBubble ? Colors.white : onSurface,
              ),
            ),
          ),

          // Centered Avatar
          Expanded(
            child: Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 6,
                    ),
                  ],
                  image: DecorationImage(
                    image: NetworkImage(widget.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          // Actions
          if (isAccepted == null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => setState(() => isAccepted = false),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: surfaceContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 20, color: onSurfaceVariant),
                  ),
                ),
                InkWell(
                  onTap: () => setState(() => isAccepted = true),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, size: 20, color: Colors.white),
                  ),
                ),
              ],
            )
          else
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isAccepted!
                      ? const Color(0xFF1F7A4A).withValues(alpha: 0.15)
                      : Colors.black.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isAccepted! ? 'Accepted' : 'Declined',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isAccepted! ? const Color(0xFF1F7A4A) : Colors.black54,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
