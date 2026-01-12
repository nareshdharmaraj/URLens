import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'core/constants/app_constants.dart';
import 'data/providers/media_provider.dart';
import 'data/providers/download_provider.dart';
import 'data/providers/history_provider.dart';
import 'data/providers/settings_provider.dart'; // Import SettingsProvider
import 'presentation/screens/home/home_screen.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize app configuration
  await AppConfig.initialize();
  await NotificationService().initialize();

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
        ChangeNotifierProvider(create: (_) => SettingsProvider()), // Add SettingsProvider
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            // Use Themes from AppTheme
            theme: AppTheme.lightTheme, 
            // Note: We are prioritizing Light Theme as requested, but keeping dark config
            // if user explicitly switches.
            darkTheme: AppTheme.darkTheme, 
            // Connect ThemeMode to Provider
            themeMode: settings.themeMode, 
            home: const HomeScreen(),
            onGenerateRoute: AppRouter.generateRoute,
          );
        },
      ),
    );
  }
}
