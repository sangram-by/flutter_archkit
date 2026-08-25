# 🛣️ Route Systems Guide

`flutter_archkit` includes a powerful routing scaffolding engine (`archkit route`) supporting 5 primary Flutter routing systems.

---

## ⚡ Scaffolding Command

```bash
# Interactive setup wizard
archkit route

# Aliases
archkit r
archkit setup-route

# Non-interactive setups using flags
archkit route --type "Go Router" --shell
archkit route --type "Auto Route"
archkit route --type "GetX Routing"
```

Running `archkit route`:
1. Generates complete router files in `lib/core/router/`.
2. Automatically updates `pubspec.yaml` with the required routing packages.
3. Saves configuration in `.metadata` for seamless future feature code generation.

---

## 🧩 Supported Router Engines

### 1. Go Router (`go_router`)
Includes optional support for **Bottom Navigation Shells** (`StatefulShellRoute`).

#### Directory Structure (`lib/core/router/`)
- `app_router.dart`: `GoRouter` instance with route paths, error handlers, and shell routes.
- `app_routes.dart`: Strongly typed route path constants (`AppRoutes.home`, `AppRoutes.profile`).
- `route_functions.dart`: Convenience helper functions (`context.pushNamed()`, `context.go()`).
- `bottom_shell_route.dart`: `StatefulShellRoute` with `ScaffoldWithNavBar` implementation.

#### Example `app_router.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
  ],
);
```

---

### 2. Auto Route (`auto_route`)
Type-safe code-generated navigation engine.

#### Generated Files:
- `lib/core/router/app_router.dart`:
```dart
import 'package:auto_route/auto_route.dart';
import 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends $AppRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: HomeRoute.page, initial: true),
      ];
}
```

---

### 3. GetX Routing (`get`)
Lightweight route management.

#### Generated Files:
- `lib/core/router/app_pages.dart`:
```dart
import 'package:get/get.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
    ),
  ];
}
```

---

### 4. Navigator 1.0 (Imperative)
Classic Flutter named route generation with `RouteGenerator` and `MaterialPageRoute`.

---

### 5. Navigator 2.0 (Declarative)
Custom `RouterDelegate` and `RouteInformationParser` scaffolding.
