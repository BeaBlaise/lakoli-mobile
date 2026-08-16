import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app.dart';
import 'core/config/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR');

  // DSN vide en développement (voir core/config/env.dart) : l'app doit rester utilisable
  // sans compte Sentry configuré, donc Sentry n'est initialisé que si un vrai DSN est fourni
  // plutôt que d'appeler SentryFlutter.init() inconditionnellement avec un DSN vide.
  if (Env.sentryDsn.isEmpty) {
    runApp(const ProviderScope(child: LakoliApp()));
    return;
  }

  await SentryFlutter.init(
    (options) {
      options.dsn = Env.sentryDsn;
      options.environment = Env.isProduction ? 'production' : 'development';
      // Le réseau mobile faible est une contrainte produit explicite ici (voir env.dart,
      // ApiClient) — capturer aussi la perf réseau aide à distinguer une vraie régression
      // d'une simple lenteur de connexion sur le terrain.
      options.tracesSampleRate = 0.2;
    },
    appRunner: () => runApp(const ProviderScope(child: LakoliApp())),
  );
}
