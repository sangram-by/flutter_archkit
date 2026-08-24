<p align="center">
  <img src="https://raw.githubusercontent.com/Sangramdeve/flutter_archkit/master/cover.svg" alt="Flutter ArchKit Logo" width="100%" />
</p>

# Flutter ArchKit

<p align="center">
  <strong>The Ultimate Flutter Architecture Generator, Feature Scaffolder, Code Generator & Multi-Flavor CLI Toolkit</strong>
</p>

<p align="center">
  <a href="https://pub.dev/packages/flutter_archkit"><img src="https://img.shields.io/pub/v/flutter_archkit.svg?style=flat-square&color=0175C2" alt="Pub Version"></a>
  <a href="https://pub.dev/packages/flutter_archkit/score"><img src="https://img.shields.io/pub/points/flutter_archkit?style=flat-square&color=2E8B57&label=pub%20points" alt="Pub Points"></a>
  <a href="https://pub.dev/packages/flutter_archkit/score"><img src="https://img.shields.io/pub/likes/flutter_archkit?style=flat-square&color=blue" alt="Pub Likes"></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square" alt="License: MIT"></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-SDK%20%3E%3D3.0.0-0175C2.svg?style=flat-square" alt="Dart SDK"></a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-teal.svg?style=flat-square" alt="Platforms"></a>
</p>

---

## 📖 Overview

**`flutter_archkit`** is an enterprise-grade command-line interface (CLI) toolkit and code generator designed to eliminate architectural boilerplate and streamline Flutter app development. 

Whether starting a greenfield project or scaling an existing production codebase, `flutter_archkit` automates:
- 🏗️ **Project Scaffolding**: Interactive wizard for Clean Architecture, MVVM, or MVC.
- ⚡ **Feature Modules**: One-command feature generator that matches your project's architecture and state management.
- 🧠 **`@Archkit` Code Generation**: Automatically writes cascading UseCases, Repositories, DataSources, and API calls from annotated presentation handlers.
- 🛣️ **Router Infrastructure**: Scaffolds Navigator 1.0/2.0, Go Router (with Bottom Navigation Shells), Auto Route, or GetX Routing.
- 🌐 **Network Layer**: Scaffolds production Dio HTTP client with generic `ApiResponse<T>`, custom `ApiException`, interceptors, and typed contracts.
- 🎯 **Multi-Flavor Environments**: Configures Android Flavors, iOS Schemes & `.xcconfig`, Dart `ServerConfig`, VS Code `launch.json`, and Android Studio run configurations.

---

## 📑 Table of Contents

