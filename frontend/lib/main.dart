import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'data/providers/media_provider.dart';
import 'data/providers/download_provider.dart';
import 'data/providers/history_provider.dart';
import 'presentation/screens/home/home_screen.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize app configuration
  await AppConfig.initialize();

  runApp(const URLensApp());
}

class URLensApp extends StatelessWidget {
  const URLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MediaProvider()),
        ChangeNotifierProvider(create: (_) => DownloadProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
