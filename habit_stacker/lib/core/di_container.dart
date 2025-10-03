import 'package:get_it/get_it.dart';
import 'services/database_service.dart';
import 'services/isar_database_service.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  final dbService = IsarDatabaseService();
  await dbService.initialize();
  sl.registerSingleton<DatabaseService>(dbService);
}