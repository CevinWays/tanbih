import 'package:dio/dio.dart';

import '../../error/dio_failure_mapper.dart';

/// Attaches the mapped `Failure` to the exception so data sources never have
/// to interpret Dio's error types themselves.
///
/// The `Failure` is carried in `DioException.error`; data sources read it and
/// return it, keeping `DioException` from leaking past the data layer.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err.copyWith(error: mapDioExceptionToFailure(err)));
  }
}
