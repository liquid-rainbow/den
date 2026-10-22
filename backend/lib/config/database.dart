import 'dart:io';

import 'package:den_backend/config/env.dart';
import 'package:postgres/postgres.dart';

class Database {
  static Pool? _pool;

  static SslMode get sslMode => switch (Env.dbSslMode) {
        'disable' => SslMode.disable,
        'verify-full' => SslMode.verifyFull,
        _ => throw StateError('Unsupported DB_SSL_MODE: ${Env.dbSslMode}'),
      };

  static SecurityContext? createSecurityContext() {
    if (sslMode == SslMode.disable) return null;

    final certificate = File(Env.dbSslRootCertificate);
    if (!certificate.existsSync()) {
      throw StateError(
        'Database CA certificate not found: ${Env.dbSslRootCertificate}',
      );
    }

    return SecurityContext(withTrustedRoots: false)
      ..setTrustedCertificates(certificate.path);
  }

  static Pool get pool {
    if (_pool == null) {
      throw StateError(
          'Database pool has not been initialized. Call Database.initialize() first.');
    }
    return _pool!;
  }

  static Future<void> initialize() async {
    if (_pool != null) return;

    final endpoint = Endpoint(
      host: Env.dbHost,
      port: Env.dbPort,
      database: Env.dbName,
      username: Env.dbUser,
      password: Env.dbPassword,
    );

    _pool = Pool.withEndpoints(
      [endpoint],
      settings: PoolSettings(
        maxConnectionCount: Env.dbPoolSize,
        sslMode: sslMode,
        securityContext: createSecurityContext(),
      ),
    );
  }

  static Future<void> close() async {
    await _pool?.close();
    _pool = null;
  }
}
