import 'package:den/src/features/organizer/application/create_event_controller.dart';
import 'package:den/src/features/organizer/domain/models/create_event_draft.dart';
import 'package:den/src/features/organizer/presentation/theme/organizer_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CreateEventCouponsScreen extends ConsumerStatefulWidget {
  const CreateEventCouponsScreen({super.key});

  @override
  ConsumerState<CreateEventCouponsScreen> createState() =>
      _CreateEventCouponsScreenState();
}

class _CreateEventCouponsScreenState
    extends ConsumerState<CreateEventCouponsScreen> {
  final _codeController = TextEditingController();
  final _pctController = TextEditingController();
  final _amtController = TextEditingController();
  final _usageLimitController = TextEditingController();
  DiscountType _selectedType = DiscountType.percentage;

  @override
  void dispose() {
    _codeController.dispose();
    _pctController.dispose();
    _amtController.dispose();
    _usageLimitController.dispose();
    super.dispose();
  }

  void _createCoupon() {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a coupon code')),
      );
      return;
    }

    double value = 0;
    if (_selectedType == DiscountType.percentage) {
      value = double.tryParse(_pctController.text.trim()) ?? 10.0;
    } else {
      value = double.tryParse(_amtController.text.trim()) ?? 100.0;
    }

    final usage = int.tryParse(_usageLimitController.text.trim());

    final coupon = EventCoupon(
      id: 'cpn_${DateTime.now().millisecondsSinceEpoch}',
      code: code,
      type: _selectedType,
      value: value,
      usageLimit: usage,
    );

    ref.read(createEventProvider.notifier).addCoupon(coupon);

    _codeController.clear();
    _pctController.clear();
    _amtController.clear();
    _usageLimitController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Coupon "$code" created!'),
        backgroundColor: OrganizerColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(createEventProvider);

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
          'Coupons',
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
              // Helper info box
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: OrganizerColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 20, color: OrganizerColors.primary),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Create a discount code for your upcoming event. Fill out percentage or fixed amount.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: OrganizerColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Coupon Form Container
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: OrganizerColors.surfaceContainerHigh),
                  boxShadow: [
                    BoxShadow(
                      color: OrganizerColors.primary.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Coupon Code',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: OrganizerColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: OrganizerColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: _codeController,
                        textCapitalization: TextCapitalization.characters,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: OrganizerColors.onSurface,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          icon: Icon(Icons.local_activity_outlined,
                              size: 20, color: OrganizerColors.outline),
                          hintText: 'e.g. SUMMER24',
                          hintStyle: TextStyle(
                            fontSize: 13,
                            letterSpacing: 0.5,
                            color: OrganizerColors.outlineVariant,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Type Selector
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() =>
                                _selectedType = DiscountType.percentage),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _selectedType == DiscountType.percentage
                                    ? OrganizerColors.primary.withValues(alpha: 0.1)
                                    : OrganizerColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _selectedType == DiscountType.percentage
                                      ? OrganizerColors.primary
                                      : Colors.transparent,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Percentage (%)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _selectedType == DiscountType.percentage
                                        ? OrganizerColors.primary
                                        : OrganizerColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() =>
                                _selectedType = DiscountType.fixedAmount),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _selectedType == DiscountType.fixedAmount
                                    ? OrganizerColors.primary.withValues(alpha: 0.1)
                                    : OrganizerColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _selectedType == DiscountType.fixedAmount
                                      ? OrganizerColors.primary
                                      : Colors.transparent,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Amount (₹)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _selectedType == DiscountType.fixedAmount
                                        ? OrganizerColors.primary
                                        : OrganizerColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Discount value input
                    if (_selectedType == DiscountType.percentage)
                      Container(
                        decoration: BoxDecoration(
                          color: OrganizerColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: TextField(
                          controller: _pctController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: OrganizerColors.onSurface,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(Icons.percent,
                                size: 18, color: OrganizerColors.outline),
                            hintText: 'e.g. 20 (for 20% off)',
                            hintStyle: TextStyle(
                                fontSize: 13,
                                color: OrganizerColors.outlineVariant),
                          ),
                        ),
                      )
                    else
                      Container(
                        decoration: BoxDecoration(
                          color: OrganizerColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: TextField(
                          controller: _amtController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: OrganizerColors.onSurface,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(Icons.currency_rupee,
                                size: 18, color: OrganizerColors.outline),
                            hintText: 'e.g. 100 (for ₹100 flat discount)',
                            hintStyle: TextStyle(
                                fontSize: 13,
                                color: OrganizerColors.outlineVariant),
                          ),
                        ),
                      ),
                    const SizedBox(height: 14),

                    // Usage limit input
                    const Text(
                      'Usage Limit (Optional)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: OrganizerColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: OrganizerColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: TextField(
                        controller: _usageLimitController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: OrganizerColors.onSurface,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          icon: Icon(Icons.group_outlined,
                              size: 18, color: OrganizerColors.outline),
                          hintText: 'e.g. 100',
                          hintStyle: TextStyle(
                              fontSize: 13,
                              color: OrganizerColors.outlineVariant),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Create Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _createCoupon,
                        icon: const Icon(Icons.add_circle_outline, size: 18),
                        label: const Text(
                          'Create Coupon',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: OrganizerColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Active Coupons List
              const Text(
                'Active Codes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: OrganizerColors.onSurface,
                ),
              ),
              const SizedBox(height: 12),

              if (draft.coupons.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  decoration: BoxDecoration(
                    color: OrganizerColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.sell_outlined,
                            size: 24, color: OrganizerColors.outline),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'No active coupons',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: OrganizerColors.onSurface,
                        ),
                      ),
                      const Text(
                        'Create one above to boost your ticket sales.',
                        style: TextStyle(
                          fontSize: 12,
                          color: OrganizerColors.outline,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...draft.coupons.map((c) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: OrganizerColors.primaryLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.local_activity,
                                size: 18, color: OrganizerColors.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.code,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                    color: OrganizerColors.primary,
                                  ),
                                ),
                                Text(
                                  c.displayDiscount,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: OrganizerColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                size: 20, color: Color(0xFFEF4444)),
                            onPressed: () {
                              ref
                                  .read(createEventProvider.notifier)
                                  .removeCoupon(c.id);
                            },
                          ),
                        ],
                      ),
                    )),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
