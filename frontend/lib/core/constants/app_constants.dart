/// Application-wide constants
class AppConstants {
  // App Info
  static const String appName = 'URLens';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Universal Web Media Downloader';

  // Database
  static const String databaseName = 'urlens.db';
  static const int databaseVersion = 1;
  static const String downloadHistoryTable = 'download_history';

  // UI
  static const double borderRadius = 12.0;
  static const double padding = 16.0;
  static const double spacing = 8.0;

  // Downloads
  static const int maxConcurrentDownloads = 3;

  // Legal
  static const String disclaimer = '''
URLens is a tool for downloading publicly accessible media from the internet.

IMPORTANT: You are solely responsible for ensuring that you have the legal right to download and use any content. This application should not be used for copyright infringement.

By using URLens, you agree to:
1. Only download content you have permission to download
2. Comply with all applicable copyright laws
3. Respect the terms of service of source platforms
4. Use downloaded content for personal, non-commercial purposes only

The developers of URLens are not responsible for any misuse of this application.
''';

  static const String termsOfService = '''
Terms of Service

1. Acceptance of Terms
By using URLens, you accept these terms.

2. Use License
URLens is provided for personal use only.

3. User Responsibilities
You are responsible for your use of URLens and any content you download.

4. Prohibited Uses
- Downloading copyrighted material without permission
- Commercial use without proper licensing
- Violating platform terms of service

5. Disclaimer
URLens is provided "as is" without warranty of any kind.

6. Limitation of Liability
The developers are not liable for any damages arising from use of URLens.

7. Changes to Terms
Terms may be updated at any time.

Last Updated: January 12, 2026
''';
}
