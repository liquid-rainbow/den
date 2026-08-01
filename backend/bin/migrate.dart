import 'dart:io';

import 'package:den_backend/config/database.dart';
import 'package:den_backend/config/env.dart';
import 'package:postgres/postgres.dart';

void main() async {
  Env.load();

  print('1. Connecting to default database "postgres" to ensure "${Env.dbName}" exists...');
  final initConn = await Connection.open(
    Endpoint(
      host: Env.dbHost,
      port: Env.dbPort,
      database: 'postgres',
      username: Env.dbUser,
      password: Env.dbPassword,
    ),
    settings: const ConnectionSettings(sslMode: SslMode.disable),
  );

  final dbCheck = await initConn.execute("SELECT 1 FROM pg_database WHERE datname = '${Env.dbName}'");
  if (dbCheck.isEmpty) {
    print('Creating database "${Env.dbName}"...');
    await initConn.execute('CREATE DATABASE ${Env.dbName}');
    print('Database "${Env.dbName}" created successfully!');
  } else {
    print('Database "${Env.dbName}" already exists.');
  }
  await initConn.close();

  print('2. Connecting to "${Env.dbName}" database and running migrations...');
  await Database.initialize();
  final pool = Database.pool;

  try {
    final migrationFile = File('migrations/001_initial_schema.sql');
    if (!migrationFile.existsSync()) {
      print('ERROR: Migration file not found!');
      exit(1);
    }

    final rawSql = await migrationFile.readAsString();
    print('Executing 001_initial_schema.sql...');
    
    // Remove SQL line comments
    final lines = rawSql.split('\n');
    final cleanedLines = lines.where((l) => !l.trimLeft().startsWith('--')).join('\n');

    final statements = cleanedLines
        .split(';')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    for (final statement in statements) {
      if (statement.isNotEmpty) {
        await pool.execute(statement);
      }
    }

    print('Migrations executed successfully!\n');

    print('================ TABLE VERIFICATION OUTPUT ================');
    final tablesResult = await pool.execute(
      "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' ORDER BY table_name;",
    );
    print('Tables created in public schema (${tablesResult.length} tables):');
    for (final row in tablesResult) {
      print(' - ${row[0]}');
    }

    print('\nIndexes on user_photos table:');
    final indexResult = await pool.execute(
      "SELECT indexname, indexdef FROM pg_indexes WHERE tablename = 'user_photos';",
    );
    for (final row in indexResult) {
      print(' - ${row[0]}: ${row[1]}');
    }
    print('===========================================================');
  } catch (e, st) {
    print('Migration failed: $e');
    print(st);
    exit(1);
  } finally {
    await Database.close();
  }
}
