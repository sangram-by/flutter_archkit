class RenameConfig {
  final String? appName;
  final String? packageName;

  // Platform-specific overrides
  final String? androidAppName;
  final String? androidPackageName;

  final String? iosAppName;
  final String? iosBundleId;

  final String? webAppName;
  final String? webDescription;

  final String? macosAppName;
  final String? macosBundleId;

  final String? windowsAppName;

  final String? linuxAppName;
  final String? linuxPackageName;

  const RenameConfig({
    this.appName,
    this.packageName,
    this.androidAppName,
    this.androidPackageName,
    this.iosAppName,
    this.iosBundleId,
    this.webAppName,
    this.webDescription,
    this.macosAppName,
    this.macosBundleId,
    this.windowsAppName,
    this.linuxAppName,
    this.linuxPackageName,
  });

  String? get effectiveAndroidAppName => androidAppName ?? appName;
  String? get effectiveAndroidPackageName => androidPackageName ?? packageName;

  String? get effectiveIosAppName => iosAppName ?? appName;
  String? get effectiveIosBundleId => iosBundleId ?? packageName;

  String? get effectiveWebAppName => webAppName ?? appName;

  String? get effectiveMacosAppName => macosAppName ?? appName;
  String? get effectiveMacosBundleId => macosBundleId ?? packageName;

  String? get effectiveWindowsAppName => windowsAppName ?? appName;

  String? get effectiveLinuxAppName => linuxAppName ?? appName;
  String? get effectiveLinuxPackageName => linuxPackageName ?? packageName;

  bool get hasAnyChange =>
      (appName != null && appName!.isNotEmpty) ||
      (packageName != null && packageName!.isNotEmpty) ||
      (androidAppName != null && androidAppName!.isNotEmpty) ||
      (androidPackageName != null && androidPackageName!.isNotEmpty) ||
      (iosAppName != null && iosAppName!.isNotEmpty) ||
      (iosBundleId != null && iosBundleId!.isNotEmpty) ||
      (webAppName != null && webAppName!.isNotEmpty) ||
      (webDescription != null && webDescription!.isNotEmpty) ||
      (macosAppName != null && macosAppName!.isNotEmpty) ||
      (macosBundleId != null && macosBundleId!.isNotEmpty) ||
      (windowsAppName != null && windowsAppName!.isNotEmpty) ||
      (linuxAppName != null && linuxAppName!.isNotEmpty) ||
      (linuxPackageName != null && linuxPackageName!.isNotEmpty);
}
