import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/chat_api_repository.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final String chatId;
  const ChatDetailScreen({super.key, required this.chatId});
  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen>
    with WidgetsBindingObserver {
  final _text = TextEditingController();
  final _scroll = ScrollController();
  final Map<String, Map<String, dynamic>> _messages = {};
  Timer? _timer;
  bool _loading = true,
      _fetching = false,
      _sending = false,
      _older = false,
      _hasOlder = true;
  String _name = 'Conversation';
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _refresh());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  List<Map<String, dynamic>> get _sorted => _messages.values.toList()
    ..sort(
      (a, b) => BigInt.parse(
        a['id'] as String,
      ).compareTo(BigInt.parse(b['id'] as String)),
    );
  Future<void> _refresh() async {
    if (_fetching ||
        !mounted ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.paused) {
      return;
    }
    _fetching = true;
    final api = ref.read(chatApiProvider);
    try {
      if (_loading) {
        final chats = await api.conversations();
        for (final chat in chats) {
          if (chat['id'] == widget.chatId) _name = chat['name'] as String;
        }
      }
      final messages = await api.messages(widget.chatId);
      if (!mounted || !identical(api, ref.read(chatApiProvider))) return;
      final atBottom =
          !_scroll.hasClients || _scroll.position.extentAfter < 100;
      final first = _loading;
      setState(() {
        for (final message in messages) {
          _messages[message['id'] as String] = message;
        }
        if (first) _hasOlder = messages.length == 100;
        _loading = false;
        _error = null;
      });
      if (first || atBottom) _bottom();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = chatError(e);
          _loading = false;
        });
      }
    } finally {
      _fetching = false;
    }
  }

  void _bottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  Future<void> _loadOlder() async {
    if (_older || _messages.isEmpty) return;
    setState(() => _older = true);
    try {
      final messages = await ref
          .read(chatApiProvider)
          .messages(widget.chatId, before: _sorted.first['id'] as String);
      if (mounted) {
        setState(() {
          for (final message in messages) {
            _messages[message['id'] as String] = message;
          }
          _hasOlder = messages.length == 100;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = chatError(e));
    } finally {
      if (mounted) setState(() => _older = false);
    }
  }

  Future<void> _send() async {
    final text = _text.text.trim();
    if (_sending || text.isEmpty) return;
    setState(() => _sending = true);
    try {
      await ref.read(chatApiProvider).send(widget.chatId, text);
      if (!mounted) return;
      _text.clear();
      while (_fetching && mounted) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      if (!mounted) return;
      await _refresh();
      _bottom();
    } catch (e) {
      if (mounted) setState(() => _error = chatError(e));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _text.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(chatApiProvider, (_, next) {
      setState(() {
        _messages.clear();
        _name = 'Conversation';
        _loading = true;
      });
    });
    final messages = _sorted;
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        title: Text(_name),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh messages',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : messages.isEmpty
                  ? const Center(
                      child: Text('You matched! Send your first message.'),
                    )
                  : ListView(
                      controller: _scroll,
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (_hasOlder)
                          TextButton(
                            onPressed: _older ? null : _loadOlder,
                            child: Text(
                              _older ? 'Loading…' : 'Load older messages',
                            ),
                          ),
                        ...messages.map((m) {
                          final mine = m['isMe'] == true;
                          final date = DateTime.parse(
                            m['createdAt'] as String,
                          ).toLocal();
                          return Align(
                            alignment: mine
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              padding: const EdgeInsets.all(12),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.sizeOf(context).width * .78,
                              ),
                              decoration: BoxDecoration(
                                color: mine
                                    ? const Color(0xFF6B38D4)
                                    : const Color(0xFFE2E7FF),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    m['text'] as String,
                                    style: TextStyle(
                                      color: mine
                                          ? Colors.white
                                          : const Color(0xFF131B2E),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${date.day}/${date.month} ${TimeOfDay.fromDateTime(date).format(context)}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: mine
                                          ? Colors.white70
                                          : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _text,
                      enabled: !_sending,
                      maxLength: 2000,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Type a message…',
                        counterText: '',
                        border: UnderlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _sending || _loading ? null : _send,
                    tooltip: 'Send message',
                    icon: Icon(
                      _sending ? Icons.hourglass_empty : Icons.send,
                      color: const Color(0xFF6B38D4),
                    ),
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
