import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'app.dart';
import 'core/services/notification_service.dart';
import 'data/local/app_database.dart';
import 'data/local/database_key.dart';
import 'providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.initialize();
  const secureStorage = FlutterSecureStorage();
  final key = await const DatabaseKeyStore(secureStorage).getOrCreate();
  final database = AppDatabase.open(key);
  runApp(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(database)],
      child: const HabitWiseApp(),
    ),
  );
}
