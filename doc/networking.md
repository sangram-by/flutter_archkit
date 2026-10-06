# 🌐 Production Network Layer Guide

`flutter_archkit` generates a battle-tested Dio network client architecture for Flutter applications.

---

## ⚡ Scaffolding Command

```bash
# Generate network layer in default project (lib/core/)
archkit network

# Aliases
archkit n
archkit net

# Specify target project path or force overwrite existing files
archkit network --path ./my_project --override
```

---

## 📁 Scaffolded File Structure

```text
lib/core/
├── network/
│   ├── api_exception.dart             # Custom HTTP & socket exception parsing
│   ├── api_interface.dart             # Abstract HTTP client interface
│   ├── dio.dart                       # Configured Dio factory instance
│   ├── dio_network.dart               # Concrete Dio request dispatcher with ApiResponse conversion
│   ├── dio_services.dart              # Base network service container
│   └── interceptors/
│       ├── api_interceptor.dart       # Bearer token & authorization header injector
│       └── logging.dart               # Colored request/response logger interceptor
└── util/
    ├── api_response.dart              # Generic ApiResponse<T> wrapper (Success, Error, Loading)
    └── typedefs.dart                  # Core JSON and callback typedefs
```

---

## 🧱 Key Components

### 1. Standardized `ApiResponse<T>` State Wrapper
`lib/core/util/api_response.dart`:
```dart
class ApiResponse<T> {
  final T? data;
  final String? message;
  final int? statusCode;
  final bool isSuccess;

  ApiResponse.success(this.data, {this.statusCode})
      : message = null,
        isSuccess = true;

  ApiResponse.error(this.message, {this.statusCode})
      : data = null,
        isSuccess = false;
}
```

---

### 2. Concrete `DioNetwork` Dispatcher
`lib/core/network/dio_network.dart`:
```dart
import 'package:dio/dio.dart';
import '../util/api_response.dart';

class DioNetwork {
  final Dio _dio = DioClient().dio;

  Future<ApiResponse<T>> get<T>({
    required String endpoint,
    Map<String, dynamic>? queryParams,
    T Function(dynamic response)? converter,
  }) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParams);
      final data = converter != null ? converter(response.data) : response.data as T;
      return ApiResponse.success(data, statusCode: response.statusCode);
    } on DioException catch (e) {
      return ApiResponse.error(e.message, statusCode: e.response?.statusCode);
    }
  }

  Future<ApiResponse<T>> post<T>({
    required String endpoint,
    dynamic data,
    T Function(dynamic response)? converter,
  }) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      final result = converter != null ? converter(response.data) : response.data as T;
      return ApiResponse.success(result, statusCode: response.statusCode);
    } on DioException catch (e) {
      return ApiResponse.error(e.message, statusCode: e.response?.statusCode);
    }
  }
}
```

---

### 3. Automatic Bearer Token Interceptor
`lib/core/network/interceptors/api_interceptor.dart`:
Automatically injects authorization bearer tokens into request headers and handles 401 unauthorized token refreshes.
