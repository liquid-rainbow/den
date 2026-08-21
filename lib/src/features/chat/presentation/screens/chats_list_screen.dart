import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatsListScreen extends StatelessWidget {
  const ChatsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bgSurface = Color(0xFFFAF8FF);
    const onSurface = Color(0xFF131B2E);
    const primaryColor = Color(0xFF6B38D4);
    const surfaceContainerHigh = Color(0xFFE2E7FF);
    const outlineVariant = Color(0xFFCBC3D7);

    return Scaffold(
      backgroundColor: bgSurface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Chats',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: surfaceContainerHigh,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.filter_list, size: 20, color: primaryColor),
                      onPressed: () {},
                      tooltip: 'Filter chats',
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),

            // Search Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(9999),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x146B38D4),
                      blurRadius: 24,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  style: const TextStyle(color: onSurface, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Search chats...',
                    hintStyle: const TextStyle(color: outlineVariant, fontSize: 15),
                    prefixIcon: const Icon(Icons.search, color: outlineVariant),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Chat List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                children: [
                  // Chat Row 1 (Alex Rivera - Unread)
                  _ChatRow(
                    id: 'alex',
                    name: 'Alex Rivera',
                    message: 'Are we still on for tacos tonight?? 🌮',
                    time: '12:42 PM',
                    imageUrl:
                        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
                    isUnread: true,
                    onTap: () {
                      context.push('/chat/alex');
                    },
                  ),

                  const SizedBox(height: 10),

                  // Chat Row 2 (Chloe - Typing)
                  _ChatRow(
                    id: 'chloe',
                    name: 'Chloe',
                    time: 'Yesterday',
                    imageUrl:
                        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
                    isTyping: true,
                    onTap: () {
                      context.push('/chat/chloe');
                    },
                  ),

                  const SizedBox(height: 10),

                  // Chat Row 3 (Design Gang - Group initials)
                  _ChatRow(
                    id: 'design-gang',
                    name: 'Design Gang',
                    message: 'Check out this new Figma file! 🎨',
                    time: 'Mon',
                    initials: 'DG',
                    isRead: true,
                    onTap: () {
                      context.push('/chat/design-gang');
                    },
                  ),

                  const SizedBox(height: 10),

                  // Chat Row 4 (Buster's Daycare - Photo attachment)
                  _ChatRow(
                    id: 'busters-daycare',
                    name: "Buster's Daycare",
                    message: 'Sent a photo',
                    time: 'Sun',
                    imageUrl:
                        'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&w=200&q=80',
                    isPhotoAttachment: true,
                    onTap: () {
                      context.push('/chat/busters-daycare');
                    },
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

class _ChatRow extends StatelessWidget {
  final String id;
  final String name;
  final String? message;
  final String time;
  final String? imageUrl;
  final String? initials;
  final bool isUnread;
  final bool isTyping;
  final bool isRead;
  final bool isPhotoAttachment;
  final VoidCallback onTap;

  const _ChatRow({
    required this.id,
    required this.name,
    this.message,
    required this.time,
    this.imageUrl,
    this.initials,
    this.isUnread = false,
    this.isTyping = false,
    this.isRead = false,
    this.isPhotoAttachment = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const onSurface = Color(0xFF131B2E);
    const onSurfaceVariant = Color(0xFF494454);
    const primaryColor = Color(0xFF6B38D4);
    const primaryContainer = Color(0xFF8455EF);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isUnread
                ? const [
                    BoxShadow(
                      color: Color(0x108455EF),
                      blurRadius: 24,
                      offset: Offset(0, 4),
                    ),
                  ]
                : const [
                    BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Unread Indicator Strip
              if (isUnread)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4,
                    decoration: const BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.horizontal(right: Radius.circular(4)),
                    ),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    // Avatar
                    if (imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Image.network(
                          imageUrl!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        ),
                      )
                    else if (initials != null)
                      Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFF57DFFE), Color(0xFFC0488A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            initials!,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(width: 14),

                    // Chat Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: onSurface,
                                ),
                              ),
                              Text(
                                time,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                                  color: isUnread ? primaryColor : onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          if (isTyping)
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: primaryContainer.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      _BouncingDot(delay: 0),
                                      const SizedBox(width: 3),
                                      _BouncingDot(delay: 200),
                                      const SizedBox(width: 3),
                                      _BouncingDot(delay: 400),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Typing...',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w600,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            )
                          else if (isPhotoAttachment)
                            Row(
                              children: [
                                const Icon(Icons.image, size: 16, color: Color(0xFF00687A)),
                                const SizedBox(width: 4),
                                Text(
                                  message ?? '',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: onSurfaceVariant,
                                  ),
                                ),
                              ],
                            )
                          else
                            Row(
                              children: [
                                if (isRead) ...[
                                  const Icon(Icons.done_all, size: 16, color: onSurfaceVariant),
                                  const SizedBox(width: 4),
                                ],
                                Expanded(
                                  child: Text(
                                    message ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isUnread ? FontWeight.w700 : FontWeight.w400,
                                      color: isUnread ? onSurface : onSurfaceVariant,
                                    ),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _BouncingDot extends StatefulWidget {
  final int delay;

  const _BouncingDot({required this.delay});

  @override
  State<_BouncingDot> createState() => _BouncingDotState();
}

class _BouncingDotState extends State<_BouncingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _animation = Tween<double>(begin: 0, end: -4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.delay > 0) {
      _timer = Timer(Duration(milliseconds: widget.delay), () {
        if (mounted) {
          _controller.repeat(reverse: true);
        }
      });
    } else {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: Color(0xFF6B38D4),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
