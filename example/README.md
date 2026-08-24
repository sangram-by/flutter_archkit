<p align="center">
  <img src="https://raw.githubusercontent.com/Sangramdeve/flutter_archkit/master/cover.svg" alt="Flutter ArchKit Logo" width="100%" />
</p>

# Flutter ArchKit Architecture Example App

This example application demonstrates how to structure and use **Clean Architecture**, **MVVM Architecture**, and **MVC Architecture** using [`flutter_archkit`](https://pub.dev/packages/flutter_archkit).

---

## 🌟 Interactive Architecture Demos

The example app includes live interactive demonstrations and directory structures for each architectural pattern supported by `flutter_archkit`:

### 1. 🏗️ Clean Architecture (`lib/architectures/clean/`)
Strict separation of concerns into four isolated layers:
- **`domain/`**: Pure Dart Entities (`UserEntity`), Repository Interfaces (`UserRepository`), and Usecases (`FetchUserProfileUseCase`). Independent of UI and external libraries.
- **`data/`**: Data Source Contracts (`UserRemoteDataSource`), Data Source Implementations (`UserRemoteDataSourceImpl`), Models (`UserModel`), and Repository Implementations (`UserRepositoryImpl`).
- **`presentation/`**: Pages (`CleanArchitecturePage`) and State Management (`CleanUserNotifier` / Bloc / Cubit / Riverpod).
- **`di/`**: Dependency Injection wiring (`CleanUserDI` / GetIt / Injectable).

### 2. ⚡ MVVM Architecture (`lib/architectures/mvvm/`)
Model-View-ViewModel with reactive data binding:
- **`models/`**: Data models (`TaskModel`).
- **`services/`**: API / Local Storage Services (`TaskService`).
- **`viewmodels/`**: Reactive ViewModel holding state and commands (`TaskViewModel`).
- **`views/`**: Flutter UI Widgets (`MvvmArchitecturePage`).

### 3. 📊 MVC Architecture (`lib/architectures/mvc/`)
Classic Model-View-Controller pattern:
- **`models/`**: Data structure state (`AnalyticsModel`).
- **`controllers/`**: Controller handling user input actions and business logic (`AnalyticsController`).
- **`views/`**: Flutter UI Widgets (`MvcArchitecturePage`).

---

## 🚀 Scaffolding Architectures with CLI (`archkit`)

Generate any of these architecture patterns in your own Flutter project using the `flutter_archkit` CLI:

### Scaffolding a New Project
```bash
# Clean Architecture with Bloc
archkit create my_app --architecture Clean --state-management Bloc

# MVVM Architecture with Provider
archkit create my_app --architecture MVVM --state-management Provider

# MVC Architecture with GetX
archkit create my_app --architecture MVC --state-management GetX
```

### Scaffolding Feature Modules
```bash
# Scaffolds feature matching your project's saved architecture
archkit feature user_profile
```

---

## ⚙️ Multi-Flavor Configuration & Setup

This example project includes a pre-configured `flavor.yaml`:

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

To run the flavor generator and configure native Android, iOS, IDE configurations, and `ServerConfig`:

```bash
dart run flutter_archkit:setup_flavor
```

---

## 🏃 Running the Example App

```bash
# Fetch dependencies
flutter pub get

# Run application
flutter run
```
