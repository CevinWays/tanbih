import 'package:flutter_test/flutter_test.dart';
import 'package:tanbih/core/error/failures.dart';

void main() {
  group('ServerFailure', () {
    test('classifies 4xx as a client error', () {
      const failure = ServerFailure(statusCode: 404);
      expect(failure.isClientError, isTrue);
      expect(failure.isServerError, isFalse);
    });

    test('classifies 5xx as a server error', () {
      const failure = ServerFailure(statusCode: 503);
      expect(failure.isServerError, isTrue);
      expect(failure.isClientError, isFalse);
    });

    test('a missing status code is neither', () {
      const failure = ServerFailure();
      expect(failure.isClientError, isFalse);
      expect(failure.isServerError, isFalse);
    });
  });

  group('equality', () {
    test('failures of the same type and payload are equal', () {
      expect(
        const CalculationFailure(message: 'x'),
        const CalculationFailure(message: 'x'),
      );
      expect(
        const ServerFailure(message: 'x', statusCode: 500),
        isNot(const ServerFailure(message: 'x', statusCode: 502)),
      );
    });

    test('flags participate in equality', () {
      expect(
        const PermissionFailure(isPermanentlyDenied: true),
        isNot(const PermissionFailure()),
      );
      expect(
        const SilentModeFailure(policyAccessDenied: true),
        isNot(const SilentModeFailure()),
      );
      expect(
        const QiblaFailure(sensorUnavailable: true),
        isNot(const QiblaFailure()),
      );
    });
  });
}
