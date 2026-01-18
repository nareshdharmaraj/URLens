import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:sqflite_common_ffi/sqflite_common_ffi.dart';

void initializeDatabase() {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    // sqfliteFfiInit();
    // databaseFactory = databaseFactoryFfi;
  }
}
