import 'package:get_it/get_it.dart';
import 'services/database_service.dart';
import 'services/mock_database_service.dart';

final sl = GetIt.instance;

void setupLocator() {
  sl.registerSingleton<DatabaseService>(MockDatabaseService());
}