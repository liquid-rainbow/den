import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/chat_api_repository.dart';

class ChatsListScreen extends ConsumerStatefulWidget {
  const ChatsListScreen({super.key});
  @override
  ConsumerState<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends ConsumerState<ChatsListScreen>
    with WidgetsBindingObserver {
  final _username = TextEditingController();
  List<Map<String, dynamic>> _chats = [];
  Timer? _timer;
  bool _loading = true, _fetching = false, _liking = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted &&
          TickerMode.valuesOf(context).enabled &&
          WidgetsBinding.instance.lifecycleState != AppLifecycleState.paused) {
        _refresh();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    if (_fetching || !mounted) return;
    _fetching = true;
    final api = ref.read(chatApiProvider);
    try {
      final chats = await api.conversations();
      if (mounted && identical(api, ref.read(chatApiProvider))) {
        setState(() {
          _chats = chats;
          _loading = false;
          _error = null;
        });
      }
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

  Future<void> _like() async {
    if (_liking || _username.text.trim().isEmpty) return;
    setState(() => _liking = true);
    try {
      final result = await ref
          .read(chatApiProvider)
          .like(_username.text.trim());
      if (!mounted) return;
      _username.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['matched'] == true
                ? 'It’s a match! You can now chat.'
                : 'Like sent. Chat opens when they like you back.',
          ),
        ),
      );
      await _refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(chatError(e))));
      }
    } finally {
      if (mounted) setState(() => _liking = false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _username.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(chatApiProvider, (_, next) {
      setState(() {
        _chats = [];
        _loading = true;
      });
      // Refresh after any request using the previous account has completed.
      Future<void>(() async {
        while (_fetching && mounted) {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        }
        if (mounted) _refresh();
      });
    });
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh chats',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Find a match',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Enter their profile username. You can chat once you both like each other.',
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _username,
                          maxLength: 30,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            prefixText: '@',
                            counterText: '',
                            border: UnderlineInputBorder(),
                          ),
                          onSubmitted: (_) => _like(),
                        ),
                      ),
                      TextButton(
                        onPressed: _liking ? null : _like,
                        child: Text(_liking ? 'Sending…' : 'Like'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: _chats.isEmpty
                            ? [
                                const Padding(
                                  padding: EdgeInsets.all(24),
                                  child: Text(
                                    'No matches yet. When you both like each other, your conversation appears here.',
                                  ),
                                ),
                              ]
                            : _chats
                                  .map(
                                    (chat) => ListTile(
                                      leading: const CircleAvatar(
                                        child: Icon(Icons.person_outline),
                                      ),
                                      title: Text(chat['name'] as String),
                                      subtitle: Text(
                                        chat['lastMessage'] as String? ??
                                            'You matched! Say hello.',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      trailing: const Icon(Icons.chevron_right),
                                      onTap: () async {
                                        await context.push(
                                          '/chat/${chat['id']}',
                                        );
                                        _refresh();
                                      },
                                    ),
                                  )
                                  .toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
