/// Annotation used to mark Presentation methods or BLoC/Controller event handlers
/// for automatic Clean Architecture code generation across Domain and Data layers using `archkit generate`.
class Archkit {
  /// Optional API endpoint path (e.g. `'/weather'` or `'/users'`)
  final String? endpoint;

  /// Optional HTTP method (e.g. `'GET'`, `'POST'`, `'PUT'`, `'DELETE'`)
  final String? method;

  /// Optional inner return type T for `ApiResponse<T>` (e.g. `User` or `'User'`)
  final dynamic returnType;

  const Archkit({
    this.endpoint,
    this.method,
    this.returnType,
  });
}

/// Lowercase constant instance enabling `@archkit` annotation syntax
const archkit = Archkit();
