# Flutter ArchKit

[![pub package](https://img.shields.io/pub/v/flutter_archkit.svg)](https://pub.dev/packages/flutter_archkit)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A comprehensive Flutter Architecture CLI generator and multi-flavor configuration tool. `flutter_archkit` automates scaffolding Flutter projects with Clean, MVVM, or MVC architecture, state management (Bloc, Cubit, Riverpod, Provider, GetX), modular feature generators, routing setup, network layer generation, and multi-flavor environment configurations.

---

## Features

- 🏗️ **Interactive Project Generator (`archkit create`)**: Scaffolds complete Flutter apps with interactive CLI prompts for Architecture, State Management, Organization ID, and Target Platforms.
- ⚡ **Feature Module Generator (`archkit feature <name>` / `archkit -f <name>`)**: Instantly generates feature modules (`auth`, `profile`, `home`, etc.) matching your project's architecture.
- 🧠 **Smart `@Archkit` Code Generator (`archkit generate` / `archkit g`)**: Automatically scans presentation event handlers and generates cascading UseCases, Repositories, DataSources, and Service interfaces across Domain and Data layers.
- 🛣️ **Route System Setup (`archkit route` / `archkit r`)**: Scaffolds routing configurations with support for Navigator 1.0, Navigator 2.0, Go Router (with optional `StatefulShellRoute` bottom navigation), Auto Route, and GetX Routing.
- 🌐 **Network Layer Generator (`archkit network` / `archkit n`)**: Scaffolds production-ready Dio network layer with generic `ApiResponse<T>`, custom `ApiException`, typed interfaces, logger/auth interceptors, and utility `typedefs`.
- 🔄 **Smart Metadata Auto-Detection**: Stores selected project configuration in `.metadata` so features, routes, and generators integrate seamlessly without requiring command flags.
- 📂 **Modular Template Engine**: Clean templates for Clean Architecture (data, domain, presentation, di), MVVM (models, services, viewmodels, views), and MVC (models, controllers, views).
- 🤖 **Android Flavor Setup**: Automatically configures `productFlavors` and `applicationId` in `android/app/flavor.gradle.kts` and links with `build.gradle.kts`.
- 🍎 **iOS Flavor Setup**: Generates flavor `.xcconfig` files, CocoaPods target dependencies (`#include? Pods-Runner`), shared `.xcscheme` schemes, patches `Info.plist`, updates Xcode `project.pbxproj` build configurations, and sets `IPHONEOS_DEPLOYMENT_TARGET = 16.0`.
- ⚙️ **Dart ServerConfig**: Generates strongly-typed `lib/core/config/server_config.dart` runtime environment configurations.
- 💻 **IDE Support**: Automatically writes `.vscode/launch.json` for VS Code and `.run/<flavor>.run.xml` run configurations for Android Studio / IntelliJ IDEA.

---

## Installation

Activate `flutter_archkit` globally via Pub:

```bash
dart pub global activate flutter_archkit
```

Or add it to your project `pubspec.yaml` under `dev_dependencies`:

```yaml
dev_dependencies:
  flutter_archkit: ^0.2.0
```

---

## Usage Guide

### 1. Creating a New Flutter Project (`archkit create`)

Run the interactive project creation wizard:

```bash
archkit create my_app
```

**Interactive Prompts:**
- **Select Architecture**: `Clean` | `MVVM` | `MVC`
- **Select State Management**: `Bloc` | `Cubit` | `Riverpod` | `Provider` | `GetX`
- **Organization Identifier**: e.g., `com.example`
- **Platforms**: `Android`, `iOS`, `Web`, `Windows`, `macOS`, `Linux`

Or pass parameters via command flags:
```bash
archkit create my_app --org com.example --architecture Clean --state-management Bloc --platforms android,ios
```

---

### 2. Scaffolding a Feature Module (`archkit feature <name>` / `archkit -f <name>`)

Inside any project created with `archkit`, run:

```bash
archkit feature auth
```

or use the shortcut:

```bash
archkit -f auth
```

`archkit` auto-detects your project's architecture and state management from `.metadata` and generates the feature module matching your established code structure!

---

### 3. Setting Up Route System (`archkit route` / `archkit r`)

Set up a robust routing system tailored to your preferred router package:

```bash
archkit route
```

or use the alias:

```bash
archkit r
```

**Interactive Prompts:**
- **Select Route System**:
  - `Navigator 1.0` (Standard Flutter MaterialPageRoute)
  - `Navigator 2.0` (Declarative RouterDelegate & RouteInformationParser)
  - `Go Router` (Supports `--shell` flag for `StatefulShellRoute` bottom navigation)
  - `Auto Route` (Strongly-typed code-generated routes)
  - `GetX Routing` (GetMaterialApp & GetPage routes)

**CLI Command Flags:**
```bash
# Non-interactive Go Router setup with Stateful Shell Navigation
archkit route --type "Go Router" --shell

# Auto Route setup
archkit route -t auto_route

# GetX Routing setup
archkit route -t getx
```

*Note: Running `archkit route` automatically updates `pubspec.yaml` with the required router dependencies (e.g. `go_router`, `auto_route`, `get`) and persists the router choice in `.metadata`.*

---

### 4. Scaffolding Network Layer (`archkit network` / `archkit n`)

Generate a production-grade Dio HTTP client architecture:

```bash
archkit network
```

or use the alias:

```bash
archkit n
```

**CLI Command Flags:**
```bash
# Specify target directory path
archkit network --path ./my_project

# Force overwrite existing network files
archkit network --override
```

*Note: Running `archkit network` automatically adds `dio: ^5.4.3` to your project's `pubspec.yaml`.*

---

### 5. Generating Domain & Data Layers with `@Archkit` (`archkit generate` / `archkit g`)

Speed up feature development by writing your presentation logic first and generating the domain & data boilerplate automatically.

#### Step 1: Annotate your presentation handler or method

Import `flutter_archkit` and annotate event handlers or functions in your BLoC, Cubit, Controller, Riverpod notifier, or ViewModel with `@Archkit` or `@archkit`:

```dart
import 'package:flutter_archkit/flutter_archkit.dart';
import '../models/weather_model.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  WeatherBloc() : super(WeatherInitial()) {
    on<FetchWeatherEvent>(_onFetchWeather);
  }

  @Archkit(
    endpoint: '/weather',
    method: 'GET',
    returnType: WeatherModel,
  )
  Future<void> _onFetchWeather(
    FetchWeatherEvent event,
    Emitter<WeatherState> emit, {
    required String city,
  }) async {
    // Generated UseCase is automatically invoked here!
  }
}
```

#### Step 2: Run the code generator

```bash
archkit generate
```

or use the shortcut:

```bash
archkit g
```

**CLI Command Flags:**
```bash
# Target a specific feature folder
archkit generate --path lib/features/weather
# or
archkit g -p lib/features/weather

# Preview changes without modifying files
archkit g --dry-run
```

**What gets generated automatically?**
- **Clean Architecture**:
  - `domain/usecases/fetch_weather_usecase.dart` (Strongly typed UseCase class)
  - `domain/repositories/weather_repository.dart` (Repository interface method)
  - `data/repositories/weather_repository_impl.dart` (Repository implementation)
  - `data/data_sources/weather_remote_datasource.dart` (DataSource contract)
  - `data/data_sources/weather_remote_datasource_impl.dart` (Dio network implementation with endpoint & HTTP method)
- **MVVM Architecture**:
  - `services/weather_service.dart` (Service interface & Dio implementation)
- **MVC Architecture**:
  - `controllers/weather_controller.dart` & `providers/weather_provider.dart`

---

### 6. Multi-Flavor Setup (`setup_flavor`)

Generate a sample `flavor.yaml` automatically:

```bash
dart run flutter_archkit:setup_flavor --init
```

Or create `flavor.yaml` manually in your project root:

```yaml
flavors:
  dev:
    app:
      name: "Example Dev"
      baseUrl: "https://dev-api.example.com"
    android:
      applicationId: "com.example.app.dev"
    ios:
      bundleId: "com.example.app.dev"

  prod:
    app:
      name: "Example"
      baseUrl: "https://api.example.com"
    android:
      applicationId: "com.example.app"
    ios:
      bundleId: "com.example.app"
```

Validate your configuration:

```bash
dart run flutter_archkit:setup_flavor --validate
```

Execute the multi-flavor code generator:

```bash
dart run flutter_archkit:setup_flavor
```

---

## Generated Architecture Layouts

### Clean Architecture (`lib/features/auth/`)
```text
lib/features/auth/
├── data/
│   ├── data_sources/
│   │   ├── auth_remote_datasource.dart
│   │   └── auth_remote_datasource_impl.dart
│   ├── models/
│   │   └── auth_model.dart
│   └── repositories/
│       └── auth_repository_impl.dart
├── di/
│   ├── auth_di.dart
│   └── auth_di.config.dart
├── domain/
│   ├── repositories/
│   │   └── auth_repository.dart
│   └── usecases/
│       └── auth_usecase.dart
└── presentation/
    ├── bloc/ (or cubit / riverpod / provider / controllers)
    │   ├── auth_bloc.dart
    │   ├── auth_event.dart
    │   └── auth_state.dart
    └── page/
        └── auth_page.dart
```

### Route System Structure (`lib/core/router/`)
```text
lib/core/router/
├── app_router.dart           # Central router definition (GoRouter / RouterDelegate / AppPages)
├── app_routes.dart           # Route name string constants
├── route_functions.dart      # Navigation helper utilities (push, pop, clearAndGo)
└── bottom_shell_route.dart   # StatefulShellRoute bottom navbar shell widget (Go Router)
```

### Network Layer Structure (`lib/core/`)
```text
lib/core/
├── network/
│   ├── api_exception.dart             # Typed network exception handling
│   ├── api_interface.dart             # Abstract API client contract interface
│   ├── dio.dart                       # Configured Dio HTTP client factory instance
│   ├── dio_network.dart               # Concrete Dio HTTP request handler
│   ├── dio_services.dart              # Base network service class
│   └── interceptors/
│       ├── api_interceptor.dart       # Auth token & header interceptor
│       └── logging.dart               # HTTP request/response logger interceptor
└── util/
    ├── api_response.dart              # Generic ApiResponse<T> state wrapper
    └── typedefs.dart                  # Utility Dart typedefs (JSON, Callbacks)
```

### MVVM Architecture (`lib/`)
```text
lib/
├── models/auth_model.dart
├── services/auth_service.dart
├── viewmodels/auth_provider.dart (or auth_viewmodel.dart / auth_bloc.dart / auth_controller.dart)
└── views/auth_view.dart
```

### MVC Architecture (`lib/`)
```text
lib/
├── models/auth_model.dart
├── controllers/auth_controller.dart
└── views/auth_view.dart
```

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
