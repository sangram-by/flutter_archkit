/// Represents a single build flavor (dev, staging, prod, etc.)
class FlavorConfig {
  final String name; // e.g. "dev"
  final String appName; // e.g. "MyApp Dev"
  final String? androidAppName; // Optional platform override e.g. "Aritra Android"
  final String? iosAppName; // Optional platform override e.g. "Aritra iOS"
  final String applicationId; // e.g. "com.example.app.dev"
  final String bundleId; // e.g. "com.example.app.dev"
  final String baseUrl; // e.g. "https://dev.api.example.com"

  const FlavorConfig({
    required this.name,
    required this.appName,
    this.androidAppName,
    this.iosAppName,
    required this.applicationId,
    required this.bundleId,
    required this.baseUrl,
  });

  String get effectiveAndroidAppName =>
      (androidAppName != null && androidAppName!.trim().isNotEmpty)
          ? androidAppName!.trim()
          : appName;

  String get effectiveIosAppName =>
      (iosAppName != null && iosAppName!.trim().isNotEmpty)
          ? iosAppName!.trim()
          : appName;

  Map<String, String> toTemplateVars() => {
    'FLAVOR_NAME': name,
    'APP_NAME': appName,
    'ANDROID_APP_NAME': effectiveAndroidAppName,
    'IOS_APP_NAME': effectiveIosAppName,
    'APPLICATION_ID': applicationId,
    'BUNDLE_ID': bundleId,
    'BASE_URL': baseUrl,
  };
}
