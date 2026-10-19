import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;

  const ChatDetailScreen({super.key, required this.chatId});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatMessage {
  final String text;
  final bool isMe;
  final String time;
  final bool isSeen;
  final bool isDelivered;

  const _ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
    this.isSeen = false,
    this.isDelivered = false,
  });
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();

  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      text: 'Are we still on for tacos tonight?? 🌮',
      isMe: false,
      time: '5:42 PM',
    ),
    const _ChatMessage(
      text: 'Absolutely! What time?',
      isMe: true,
      time: '5:45 PM',
      isDelivered: true,
    ),
    const _ChatMessage(
      text: 'Does 7pm work for you?',
      isMe: false,
      time: '5:46 PM',
    ),
    const _ChatMessage(
      text: 'Perfect, see you there! 🚗💨',
      isMe: true,
      time: '5:47 PM',
      isSeen: true,
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        _ChatMessage(
          text: text,
          isMe: true,
          time: 'Just now',
          isDelivered: true,
        ),
      );
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    const bgSurface = Color(0xFFFAF8FF);
    const onSurface = Color(0xFF131B2E);
    const onSurfaceVariant = Color(0xFF494454);
    const primaryColor = Color(0xFF6B38D4);
    const secondaryColor = Color(0xFF00687A);
    const secondaryFixed = Color(0xFFACEDFF);
    const surfaceVariant = Color(0xFFDAE2FD);
    const surfaceContainerHigh = Color(0xFFE2E7FF);
    const outline = Color(0xFF7B7486);

    return Scaffold(
      backgroundColor: bgSurface,
      body: SafeArea(
        child: Column(
          children: [
            // Chat Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0D6B38D4),
                    blurRadius: 24,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: primaryColor),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/chat');
                      }
                    },
                  ),
                  const SizedBox(width: 4),
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.network(
                          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CD7F6),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x804CD7F6),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Alex Rivera',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: secondaryFixed.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Online',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: secondaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: onSurfaceVariant),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Messages List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  // Time Separator
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Today, 5:42 PM',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),

                  // Messages
                  ..._messages.map((m) {
                    if (m.isMe) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.75,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: const BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(24),
                                  topRight: Radius.circular(24),
                                  bottomLeft: Radius.circular(24),
                                  bottomRight: Radius.circular(4),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x336B38D4),
                                    blurRadius: 16,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                m.text,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                  height: 1.35,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (m.isSeen)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text(
                                    'Seen',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: primaryColor,
                                    ),
                                  ),
                                  SizedBox(width: 3),
                                  Icon(Icons.done_all, size: 14, color: primaryColor),
                                ],
                              )
                            else
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    m.time,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: outline,
                                    ),
                                  ),
                                  if (m.isDelivered) ...[
                                    const SizedBox(width: 3),
                                    const Icon(Icons.done_all, size: 14, color: primaryColor),
                                  ],
                                ],
                              ),
                          ],
                        ),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.75,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: const BoxDecoration(
                                color: surfaceVariant,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(24),
                                  topRight: Radius.circular(24),
                                  bottomRight: Radius.circular(24),
                                  bottomLeft: Radius.circular(4),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x08000000),
                                    blurRadius: 12,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                m.text,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: onSurface,
                                  height: 1.35,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              m.time,
                              style: const TextStyle(
                                fontSize: 11,
                                color: outline,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  }),

                  // Typing Indicator
                  Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=100&q=80',
                            width: 24,
                            height: 24,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              _TypingDot(delay: 0),
                              SizedBox(width: 4),
                              _TypingDot(delay: 150),
                              SizedBox(width: 4),
                              _TypingDot(delay: 300),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Message Input Area
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 16,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F6F9),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFE8E5EE)),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        onSubmitted: (_) => _sendMessage(),
                        style: const TextStyle(color: onSurface, fontSize: 15),
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: outline, fontSize: 15),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.mic, color: primaryColor, size: 22),
                      onPressed: () {},
                    ),
                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x666B38D4),
                            blurRadius: 12,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white, size: 18),
                        onPressed: _sendMessage,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingDot extends StatefulWidget {
  final int delay;

  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

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

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
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
            width: 6,
            height: 6,
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
