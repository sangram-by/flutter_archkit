# 🎯 Multi-Flavor Environment Setup Guide

`flutter_archkit` automates multi-environment configuration (e.g. `dev`, `staging`, `prod`) for both Android and iOS platforms, as well as Dart environment configs and IDE run targets.

---

## ⚡ Commands

```bash
# 1. Initialize flavor.yaml template in project root
archkit flavor --init

# 2. Validate flavor.yaml syntax and configuration values
archkit flavor --validate

# 3. Generate Android, iOS, Dart, and IDE flavor files
archkit flavor

# Alias
archkit -fl
```

---

## 📄 `flavor.yaml` Schema

Configure your app environments in `flavor.yaml`:

```yaml
flavors:
  dev:
    app:
      name: "App [DEV]"
      baseUrl: "https://dev-api.example.com"
    android:
      applicationId: "com.example.app.dev"
    ios:
      bundleId: "com.example.app.dev"

  prod:
    app:
      name: "App"
      baseUrl: "https://api.example.com"
    android:
      applicationId: "com.example.app"
    ios:
      bundleId: "com.example.app"
```

---

## 🛠️ Automated Setup Artifacts

### 1. Android (`android/app/flavor.gradle.kts`)
Automatically creates Gradle `productFlavors` and links them cleanly with `build.gradle.kts`:
```kotlin
flavorDimensions += "default"

productFlavors {
    create("dev") {
        dimension = "default"
        applicationId = "com.example.app.dev"
        resValue("string", "app_name", "App [DEV]")
    }
    create("prod") {
        dimension = "default"
        applicationId = "com.example.app"
        resValue("string", "app_name", "App")
    }
}
```

---

### 2. iOS XCConfig & Xcode Schemes
- Generates `.xcconfig` build configurations (`Debug-dev.xcconfig`, `Release-prod.xcconfig`, etc.).
- Configures CocoaPods target integrations (`#include? "Pods-Runner.<mode>-<flavor>.xcconfig"`).
- Generates shared `.xcscheme` scheme definitions in `Runner.xcodeproj/xcshareddata/xcschemes/`.
- Patches `Info.plist` with dynamic `CFBundleDisplayName` and `BaseURL`.
- Upgrades `IPHONEOS_DEPLOYMENT_TARGET = 16.0` in Xcode `project.pbxproj`.

---

### 3. Strongly Typed Dart Configuration (`lib/core/config/server_config.dart`)
```dart
enum Flavor { dev, prod }

class ServerConfig {
  static late Flavor currentFlavor;
  static late String baseUrl;
  static late String appName;

  static void setFlavor(Flavor flavor) {
    currentFlavor = flavor;
    switch (flavor) {
      case Flavor.dev:
        baseUrl = 'https://dev-api.example.com';
        appName = 'App [DEV]';
        break;
      case Flavor.prod:
        baseUrl = 'https://api.example.com';
        appName = 'App';
        break;
    }
  }
}
```

---

### 4. IDE 1-Click Run Configurations
- **VS Code**: Scaffolds `.vscode/launch.json` for 1-click target debugging.
- **Android Studio / IntelliJ**: Scaffolds `.run/<flavor>.run.xml` run configurations.
