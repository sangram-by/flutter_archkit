class NetworkTemplates {
  static String apiResponseTemplate() {
    return '''
import 'package:flutter/material.dart';

enum Status { empty, loading, success, error }

class ApiResponse<T> {
  final Status status;
  final T? data;
  final ErrorResponse? message;

  ApiResponse._({required this.status, this.data, this.message});

  factory ApiResponse.empty() => ApiResponse._(status: Status.empty);

  factory ApiResponse.loading() => ApiResponse._(status: Status.loading);

  factory ApiResponse.success(T data) =>
      ApiResponse._(status: Status.success, data: data);

  factory ApiResponse.error(ErrorResponse message) =>
      ApiResponse._(status: Status.error, message: message);

  bool get isEmpty => status == Status.empty;
  bool get isLoading => status == Status.loading;
  bool get isSuccess => status == Status.success;
  bool get isError => status == Status.error;
}

extension ApiResponseWidgetX<T> on ApiResponse<T> {
  Widget when({
    Widget Function()? empty,
    Widget Function()? loading,
    required Widget Function(T data) success,
    Widget Function(ErrorResponse error)? error,
  }) {
    switch (status) {
      case Status.empty:
        return empty?.call() ?? const Text('No data');
      case Status.loading:
        return loading?.call() ??
            const Center(child: CircularProgressIndicator());
      case Status.success:
        return success(data as T);
      case Status.error:
        return error?.call(message!) ??
            Text('Error: \${message?.message ?? 'Unknown error'}');
    }
  }
}

extension ApiResponseHandlerX<T> on ApiResponse<T> {
  void whenStatus({
    void Function()? empty,
    void Function()? loading,
    void Function(T data)? success,
    void Function(ErrorResponse error)? error,
  }) {
    switch (status) {
      case Status.empty:
        empty?.call();
        break;
      case Status.loading:
        loading?.call();
        break;
      case Status.success:
        if (data != null) success?.call(data as T);
        break;
      case Status.error:
        if (message != null) error?.call(message!);
        break;
    }
  }
}

class ErrorResponse {
  final int code;
  final String message;
  final dynamic data;

  ErrorResponse({required this.code, required this.message, this.data});

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      code: json['code'] ?? 0,
      message: json['message'] ?? 'Unknown error',
      data: json['data'],
    );
  }
}
''';
  }

  static String typedefsTemplate() {
    return '''
typedef JSON = Map<String, dynamic>;
''';
  }

  static String apiExceptionTemplate() {
    return '''
import 'dart:io';
import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic errorData;

  ApiException({required this.message, this.statusCode, this.errorData});

  factory ApiException.fromDioError(DioException e) {
    String errorMsg = 'Unexpected error occurred';
    dynamic errorBody;

    // Connection / timeout handling
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return ApiException(
        message: "Connection timed out. Please try again.",
        statusCode: 408,
      );
    }

    if (e.type == DioExceptionType.connectionError ||
        e.error is SocketException) {
      return ApiException(
        message: "No internet connection. Please check your network.",
        statusCode: 503,
      );
    }

    if (e.type == DioExceptionType.cancel) {
      return ApiException(
        message: "Request was cancelled.",
        statusCode: 499,
      );
    }

    // Server response error
    if (e.response != null) {
      final status = e.response?.statusCode;
      errorBody = e.response?.data;

      if (errorBody is Map && errorBody['message'] != null) {
        errorMsg = errorBody['message'];
      } else if (errorBody is String) {
        errorMsg = errorBody;
      } else {
        errorMsg = "Something went wrong. Please try again.";
      }

      return ApiException(
        message: errorMsg,
        statusCode: status,
        errorData: errorBody,
      );
    }

    return ApiException(message: e.message ?? errorMsg, statusCode: 500);
  }
}
''';
  }

  static String apiInterfaceTemplate(String packageName) {
    return '''
import 'package:dio/dio.dart';
import 'package:$packageName/core/util/api_response.dart';
import 'package:$packageName/core/util/typedefs.dart';

abstract class ApiInterface {
  const ApiInterface();

  Future<List<T>> getCollection<T>({
    required String endpoint,
    JSON? queryParams,
    CancelToken? cancelToken,
    required T Function(JSON responseBody) converter,
  });

  Future<ApiResponse<T>> get<T>({
    required String endpoint,
    JSON? queryParams,
    CancelToken? cancelToken,
    required T Function(JSON responseBody) converter,
  });

  Future<ApiResponse<T>> post<T>({
    required String endpoint,
    required JSON data,
    CancelToken? cancelToken,
    required T Function(JSON response) converter,
  });

  Future<ApiResponse<T>> postFormData<T>({
    required String endpoint,
    required JSON data,
    List<MapEntry<String, MultipartFile>>? files,
    CancelToken? cancelToken,
    required T Function(JSON response) converter,
  });

  Future<ApiResponse<T>> patch<T>({
    required String endpoint,
    required JSON data,
    CancelToken? cancelToken,
    required T Function(JSON response) converter,
  });

  Future<ApiResponse<T>> put<T>({
    required String endpoint,
    required JSON data,
    CancelToken? cancelToken,
    required T Function(JSON response) converter,
  });

  Future<ApiResponse<T>> delete<T>({
    required String endpoint,
    JSON? data,
    CancelToken? cancelToken,
    required T Function(JSON response) converter,
  });

  void cancelRequests({CancelToken? cancelToken});
}
''';
  }

  static String dioServicesTemplate(String packageName) {
    return '''
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:$packageName/core/util/api_response.dart';
import 'package:$packageName/core/util/typedefs.dart';

class DioService {
  final Dio _dio;

  Dio get dio => _dio;

  final CancelToken _cancelToken;

  DioService({required Dio dioClient, HttpClientAdapter? httpClientAdapter})
      : _dio = dioClient,
        _cancelToken = CancelToken() {
    if (httpClientAdapter != null) _dio.httpClientAdapter = httpClientAdapter;
  }

  void cancelRequests({CancelToken? cancelToken}) {
    if (cancelToken == null) {
      _cancelToken.cancel('Cancelled');
    } else {
      cancelToken.cancel();
    }
  }

  Future<ApiResponse<T>> get<T>({
    required String endpoint,
    JSON? queryParams,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get<T>(
      endpoint,
      queryParameters: queryParams,
      options: options,
      cancelToken: cancelToken ?? _cancelToken,
    );
    return ApiResponse.success(response.data as T);
  }

  Future<ApiResponse<T>> post<T>({
    required String endpoint,
    JSON? data,
    JSON? queryParams,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.post<JSON>(
      endpoint,
      data: data,
      queryParameters: queryParams,
      options: options,
      cancelToken: cancelToken ?? _cancelToken,
    );
    return ApiResponse.success(response.data as T);
  }

  Future<ApiResponse<T>> multipart<T>({
    required String endpoint,
    FormData? data,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
  }) async {
    final response = await _dio.post<JSON>(
      endpoint,
      data: data,
      options: options,
      cancelToken: cancelToken ?? _cancelToken,
      onSendProgress: onSendProgress,
    );
    return ApiResponse.success(response.data as T);
  }

  Future<ApiResponse<T>> patch<T>({
    required String endpoint,
    JSON? data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.patch<JSON>(
      endpoint,
      data: data,
      options: options,
      cancelToken: cancelToken ?? _cancelToken,
    );
    return ApiResponse.success(response.data as T);
  }

  Future<ApiResponse<T>> put<T>({
    required String endpoint,
    JSON? data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.put<JSON>(
      endpoint,
      data: data,
      options: options,
      cancelToken: cancelToken ?? _cancelToken,
    );
    return ApiResponse.success(response.data as T);
  }

  Future<ApiResponse<T>> delete<T>({
    required String endpoint,
    JSON? data,
    Options? options,
    JSON? queryParams,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.delete<JSON>(
      endpoint,
      data: data,
      queryParameters: queryParams,
      options: options,
      cancelToken: cancelToken ?? _cancelToken,
    );
    return ApiResponse.success(response.data as T);
  }
}
''';
  }

  static String dioNetworkTemplate(String packageName) {
    return '''
import 'package:dio/dio.dart';
import 'package:$packageName/core/util/api_response.dart';
import 'package:$packageName/core/util/typedefs.dart';
import 'api_exception.dart';
import 'api_interface.dart';
import 'dio.dart';
import 'dio_services.dart';

class DioNetwork implements ApiInterface {
    static final DioNetwork _instance = DioNetwork._internal();

  factory DioNetwork() {
    return _instance;
  }

  DioNetwork._internal();

  final DioService _dioService = DioService(dioClient: getDio());

  @override
  void cancelRequests({CancelToken? cancelToken}) {
    _dioService.cancelRequests(cancelToken: cancelToken);
  }

  @override
  Future<List<T>> getCollection<T>({
    required String endpoint,
    JSON? queryParams,
    CancelToken? cancelToken,
    required T Function(JSON responseBody) converter,
  }) async {
    try {
      final response = await _dioService.get<List<dynamic>>(
        endpoint: endpoint,
        queryParams: queryParams,
        cancelToken: cancelToken,
      );
      final rawList = response.data ?? [];
      return rawList.map((e) => converter(e as JSON)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<ApiResponse<T>> get<T>({
    required String endpoint,
    JSON? queryParams,
    CancelToken? cancelToken,
    required T Function(JSON responseBody) converter,
  }) async {
    try {
      final response = await _dioService.get<JSON>(
        endpoint: endpoint,
        queryParams: queryParams,
        cancelToken: cancelToken,
      );
      return ApiResponse.success(converter(response.data!));
    } on DioException catch (e) {
      final exception = ApiException.fromDioError(e);
      return ApiResponse.error(
        ErrorResponse(
          code: exception.statusCode ?? 500,
          message: exception.message,
          data: exception.errorData,
        ),
      );
    }
  }

  @override
  Future<ApiResponse<T>> post<T>({
    required String endpoint,
    required JSON data,
    CancelToken? cancelToken,
    required T Function(JSON response) converter,
  }) async {
    try {
      final response = await _dioService.post<JSON>(
        endpoint: endpoint,
        data: data,
        cancelToken: cancelToken,
      );
      return ApiResponse.success(converter(response.data!));
    } on DioException catch (e) {
      final exception = ApiException.fromDioError(e);
      return ApiResponse.error(
        ErrorResponse(
          code: exception.statusCode ?? 500,
          message: exception.message,
          data: exception.errorData,
        ),
      );
    }
  }

  @override
  Future<ApiResponse<T>> postFormData<T>({
    required String endpoint,
    required JSON data,
    List<MapEntry<String, MultipartFile>>? files,
    CancelToken? cancelToken,
    required T Function(JSON response) converter,
  }) async {
    try {
      final formData = FormData.fromMap(data);
      if (files != null && files.isNotEmpty) {
        formData.files.addAll(files);
      }
      final response = await _dioService.multipart<JSON>(
        endpoint: endpoint,
        data: formData,
        cancelToken: cancelToken,
      );
      return ApiResponse.success(converter(response.data!));
    } on DioException catch (e) {
      final exception = ApiException.fromDioError(e);
      return ApiResponse.error(
        ErrorResponse(
          code: exception.statusCode ?? 500,
          message: exception.message,
          data: exception.errorData,
        ),
      );
    }
  }

  @override
  Future<ApiResponse<T>> patch<T>({
    required String endpoint,
    required JSON data,
    CancelToken? cancelToken,
    required T Function(JSON response) converter,
  }) async {
    try {
      final response = await _dioService.patch<JSON>(
        endpoint: endpoint,
        data: data,
        cancelToken: cancelToken,
      );
      return ApiResponse.success(converter(response.data!));
    } on DioException catch (e) {
      final exception = ApiException.fromDioError(e);
      return ApiResponse.error(
        ErrorResponse(
          code: exception.statusCode ?? 500,
          message: exception.message,
          data: exception.errorData,
        ),
      );
    }
  }

  @override
  Future<ApiResponse<T>> put<T>({
    required String endpoint,
    required JSON data,
    CancelToken? cancelToken,
    required T Function(JSON response) converter,
  }) async {
    try {
      final response = await _dioService.put<JSON>(
        endpoint: endpoint,
        data: data,
        cancelToken: cancelToken,
      );
      return ApiResponse.success(converter(response.data!));
    } on DioException catch (e) {
      final exception = ApiException.fromDioError(e);
      return ApiResponse.error(
        ErrorResponse(
          code: exception.statusCode ?? 500,
          message: exception.message,
          data: exception.errorData,
        ),
      );
    }
  }

  @override
  Future<ApiResponse<T>> delete<T>({
    required String endpoint,
    JSON? data,
    CancelToken? cancelToken,
    required T Function(JSON response) converter,
  }) async {
    try {
      final response = await _dioService.delete<JSON>(
        endpoint: endpoint,
        data: data,
        cancelToken: cancelToken,
      );
      return ApiResponse.success(converter(response.data!));
    } on DioException catch (e) {
      final exception = ApiException.fromDioError(e);
      return ApiResponse.error(
        ErrorResponse(
          code: exception.statusCode ?? 500,
          message: exception.message,
          data: exception.errorData,
        ),
      );
    }
  }
}
''';
  }

  static String dioClientTemplate(String packageName) {
    return '''
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:$packageName/core/constants/api_urls.dart';
import 'package:$packageName/core/network/interceptors/api_interceptor.dart';
import 'package:$packageName/core/network/interceptors/logging.dart';

Dio getDio({String? baseUrl}) {
  Dio dio = Dio(
    BaseOptions(
      baseUrl: baseUrl ?? ApiUrls.baseUrl,
      connectTimeout: const Duration(seconds: 90),
      receiveTimeout: const Duration(seconds: 90),
      responseType: ResponseType.json,
    ),
  )..interceptors.addAll([
      CustomInterceptors(),
    ]);

  if (kDebugMode) {
    dio.interceptors.add(Logging());
  }

  return dio;
}
''';
  }

  static String apiInterceptorTemplate() {
    return '''
import 'package:dio/dio.dart';

class CustomInterceptors extends Interceptor {
  final String? refreshTokenUrl;

  CustomInterceptors({this.refreshTokenUrl});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add auth tokens or custom headers here
    // options.headers['Authorization'] = 'Bearer \$token';
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle status 401 token refresh or global error interceptors here
    super.onError(err, handler);
  }
}
''';
  }

  static String loggingInterceptorTemplate() {
    return '''
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class Logging extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      log('REQUEST[\${options.method}] => PATH: \${options.path}');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      log('RESPONSE[\${response.statusCode}] => PATH: \${response.requestOptions.path}');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      log('ERROR[\${err.response?.statusCode}] => PATH: \${err.requestOptions.path}');
    }
    super.onError(err, handler);
  }
}
''';
  }

  static String apiUrlsTemplate() {
    return '''
class ApiUrls {
  // TODO: Add your base URL implementation here
  static const String baseUrl = 'https://api.example.com';
}
''';
  }
}
