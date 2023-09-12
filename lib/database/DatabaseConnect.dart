import 'package:test_app/database/AppDatabase.dart';

class DatabaseConnect {
  AppDatabase? database;

  AppDatabase? init() {
    $FloorAppDatabase
        .databaseBuilder('database_test.db')
        .build()
        .then((value) async {
      database = value;
    });
    return database;
  }
}
