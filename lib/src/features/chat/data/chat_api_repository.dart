import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';

class ChatApiRepository {
  final Dio _dio;

  ChatApiRepository(this._dio);

  Future<List<Map<String, dynamic>>> getChats() async {
    final response = await _dio.get('/api/chats');
    return List<Map<String, dynamic>>.from(response.data['chats']);
  }

  Future<List<Map<String, dynamic>>> getChatMessages(String chatId) async {
    final response = await _dio.get('/api/chats/$chatId/messages');
    return List<Map<String, dynamic>>.from(response.data['messages']);
  }
}

final chatApiRepositoryProvider = Provider<ChatApiRepository>((ref) {
  return ChatApiRepository(ref.watch(dioProvider));
});

final chatsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  final repo = ref.watch(chatApiRepositoryProvider);
  return repo.getChats();
});

final chatMessagesProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, chatId) {
  final repo = ref.watch(chatApiRepositoryProvider);
  return repo.getChatMessages(chatId);
});
