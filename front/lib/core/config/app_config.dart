/// Backend base URL (no trailing slash). Override at build/run time:
/// `flutter run --dart-define=API_BASE_URL=https://api.example.com`
class AppConfig {
  AppConfig({String? apiBaseUrl})
      : apiBaseUrl = apiBaseUrl ??
            const String.fromEnvironment(
              'API_BASE_URL',
              defaultValue: 'http://localhost:3000',
            );

  final String apiBaseUrl;

  static final AppConfig instance = AppConfig();
}
