import 'package:dio/dio.dart';
import 'dart:async';

/// Intercepts network requests and returns dummy successful responses
/// when the app is run with --dart-define=MOCK_MODE=true.
/// This safely bypasses the network for local development without the backend.
class MockInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Artificial network delay to simulate real loading states
    await Future.delayed(const Duration(seconds: 1));

    if (options.path == '/api/auth/send-otp') {
      final phone = options.data['phoneNumber'] as String?;
      if (phone == '+919999999999' || phone == '+918888888888') {
        return handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {'success': true},
          ),
        );
      }
    }

    if (options.path == '/api/auth/verify-otp') {
      final phone = options.data['phoneNumber'] as String?;
      final code = options.data['code'] as String?;
      
      if ((phone == '+919999999999' || phone == '+918888888888') && code == '999999') {
        return handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'sessionToken': 'mock_jwt_token_12345',
              'user': {
                'id': 'mock_user_123',
                'phoneNumber': phone,
                'isNewUser': true, 
              }
            },
          ),
        );
      } else {
        // Simulate incorrect OTP
        return handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.badResponse,
            response: Response(
              requestOptions: options,
              statusCode: 401,
              data: {'message': 'Invalid verification code.'}
            )
          )
        );
      }
    }
    

    // --- Home Feed Mock Endpoints ---
    if (options.path == '/api/home/feed') {
      final radius = int.tryParse(options.queryParameters['radius']?.toString() ?? '50') ?? 50;
      
      // We simulate filtering by radius by dropping an event if radius is too small
      final allEvents = [
        {
          'title': 'Rooftop Neon House Party',
          'dateStr': "12 Oct '24",
          'timeStr': '9:00 PM',
          'locationStr': 'Mission District',
          'joinedCountText': '+42',
          'statsText': '45 Joined • 15 Spots Left',
          'imageUrl': 'https://images.unsplash.com/photo-1566737236500-c8ac43014a67?auto=format&fit=crop&w=1200&q=80',
          'distanceKm': 12,
        },
        {
          'title': 'Underground Warehouse Rave',
          'dateStr': "18 Oct '24",
          'timeStr': '11:00 PM',
          'locationStr': 'SOMA',
          'joinedCountText': '+120',
          'statsText': '122 Joined • 8 Spots Left',
          'imageUrl': 'https://images.unsplash.com/photo-1540039155732-68ee23e15b51?auto=format&fit=crop&w=1200&q=80',
          'distanceKm': 25,
        },
        {
          'title': 'Beach Bonfire Social',
          'dateStr': "25 Oct '24",
          'timeStr': '7:00 PM',
          'locationStr': 'Ocean Beach',
          'joinedCountText': '+80',
          'statsText': '85 Joined • 20 Spots Left',
          'imageUrl': 'https://images.unsplash.com/photo-1517457373958-b7bdd4587205?auto=format&fit=crop&w=1200&q=80',
          'distanceKm': 40,
        },
      ];

      final filteredEvents = allEvents.where((e) => (e['distanceKm'] as int) <= radius).toList();

      return handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {'events': filteredEvents},
      ));
    }
    // --- Chats Mock Endpoints ---
    if (options.path == '/api/chats') {
      return handler.resolve(Response(requestOptions: options, statusCode: 200, data: {
        'chats': [
          {
            'id': 'alex',
            'name': 'Alex Rivera',
            'message': 'Are we still on for tacos tonight?? 🌮',
            'time': '12:42 PM',
            'imageUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
            'isUnread': true,
          },
          {
            'id': 'chloe',
            'name': 'Chloe',
            'message': 'Typing...',
            'time': '10:15 AM',
            'imageUrl': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?auto=format&fit=crop&w=200&q=80',
            'isUnread': false,
          },
          {
            'id': 'design-gang',
            'name': 'Design Gang',
            'message': 'Can someone share the figma link?',
            'time': 'Yesterday',
            'imageUrl': '',
            'isUnread': false,
            'isGroup': true,
          },
        ]
      }));
    }
    
    if (options.path.startsWith('/api/chats/') && options.path.endsWith('/messages')) {
      return handler.resolve(Response(requestOptions: options, statusCode: 200, data: {
        'messages': [
          {'text': 'Are we still on for tacos tonight?? 🌮', 'isMe': false, 'time': '5:42 PM'},
          {'text': 'Absolutely! What time?', 'isMe': true, 'time': '5:45 PM', 'isDelivered': true},
          {'text': 'Does 7pm work for you?', 'isMe': false, 'time': '5:46 PM'},
          {'text': 'Perfect, see you there! 🚗💨', 'isMe': true, 'time': '5:47 PM', 'isSeen': true},
        ]
      }));
    }

    // --- Onboarding & Face Verification Mock Endpoints ---
    if (options.path == '/api/onboarding/face-liveness/session') {
      return handler.resolve(Response(requestOptions: options, statusCode: 200, data: {'sessionId': 'mock_session_123'}));
    }
    if (options.path == '/api/onboarding/verify-face') {
      return handler.resolve(Response(requestOptions: options, statusCode: 200, data: {'isLive': true}));
    }
    if (options.path == '/api/users/me/face-verification-status') {
      return handler.resolve(Response(requestOptions: options, statusCode: 200, data: {'success': true}));
    }

    // --- Photo Upload Mock Endpoints ---
    if (options.path == '/api/uploads/photo-url') {
      return handler.resolve(Response(requestOptions: options, statusCode: 200, data: {
        'uploadUrl': 'https://mock-upload-url.com',
        'photoId': 'mock_photo_123',
        'downloadUrl': 'https://mock-download-url.com',
      }));
    }
    if (options.path == '/api/uploads/complete') {
      return handler.resolve(Response(requestOptions: options, statusCode: 200, data: {'success': true}));
    }

    // --- Profile Mock Endpoints ---
    if (options.path == '/api/users/me' && options.method == 'PUT') {
      return handler.resolve(Response(requestOptions: options, statusCode: 200, data: {'success': true}));
    }
    if (options.path == '/api/users/me/complete-onboarding') {
      return handler.resolve(Response(requestOptions: options, statusCode: 200, data: {'success': true}));
    }

    // If no mock matched, let the request pass through normally (it will likely fail if no backend exists)
    return handler.next(options);
  }
}
