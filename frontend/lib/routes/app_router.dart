import 'package:flutter/material.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/history/history_screen.dart';

/// App router for navigation
class AppRouter {
  static const String home = '/';
  static const String history = '/history';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case history:
        return MaterialPageRoute(builder: (_) => const HistoryScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
