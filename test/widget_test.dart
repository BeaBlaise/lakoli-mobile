import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lakoli_mobile/app.dart';
import 'package:lakoli_mobile/core/providers/core_providers.dart';

import 'fakes/fake_secure_storage_service.dart';

void main() {
  testWidgets("un visiteur sans session est redirigé vers l'écran de connexion", (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secureStorageServiceProvider.overrideWithValue(FakeSecureStorageService()),
        ],
        child: const LakoliApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Connexion'), findsOneWidget);
  });
}
