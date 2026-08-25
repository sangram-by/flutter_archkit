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
- ⚡ **Feature Modules**: One-command feature generator matching your project's architecture and state management.
- 🧠 **`@Archkit` Code Generation**: Automatically writes cascading UseCases, Repositories, DataSources, and API calls from annotated presentation handlers.
- 🛣️ **Router Infrastructure**: Scaffolds Navigator 1.0/2.0, Go Router (with Bottom Navigation Shells), Auto Route, or GetX Routing.
- 🌐 **Network Layer**: Scaffolds production Dio HTTP client with generic `ApiResponse<T>`, custom `ApiException`, interceptors, and typed contracts.
- 🎯 **Multi-Flavor Environments**: Configures Android Flavors, iOS Schemes & `.xcconfig`, Dart `ServerConfig`, VS Code `launch.json`, and Android Studio run configurations.

---

## 📚 Documentation Guides & Topics

Explore dedicated, in-depth documentation guides for each architecture pattern and feature:

| Topic / Guide | Description |
| :--- | :--- |
| 🏗️ **[Clean Architecture Guide](doc/clean_architecture.md)** | Deep dive into Data, Domain, Presentation, & DI layers with BLoC, Cubit, Riverpod, Provider, & GetX. |
| 🎨 **[MVVM Architecture Guide](doc/mvvm_architecture.md)** | Deep dive into Models, Services, ViewModels, Views, and reactive state management integration. |
| 🏛️ **[MVC Architecture Guide](doc/mvc_architecture.md)** | Deep dive into Models, Controllers, Views, and lightweight action dispatching. |
| 🧠 **[`@Archkit` Code Generator Guide](doc/code_generation.md)** | Complete guide on annotating presentation handlers and cascading methods across domain/data layers. |
| 🛣️ **[Route Systems Guide](doc/routing.md)** | Comprehensive setup for Go Router (with Bottom Nav Shell), Auto Route, GetX Routing, Navigator 1.0/2.0. |
| 🌐 **[Production Network Layer Guide](doc/networking.md)** | Detailed guide for Dio HTTP client, `ApiResponse<T>`, `ApiException`, and interceptors. |
| 🎯 **[Multi-Flavor Setup Guide](doc/multi_flavor.md)** | Complete guide for `archkit flavor`, `flavor.yaml`, Android Gradle, iOS Xcode schemes, & IDE run targets. |

---

## 📑 Table of Contents

- [Documentation Guides & Topics](#-documentation-guides--topics)
- [Features & Architecture Matrix](#-features--architecture-matrix)
- [CLI Command Cheat Sheet](#-cli-command-cheat-sheet)
- [Installation](#-installation)
- [Usage Guide](#-usage-guide)
  - [1. Creating a Project (`archkit create`)](#1-creating-a-project-archkit-create)
  - [2. Scaffolding Feature Modules (`archkit feature`)](#2-scaffolding-feature-modules-archkit-feature)
  - [3. Setting Up Route Systems (`archkit route`)](#3-setting-up-route-systems-archkit-route)
  - [4. Generating Network Layer (`archkit network`)](#4-generating-network-layer-archkit-network)
  - [5. `@Archkit` Code Generation (`archkit generate`)](#5-smart-archkit-code-generation-archkit-generate)
  - [6. Multi-Flavor Configuration (`archkit flavor`)](#6-multi-flavor-configuration-archkit-flavor)
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
| `archkit flavor` | `-fl`, `--flavor` | Configures multi-flavor environments (Android, iOS, Dart, IDEs) | `archkit flavor --init` or `archkit -fl` |

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

---

### 4. Generating Network Layer (`archkit network`)

Scaffold a battle-tested Dio network client architecture in `lib/core/network/` and `lib/core/util/`:

```bash
archkit network
# Or alias
archkit n
```

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

---

### 6. Multi-Flavor Configuration (`archkit flavor`)

Easily configure enterprise-grade multi-environment setups (e.g. `dev`, `staging`, `prod`) for both Android and iOS in seconds.

```bash
# Initialize flavor.yaml template
archkit flavor --init

# Validate syntax
archkit flavor --validate

# Generate Android, iOS, Dart, and IDE flavor files
archkit flavor
```

---

## 📁 Directory Structures

- 🏗️ **Clean Architecture Details**: [doc/clean_architecture.md](doc/clean_architecture.md)
- 🎨 **MVVM Architecture Details**: [doc/mvvm_architecture.md](doc/mvvm_architecture.md)
- 🏛️ **MVC Architecture Details**: [doc/mvc_architecture.md](doc/mvc_architecture.md)

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
