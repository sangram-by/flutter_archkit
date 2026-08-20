## 0.2.1

* **Bug Fixes & Generator Enhancements (`archkit generate`)**:
  * Fixed regex method detection to parse Riverpod providers, top-level variable declarations, and `StateNotifier` / `Notifier` class methods.
  * Added automatic injection of `final DioNetwork api = DioNetwork();` and required Dio imports into `RemoteDataSourceImpl` classes when missing during code generation.
  * Updated `CleanRiverpodTemplate` to generate structured `StateNotifier` classes (`StateNotifier<AsyncValue<String>>`) with `StateNotifierProvider`, ensuring state management consistency across Bloc, Cubit, GetX, Provider, and Riverpod.
  * Added `--path` / `-p` option to `archkit feature` command to allow target project directory specification.
  * Preserved clean architecture method signature forwarding for positional and required named parameters across all tiers.

## 0.2.0

* **`@Archkit` Presentation-to-Data Code Generator (`archkit generate` / `archkit g` / `archkit gen` / `archkit -g`)**:
  * Added automated Clean Architecture cascading method generator across Domain and Data layers:
    * Automatically generates UseCases (`lib/features/<name>/domain/usecases/`), Repositories (`domain/repositories/` & `data/repositories/`), and DataSources (`data/data_sources/`) from `@Archkit` or `@archkit` annotated methods in presentation controllers, BLoCs, Cubits, Riverpod providers, or ViewModels.
    * Added cascading method generation for MVVM (`lib/services/`) and MVC (`lib/controllers/` & `lib/providers/`) architectures.
  * Added `@Archkit` annotation (`package:flutter_archkit/flutter_archkit.dart`) with metadata parameters:
    * `endpoint`: Target API endpoint path (e.g. `'/weather'`, `'/users'`).
    * `method`: HTTP request method (`'GET'`, `'POST'`, `'PUT'`, `'DELETE'`, `'PATCH'`).
    * `returnType`: Inner generic type for `ApiResponse<T>` (e.g. `User`, `List<Product>`).
  * Intelligent signature forwarding for method arguments (positional and required named parameters) across all architectural tiers.
  * Added `--dry-run` flag to preview proposed method injections and target files without modifying disk.
  * Added target path selector via `--path` / `-p` option, positional arguments, or interactive CLI prompt.

## 0.1.0

* **Route Setup Generator (`archkit route` / `archkit r` / `archkit setup-route`)**:
  * Added automated routing scaffolding supporting 5 router engines: Navigator 1.0, Navigator 2.0, Go Router, Auto Route, and GetX Routing.
  * Added support for `StatefulShellRoute` (bottom navigation shell) for Go Router.
  * Automated `pubspec.yaml` dependency injection (`go_router`, `auto_route`, `get`, etc.) and `.metadata` configuration persistence.
* **Network Generator (`archkit network` / `archkit n` / `archkit net`)**:
  * Added production-ready Dio network layer generator (`lib/core/network/` & `lib/core/util/`).
  * Scaffolds `ApiResponse<T>` generic wrapper, custom `ApiException`, typed `ApiInterface`, `DioServices`, `DioNetwork`, custom interceptors (`ApiInterceptor`, `LoggingInterceptor`), and `typedefs.dart`.
  * Automatically adds `dio: ^5.4.3` to project `pubspec.yaml`.

## 0.0.3

* Updated `flavor.yaml` schema with structured `app.name`, `app.baseUrl`, `android.applicationId`, and `ios.bundleId` definitions.
* Improved Android flavor generator (`android/app/flavor.gradle.kts`) with explicit `applicationId` and idempotency block replacements.
* Fixed iOS Xcode project patcher (`project.pbxproj`) to inherit full target `buildSettings` (`INFOPLIST_FILE`, `SWIFT_VERSION`, `PRODUCT_BUNDLE_IDENTIFIER`, bridging headers) across all flavor build configurations.
* Added auto-upgrade for `IPHONEOS_DEPLOYMENT_TARGET = 16.0` in `project.pbxproj`.
* Added CocoaPods target xcconfig inclusions (`Pods-Runner.<config>-<flavor>.xcconfig` and `Pods-Runner.<mode>.xcconfig`).
* Added FVM fallback support in `ProcessService` for `flutter create` and `pub get`.
* Fixed runtime environment switch logic bug in generated `lib/core/config/server_config.dart`.
* Added Android Studio / IntelliJ IDEA 1-click run configuration generator (`.run/<flavor>.run.xml`).
* Added `--validate` and `--init` flags to `setup_flavor` CLI tool.
* Updated SDK constraint compatibility to `">=3.0.0 <4.0.0"`.

## 0.0.2

* Fixed CLI setup issue and package metadata updates.

## 0.0.1

* Initial release of `flutter_archkit`.
* Interactive project generator (`archkit create`) supporting Clean, MVVM, and MVC architectures.
* Integrated state management templates for Bloc, Cubit, Riverpod, Provider, and GetX.
* Feature module generator (`archkit feature <name>` / `archkit -f <name>`) for dynamic feature scaffolding.
* Automatic project architecture detection via `.metadata` configuration persistence.
* Automated multi-flavor generator for Flutter applications (`setup_flavor`).
