import 'package:den_backend/config/env.dart';
import 'package:postgres/postgres.dart';

class Database {
  static Pool? _pool;

  static Pool get pool {
    if (_pool == null) {
      throw StateError('Database pool has not been initialized. Call Database.initialize() first.');
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
        sslMode: SslMode.disable,
      ),
    );
  }

  static Future<void> close() async {
    await _pool?.close();
    _pool = null;
  }
}