- [Features & Architecture Matrix](#-features--architecture-matrix)
- [CLI Command Cheat Sheet](#-cli-command-cheat-sheet)
- [Installation](#-installation)
- [Usage Guide](#-usage-guide)
  - [1. Creating a Project (`archkit create`)](#1-creating-a-project-archkit-create)
  - [2. Scaffolding Feature Modules (`archkit feature`)](#2-scaffolding-feature-modules-archkit-feature)
  - [3. Setting Up Route Systems (`archkit route`)](#3-setting-up-route-systems-archkit-route)
  - [4. Generating Network Layer (`archkit network`)](#4-generating-network-layer-archkit-network)
  - [5. `@Archkit` Code Generation (`archkit generate`)](#5-smart-archkit-code-generation-archkit-generate)
  - [6. Multi-Flavor Configuration (`setup_flavor`)](#6-multi-flavor-configuration-setup_flavor)
- [Directory Structures](#-directory-structures)
- [Example Application](#-example-application)
- [Contributing & Issues](#-contributing--issues)
- [License](#-license)

---

## 🧩 Features & Architecture Matrix

| Capability | Supported Technologies & Options |
| :--- | :--- |
| **Architectures** | **Clean Architecture** (Data / Domain / Presentation / DI), **MVVM** (Models / Services / ViewModels / Views), **MVC** (Models / Controllers / Views) |
| **State Management** | **BLoC**, **Cubit**, **Riverpod**, **Provider**, **GetX** |
| **Routing Systems** | **Navigator 1.0**, **Navigator 2.0**, **Go Router** (with StatefulShellRoute bottom navigation support), **Auto Route**, **GetX Routing** |
| **Networking** | **Dio 5.x**, Generic `ApiResponse<T>`, `ApiException`, Logging Interceptor, Auth Interceptors, `ApiInterface` contract |
| **Code Generation** | **`@Archkit` annotation parser**: Cascading generation of UseCases, Repositories, Remote DataSources, and Service interfaces |
| **Multi-Flavor** | **Android** (`flavor.gradle.kts`), **iOS** (XCConfig, Schemes, `project.pbxproj`), **Dart** (`ServerConfig`), **IDE Run Configs** (VS Code & Android Studio) |
| **Configuration** | **Smart `.metadata` tracking**: Auto-detects project architecture without passing repetitive flags |

---

## ⚡ CLI Command Cheat Sheet

| Command | Aliases | Description | Example |
| :--- | :--- | :--- | :--- |
| `archkit create <app_name>` | `-c`, `--create` | Creates a new Flutter app with chosen architecture & state management | `archkit create my_app -a Clean -s Bloc` |
| `archkit feature <name>` | `-f`, `--feature` | Scaffolds a new feature module matching project architecture | `archkit feature auth` or `archkit -f profile` |
| `archkit route` | `-r`, `--route` | Scaffolds routing system & installs router dependencies | `archkit route -t "Go Router" --shell` |
| `archkit network` | `-n`, `--network` | Scaffolds production Dio HTTP network layer | `archkit network --override` |
| `archkit generate` | `g`, `gen`, `-g` | Generates domain & data layer methods for `@Archkit` annotations | `archkit g -p lib/features/auth` |
| `setup_flavor` | `setup_flavor` | Configures multi-flavor environments (Android, iOS, Dart, IDEs) | `dart run flutter_archkit:setup_flavor` |

---

## 📦 Installation

### Global Activation (Recommended)
Activate `flutter_archkit` globally to use the `archkit` CLI from anywhere in your terminal:

```bash
dart pub global activate flutter_archkit
```

> **Note**: Ensure your global pub cache bin path is added to your system's `PATH` environment variable.

### As a Project Dependency
Add `flutter_archkit` to your Flutter project's `pubspec.yaml` under `dev_dependencies` to utilize the `@Archkit` annotation and flavor generators:

```yaml
dev_dependencies:
  flutter_archkit: ^0.2.1
```

Then run:
```bash
flutter pub get
```

---

## 🚀 Usage Guide

### 1. Creating a Project (`archkit create`)

Scaffold a complete, production-ready Flutter application with interactive terminal prompts:

```bash
archkit create my_app
```

```text
? Select Architecture:
  ❯ Clean Architecture (Data, Domain, Presentation, DI)
    MVVM Architecture (Models, Services, ViewModels, Views)
    MVC Architecture (Models, Controllers, Views)

? Select State Management:
  ❯ Bloc
    Cubit
    Riverpod
    Provider
    GetX

? Organization Identifier: com.example
? Target Platforms: android, ios, web
```

#### Non-Interactive CLI Mode
Automate CI/CD or scripted project generation using command-line flags:

```bash
archkit create my_app \
  --org com.example \
  --architecture Clean \
  --state-management Bloc \
  --platforms android,ios,web
```

---

### 2. Scaffolding Feature Modules (`archkit feature`)

Generate modular, architecture-compliant feature packages in seconds. `archkit` automatically detects your project's architecture and state management from `.metadata`!

```bash
# Full command
archkit feature auth

# Or quick shortcut
archkit -f user_profile
```

**Clean Architecture Feature Output (`lib/features/auth/`):**
- `domain/entities/auth_entity.dart`
- `domain/repositories/auth_repository.dart`
- `domain/usecases/auth_usecase.dart`
- `data/models/auth_model.dart`
- `data/data_sources/auth_remote_datasource.dart` & `_impl.dart`
- `data/repositories/auth_repository_impl.dart`
- `presentation/bloc/auth_bloc.dart`, `auth_event.dart`, `auth_state.dart`
- `presentation/page/auth_page.dart`
- `di/auth_di.dart`

---

### 3. Setting Up Route Systems (`archkit route`)

Set up a robust navigation infrastructure tailored to your preferred routing engine:

```bash
archkit route
# Or alias
archkit r
```

#### Supported Route Engines:
1. **`Navigator 1.0`**: Traditional named routes with `RouteGenerator` and `MaterialPageRoute`.
2. **`Navigator 2.0`**: Declarative routing with custom `RouterDelegate` and `RouteInformationParser`.
3. **`Go Router`**: URL-driven routing supporting deep links, route redirection, and optional `StatefulShellRoute` bottom navigation.
4. **`Auto Route`**: Type-safe code-generated navigation.
5. **`GetX Routing`**: Lightweight `GetPage` navigation.

#### CLI Command Flags:
```bash
# Go Router with Bottom Navigation Shell
archkit route --type "Go Router" --shell

# Auto Route setup
archkit route -t auto_route

# GetX Routing setup
archkit route -t getx
```

*Note: Running `archkit route` automatically adds the required package dependencies to `pubspec.yaml` and persists your configuration in `.metadata`.*

---

### 4. Generating Network Layer (`archkit network`)

Scaffold a battle-tested Dio network client architecture in `lib/core/network/` and `lib/core/util/`:

```bash
archkit network
# Or alias
archkit n
```

#### CLI Options:
```bash
# Specify custom project path
archkit network --path ./my_project

# Force overwrite existing network files
archkit network --override
```

#### What gets scaffolded?
- **`ApiResponse<T>`**: Standardized response wrapper representing `Success`, `Error`, and `Loading` states.
- **`ApiException`**: Centralized exception handler parsing HTTP status codes, validation errors, and timeout exceptions.
- **`ApiInterface`**: Abstract contract for GET, POST, PUT, DELETE, and PATCH methods.
- **`DioNetwork` & `DioServices`**: Configured Dio instance with base URLs, headers, connection timeouts, and SSL pinning hooks.
- **Interceptors**:
  - `ApiInterceptor`: Automatic bearer token injection and authentication headers.
  - `LoggingInterceptor`: Detailed console request/response logging in debug mode.

---

### 5. Smart `@Archkit` Code Generation (`archkit generate`)

Speed up development exponentially by designing your UI/Presentation layer first and generating all corresponding domain and data layer classes with a single command.

#### Step 1: Annotate your Presentation Method
Import `package:flutter_archkit/flutter_archkit.dart` and annotate event handlers or functions in your BLoC, Cubit, Riverpod Notifier, ViewModel, or Controller:

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
    String? units,
  }) async {
    // Business logic...
  }
}
```

#### Step 2: Run Code Generator
```bash
# Run code generation on target feature
archkit generate --path lib/features/weather

# Or use shortcuts
archkit g -p lib/features/weather

# Preview changes without modifying files
archkit g -p lib/features/weather --dry-run
```

#### Automated Generation Pipeline:
```mermaid
graph LR
    A["@Archkit Annotation in Presentation"] --> B["UseCase (Domain)"]
    B --> C["Repository Interface (Domain)"]
    C --> D["Repository Implementation (Data)"]
    D --> E["Remote DataSource Contract (Data)"]
    E --> F["Remote DataSource Impl (Dio Client)"]
```

- **`domain/usecases/fetch_weather_usecase.dart`**: Generates typed UseCase with matching parameters (`city`, `units`).
- **`domain/repositories/weather_repository.dart`**: Injects contract method returning `Future<ApiResponse<WeatherModel>>`.
- **`data/repositories/weather_repository_impl.dart`**: Implements method delegating to the remote data source.
- **`data/data_sources/weather_remote_datasource.dart`**: Declares data source method.
- **`data/data_sources/weather_remote_datasource_impl.dart`**: Generates concrete Dio network call with `/weather` endpoint and `GET` method.

---

### 6. Multi-Flavor Configuration (`setup_flavor`)

Easily configure enterprise-grade multi-environment setups (e.g. `dev`, `staging`, `prod`) for both Android and iOS in seconds.

#### Step 1: Initialize `flavor.yaml`
```bash
dart run flutter_archkit:setup_flavor --init
```

Customize `flavor.yaml` in your project root:

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

#### Step 2: Validate Configuration
```bash
dart run flutter_archkit:setup_flavor --validate
```

#### Step 3: Run the Flavor Generator
```bash
dart run flutter_archkit:setup_flavor
```

#### Automated Native & IDE Setup:
- **Android**: Configures `productFlavors` and `applicationId` in `android/app/flavor.gradle.kts` and links with `build.gradle.kts`.
- **iOS**: 
  - Generates `.xcconfig` build configuration files (`Debug-dev.xcconfig`, `Release-prod.xcconfig`, etc.).
  - Configures CocoaPods target integrations (`#include? "Pods-Runner.<mode>-<flavor>.xcconfig"`).
  - Generates shared `.xcscheme` scheme definitions in `Runner.xcodeproj/xcshareddata/xcschemes/`.
  - Patches `Info.plist` with dynamic `CFBundleDisplayName` and `BaseURL`.
  - Updates Xcode `project.pbxproj` and upgrades `IPHONEOS_DEPLOYMENT_TARGET = 16.0`.
- **Dart ServerConfig**: Generates strongly-typed `lib/core/config/server_config.dart`.
- **IDE Run Configurations**:
  - Writes `.vscode/launch.json` for 1-click debugging in VS Code.
  - Generates `.run/<flavor>.run.xml` for Android Studio / IntelliJ IDEA.

---

## 📁 Directory Structures

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
│   ├── entities/
│   │   └── auth_entity.dart
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
├── app_routes.dart           # Strongly-typed route name constants
├── route_functions.dart      # Global navigation utilities (push, pop, clearAndGo)
└── bottom_shell_route.dart   # StatefulShellRoute bottom navigation scaffold (Go Router)
```

### Network Layer Structure (`lib/core/`)
```text
lib/core/
├── network/
│   ├── api_exception.dart             # Typed HTTP & socket exception handling
│   ├── api_interface.dart             # Abstract API client contract
│   ├── dio.dart                       # Configured Dio HTTP factory instance
│   ├── dio_network.dart               # Concrete Dio HTTP request dispatcher
│   ├── dio_services.dart              # Base network service class
│   └── interceptors/
│       ├── api_interceptor.dart       # Bearer token & authorization header interceptor
│       └── logging.dart               # Colored request/response logger interceptor
└── util/
    ├── api_response.dart              # Generic ApiResponse<T> state wrapper
    └── typedefs.dart                  # Utility Dart typedefs (JSON, Callbacks)
```

### MVVM Architecture (`lib/`)
```text
lib/
├── models/
│   └── user_model.dart
├── services/
│   └── user_service.dart
├── viewmodels/
│   └── user_viewmodel.dart (or user_provider.dart / user_bloc.dart)
└── views/
    └── user_view.dart
```

### MVC Architecture (`lib/`)
```text
lib/
├── models/
│   └── user_model.dart
├── controllers/
│   └── user_controller.dart
└── views/
    └── user_view.dart
```

---

## 🌟 Example Application

A full reference application demonstrating Clean Architecture, MVVM, MVC, Network Layer, Routing, and Flavor configurations is available in the [`example/`](example/) directory.

To run the example app:
```bash
cd example
flutter pub get
flutter run
```

---

## 🤝 Contributing & Issues

Contributions, feature suggestions, and bug reports are welcome!
- 🐛 **Report Issues**: [GitHub Issue Tracker](https://github.com/Sangramdeve/flutter_archkit/issues)
- 💡 **Source Code**: [GitHub Repository](https://github.com/Sangramdeve/flutter_archkit)

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
