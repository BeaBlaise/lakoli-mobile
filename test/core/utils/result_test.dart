import 'package:flutter_test/flutter_test.dart';
import 'package:lakoli_mobile/core/errors/app_exception.dart';
import 'package:lakoli_mobile/core/utils/result.dart';

void main() {
  group('Result', () {
    test('success exécute la branche success de when()', () {
      const result = Result<int>.success(42);

      final output = result.when(success: (data) => 'ok:$data', failure: (e) => 'erreur:$e');

      expect(output, 'ok:42');
      expect(result.isSuccess, isTrue);
    });

    test('failure exécute la branche failure de when()', () {
      const result = Result<int>.failure(NetworkException());

      final output = result.when(success: (data) => 'ok:$data', failure: (e) => 'erreur:${e.message}');

      expect(output, contains('erreur:'));
      expect(result.isSuccess, isFalse);
    });
  });
}
