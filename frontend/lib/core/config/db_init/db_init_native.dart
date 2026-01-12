import 'dart:io';
// import 'package:sqflite_common_ffi/sqflite_common_ffi.dart';
import 'package:sqflite/sqflite.dart';

void initializeDatabase() {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // sqfliteFfiInit();
    // databaseFactory = databaseFactoryFfi;
  }
}
