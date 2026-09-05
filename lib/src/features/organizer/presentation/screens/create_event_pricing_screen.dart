import 'package:den/src/features/organizer/application/create_event_controller.dart';
import 'package:den/src/features/organizer/domain/models/create_event_draft.dart';
import 'package:den/src/features/organizer/presentation/theme/organizer_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CreateEventPricingScreen extends ConsumerStatefulWidget {
  const CreateEventPricingScreen({super.key});

  @override
  ConsumerState<CreateEventPricingScreen> createState() =>
      _CreateEventPricingScreenState();
}

class _CreateEventPricingScreenState
    extends ConsumerState<CreateEventPricingScreen> {
  late EventPricingType _pricingType;

  @override
  void initState() {
    super.initState();
    _pricingType = ref.read(createEventProvider).pricingType;
  }

  void _onContinue() {
    ref.read(createEventProvider.notifier).setPricingType(_pricingType);
    context.push('/organizer/events/create/contact');
  }

  void _addNewTier() {
    final count = ref.read(createEventProvider).ticketTiers.length + 1;
    final newTier = EventTicketTier(
      id: 'tier_$count',
      name: 'Tier $count Ticket',
      badge: 'SINGLE',
      price: 400.0,
      isLimited: true,
      quantityLimit: 100,
    );
    ref.read(createEventProvider.notifier).addTicketTier(newTier);
  }

  void _showEditPriceDialog(EventTicketTier tier) {
    final controller =
        TextEditingController(text: tier.price.toStringAsFixed(0));
    final nameController = TextEditingController(text: tier.name);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Edit Ticket Tier',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: OrganizerColors.onSurface,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tier Name',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: OrganizerColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: nameController,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1C1B1B),
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: OrganizerColors.surfaceContainerLow,
                hintText: 'Ticket Name',
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Base Price (₹)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: OrganizerColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1C1B1B),
              ),
              decoration: InputDecoration(
                prefixText: '₹ ',
                prefixStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1C1B1B),
                ),
                filled: true,
                fillColor: OrganizerColors.surfaceContainerLow,
                hintText: '400',
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newPrice =
                  double.tryParse(controller.text.trim()) ?? tier.price;
              final newName = nameController.text.trim().isNotEmpty
                  ? nameController.text.trim()
                  : tier.name;
              ref.read(createEventProvider.notifier).updateTicketTier(
                    tier.copyWith(price: newPrice, name: newName),
                  );
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: OrganizerColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _roundOffTier(EventTicketTier tier, double roundTarget) {
    ref.read(createEventProvider.notifier).updateTicketTier(
          tier.copyWith(price: roundTarget),
        );
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(createEventProvider);
    final primaryTier = draft.ticketTiers.isNotEmpty
        ? draft.ticketTiers.first
        : const EventTicketTier(
            id: 'default',
            name: 'Single-General',
            badge: 'SINGLE',
            price: 400.0,
          );

    final basePrice = primaryTier.price;
    final platformFee = basePrice * 0.05;
    final gstFee = platformFee * 0.18;
    final guestPays = basePrice + platformFee + gstFee;
    final hostGets = basePrice - platformFee;

    return Scaffold(
      backgroundColor: OrganizerColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: OrganizerColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Ticket Price',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: OrganizerColors.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text(
                'How would you like to sell your tickets?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: OrganizerColors.onSurface,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 24),

              // Pricing Options: Free vs Add Tickets
              _buildPricingOptionCard(
                type: EventPricingType.free,
                title: 'Free to join',
                subtitle: "Build a community you'd like to party with",
                icon: Icons.volunteer_activism_outlined,
              ),
              const SizedBox(height: 12),
              _buildPricingOptionCard(
                type: EventPricingType.paid,
                title: 'Add tickets',
                subtitle: 'Add types and phases with their respective price',
                icon: Icons.confirmation_number_outlined,
              ),
              const SizedBox(height: 28),

              if (_pricingType == EventPricingType.paid) ...[
                // Ticket Tiers Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Configured Tickets',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: OrganizerColors.onSurface,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () =>
                          context.push('/organizer/events/create/coupons'),
                      icon: const Icon(Icons.sell_outlined,
                          size: 16, color: OrganizerColors.primary),
                      label: Text(
                        'Coupons (${draft.coupons.length})',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: OrganizerColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // List of Ticket Tiers
                ...draft.ticketTiers.map((tier) => _buildTicketTierCard(tier)),

                const SizedBox(height: 12),

                // Add another ticket button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _addNewTier,
                    icon: const Icon(Icons.add,
                        size: 20, color: OrganizerColors.primary),
                    label: const Text(
                      'Add another ticket type',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: OrganizerColors.primary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: OrganizerColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Complete Pricing & Fee Breakdown Card on the SAME screen
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: OrganizerColors.primary.withValues(alpha: 0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.analytics_outlined,
                              size: 20, color: OrganizerColors.primary),
                          SizedBox(width: 8),
                          Text(
                            'Pricing Breakdown',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: OrganizerColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Side-by-side Guest Pays vs You Get Pills
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: OrganizerColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Guest pays',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹${guestPays.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: OrganizerColors.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: OrganizerColors.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: OrganizerColors.primary.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'You get',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: OrganizerColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹${hostGets.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: OrganizerColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Fee row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Host Platform fee',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: OrganizerColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '5%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: OrganizerColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Round-off options
                      const SizedBox(height: 16),
                      const Divider(height: 1, color: Color(0xFFE5E7EB)),
                      const SizedBox(height: 12),
                      const Text(
                        'Quick Round-Off',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildRoundOffChip(primaryTier, 300),
                          _buildRoundOffChip(primaryTier, 400),
                          _buildRoundOffChip(primaryTier, 500),
                          _buildRoundOffChip(primaryTier, 1000),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 36),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _onContinue,
                  icon: const SizedBox.shrink(),
                  label: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OrganizerColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 3,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoundOffChip(EventTicketTier tier, double amount) {
    final isCurrent = (tier.price - amount).abs() < 0.1;
    return ActionChip(
      label: Text('₹${amount.toInt()}'),
      backgroundColor: isCurrent
          ? OrganizerColors.primary
          : OrganizerColors.surfaceContainerLow,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: isCurrent ? Colors.white : OrganizerColors.onSurface,
      ),
      onPressed: () => _roundOffTier(tier, amount),
    );
  }

  Widget _buildPricingOptionCard({
    required EventPricingType type,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _pricingType == type;
    return GestureDetector(
      onTap: () => setState(() => _pricingType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? OrganizerColors.primaryContainer
              : OrganizerColors.surfaceContainer,
          borderRadius: BorderRadius.circular(9999),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? OrganizerColors.primary.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : OrganizerColors.surfaceContainerHigh,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : OrganizerColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : OrganizerColors.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white70
                          : OrganizerColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check,
                    size: 16, color: OrganizerColors.primary),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketTierCard(EventTicketTier tier) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: OrganizerColors.surfaceContainerHigh),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => _showEditPriceDialog(tier),
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: OrganizerColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      tier.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: OrganizerColors.onSurface,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.edit, size: 14, color: OrganizerColors.primary),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: OrganizerColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tier.badge,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: OrganizerColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 20, color: Color(0xFFEF4444)),
                    onPressed: () {
                      ref
                          .read(createEventProvider.notifier)
                          .removeTicketTier(tier.id);
                    },
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => _showEditPriceDialog(tier),
                child: Text(
                  '₹${tier.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: OrganizerColors.primary,
                  ),
                ),
              ),
              Row(
                children: [
                  const Text(
                    'Sell limited tickets',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: OrganizerColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: tier.isLimited,
                    onChanged: (val) {
                      ref.read(createEventProvider.notifier).updateTicketTier(
                            tier.copyWith(isLimited: val),
                          );
                    },
                    activeThumbColor: OrganizerColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
