import 'dart:convert';
import 'package:den_backend/config/database.dart';
import 'package:den_backend/config/env.dart';
import 'package:den_backend/middleware/security_headers.dart';
import 'package:den_backend/modules/auth/auth_service.dart';
import 'package:den_backend/modules/user/user_controller.dart';
import 'package:den_backend/modules/user/user_service.dart';
import 'package:den_backend/shared/aws/sms_sender.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:test/test.dart';

class CapturingSmsSender implements SmsSender {
  String? lastCode;

  @override
  Future<void> sendOtp(String phoneNumber, String code) async {
    lastCode = code;
  }
}

void main() {
  late CapturingSmsSender smsSender;
  late AuthService authService;
  late UserService userService;
  late Handler appHandler;

  setUpAll(() async {
    Env.load();
    await Database.initialize();
  });

  tearDownAll(() async {
    await Database.close();
  });

  setUp(() {
    smsSender = CapturingSmsSender();
    authService = AuthService(smsSender: smsSender);
    userService = UserService();
    final userController = UserController(userService: userService);

    final app = Router();
    app.mount('/api/users', userController.router.call);

    appHandler = const Pipeline()
        .addMiddleware(securityHeadersMiddleware())
        .addHandler(app.call);
  });

  Future<Map<String, dynamic>> createAndAuthenticateUser(String phone) async {
    await authService.sendOtp(phone);
    final code = smsSender.lastCode!;
    final verifyRes = await authService.verifyOtp(phone, code);
    return {
      'token': verifyRes.sessionToken!,
      'user': verifyRes.user!,
    };
  }

  Future<void> cleanupUser(String phone) async {
    final pool = Database.pool;
    await pool.execute('DELETE FROM users WHERE phone_number = \$1', parameters: [phone]);
    await pool.execute('DELETE FROM auth_otps WHERE phone_number = \$1', parameters: [phone]);
  }

  test('Auto-generated usernames are sequential and unique on signup via verify-otp', () async {
    final phone1 = '+919876500001';
    final phone2 = '+919876500002';

    await cleanupUser(phone1);
    await cleanupUser(phone2);

    final user1Data = await createAndAuthenticateUser(phone1);
    final user2Data = await createAndAuthenticateUser(phone2);

    final username1 = user1Data['user']['username'] as String;
    final username2 = user2Data['user']['username'] as String;

    expect(username1, isNotEmpty);
    expect(username2, isNotEmpty);
    expect(username1, isNot(equals(username2)));

    // Check sequential formatting (e.g. den001, den002...)
    expect(RegExp(r'^den\d{3,}$').hasMatch(username1), isTrue);
    expect(RegExp(r'^den\d{3,}$').hasMatch(username2), isTrue);

    // Extract numbers and confirm sequential increment
    final num1 = int.parse(username1.replaceFirst('den', ''));
    final num2 = int.parse(username2.replaceFirst('den', ''));
    expect(num2, equals(num1 + 1));

    await cleanupUser(phone1);
    await cleanupUser(phone2);
  });

  test('GET /api/users/me response includes username', () async {
    final phone = '+919876500003';
    await cleanupUser(phone);

    final authData = await createAndAuthenticateUser(phone);
    final token = authData['token'] as String;

    final request = Request(
      'GET',
      Uri.parse('http://localhost/api/users/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    final response = await appHandler(request);
    expect(response.statusCode, equals(200));

    final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
    expect(body['success'], isTrue);
    expect(body['user']['username'], isNotNull);
    expect(body['user']['username'], equals(authData['user']['username']));

    await cleanupUser(phone);
  });

  test('PATCH /api/users/me/username successfully updates username to an available valid name', () async {
    final phone = '+919876500004';
    await cleanupUser(phone);

    final authData = await createAndAuthenticateUser(phone);
    final token = authData['token'] as String;

    final newUsername = 'valid_user_123';

    final request = Request(
      'PATCH',
      Uri.parse('http://localhost/api/users/me/username'),
      headers: {
        'Authorization': 'Bearer $token',
        'content-type': 'application/json',
      },
      body: jsonEncode({'username': newUsername}),
    );

    final response = await appHandler(request);
    expect(response.statusCode, equals(200));

    final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
    expect(body['success'], isTrue);
    expect(body['username'], equals(newUsername));

    // Verify GET /me returns updated username
    final meRequest = Request(
      'GET',
      Uri.parse('http://localhost/api/users/me'),
      headers: {'Authorization': 'Bearer $token'},
    );
    final meResponse = await appHandler(meRequest);
    final meBody = jsonDecode(await meResponse.readAsString()) as Map<String, dynamic>;
    expect(meBody['user']['username'], equals(newUsername));

    await cleanupUser(phone);
  });

  test('PATCH /api/users/me/username rejects already-taken username case-insensitively with 409 Conflict', () async {
    final phone1 = '+919876500005';
    final phone2 = '+919876500006';

    await cleanupUser(phone1);
    await cleanupUser(phone2);

    final auth1 = await createAndAuthenticateUser(phone1);
    final auth2 = await createAndAuthenticateUser(phone2);

    // User 1 sets username to 'unique_alpha'
    final req1 = Request(
      'PATCH',
      Uri.parse('http://localhost/api/users/me/username'),
      headers: {
        'Authorization': 'Bearer ${auth1['token']}',
        'content-type': 'application/json',
      },
      body: jsonEncode({'username': 'unique_alpha'}),
    );
    final res1 = await appHandler(req1);
    expect(res1.statusCode, equals(200));

    // User 2 attempts to set username to 'UNIQUE_ALPHA' (case-insensitive match)
    final req2 = Request(
      'PATCH',
      Uri.parse('http://localhost/api/users/me/username'),
      headers: {
        'Authorization': 'Bearer ${auth2['token']}',
        'content-type': 'application/json',
      },
      body: jsonEncode({'username': 'UNIQUE_ALPHA'}),
    );
    final res2 = await appHandler(req2);
    expect(res2.statusCode, equals(409));

    final body2 = jsonDecode(await res2.readAsString()) as Map<String, dynamic>;
    expect(body2['success'], isFalse);
    expect(body2['message'], equals('Username already taken.'));

    await cleanupUser(phone1);
    await cleanupUser(phone2);
  });

  test('PATCH /api/users/me/username rejects invalid formats with 400 Bad Request', () async {
    final phone = '+919876500007';
    await cleanupUser(phone);

    final auth = await createAndAuthenticateUser(phone);
    final token = auth['token'] as String;

    final invalidUsernames = [
      'ab', // too short (< 3 chars)
      'a' * 31, // too long (> 30 chars)
      'user name', // contains spaces
      'user@name', // contains invalid symbol @
      'user#name!', // contains invalid symbol #!
    ];

    for (final invalidName in invalidUsernames) {
      final request = Request(
        'PATCH',
        Uri.parse('http://localhost/api/users/me/username'),
        headers: {
          'Authorization': 'Bearer $token',
          'content-type': 'application/json',
        },
        body: jsonEncode({'username': invalidName}),
      );

      final response = await appHandler(request);
      expect(response.statusCode, equals(400), reason: 'Username "$invalidName" should be rejected with 400');
      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      expect(body['success'], isFalse);
    }

    await cleanupUser(phone);
  });

  test('A user can successfully change their own username more than once', () async {
    final phone = '+919876500008';
    await cleanupUser(phone);

    final auth = await createAndAuthenticateUser(phone);
    final token = auth['token'] as String;

    final names = ['first_name_1', 'second_name_2', 'third_name_3'];

    for (final name in names) {
      final request = Request(
        'PATCH',
        Uri.parse('http://localhost/api/users/me/username'),
        headers: {
          'Authorization': 'Bearer $token',
          'content-type': 'application/json',
        },
        body: jsonEncode({'username': name}),
      );

      final response = await appHandler(request);
      expect(response.statusCode, equals(200));

      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      expect(body['success'], isTrue);
      expect(body['username'], equals(name));
    }

    await cleanupUser(phone);
  });

  test('User A changes username to newname1; User B then successfully claims freed old username', () async {
    final phoneA = '+919876500010';
    final phoneB = '+919876500011';

    await cleanupUser(phoneA);
    await cleanupUser(phoneB);

    final userA = await createAndAuthenticateUser(phoneA);
    final userB = await createAndAuthenticateUser(phoneB);

    final tokenA = userA['token'] as String;
    final tokenB = userB['token'] as String;

    final initialUsernameA = userA['user']['username'] as String;

    // User A changes username to 'newname1'
    final reqA = Request(
      'PATCH',
      Uri.parse('http://localhost/api/users/me/username'),
      headers: {
        'Authorization': 'Bearer $tokenA',
        'content-type': 'application/json',
      },
      body: jsonEncode({'username': 'newname1'}),
    );
    final resA = await appHandler(reqA);
    expect(resA.statusCode, equals(200));

    // User B now claims User A's freed initial username
    final reqB = Request(
      'PATCH',
      Uri.parse('http://localhost/api/users/me/username'),
      headers: {
        'Authorization': 'Bearer $tokenB',
        'content-type': 'application/json',
      },
      body: jsonEncode({'username': initialUsernameA}),
    );
    final resB = await appHandler(reqB);
    expect(resB.statusCode, equals(200));

    final bodyB = jsonDecode(await resB.readAsString()) as Map<String, dynamic>;
    expect(bodyB['success'], isTrue);
    expect(bodyB['username'], equals(initialUsernameA));

    await cleanupUser(phoneA);
    await cleanupUser(phoneB);
  });

  test('User A attempts to change username to User B current still-in-use username and is rejected with 409', () async {
    final phoneA = '+919876500012';
    final phoneB = '+919876500013';

    await cleanupUser(phoneA);
    await cleanupUser(phoneB);

    final userA = await createAndAuthenticateUser(phoneA);
    final userB = await createAndAuthenticateUser(phoneB);

    final tokenA = userA['token'] as String;

    // User B's current active username
    final currentUsernameB = userB['user']['username'] as String;

    // User A attempts to claim User B's active username
    final reqA = Request(
      'PATCH',
      Uri.parse('http://localhost/api/users/me/username'),
      headers: {
        'Authorization': 'Bearer $tokenA',
        'content-type': 'application/json',
      },
      body: jsonEncode({'username': currentUsernameB}),
    );
    final resA = await appHandler(reqA);
    expect(resA.statusCode, equals(409));

    final bodyA = jsonDecode(await resA.readAsString()) as Map<String, dynamic>;
    expect(bodyA['success'], isFalse);
    expect(bodyA['message'], equals('Username already taken.'));

    await cleanupUser(phoneA);
    await cleanupUser(phoneB);
  });
}
