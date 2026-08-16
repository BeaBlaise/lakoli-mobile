/// Configuration d'environnement, résolue à la compilation via `--dart-define`.
///
/// Aucune valeur sensible n'est codée en dur ici — l'URL de base varie selon la cible
/// (émulateur Android, appareil physique, production) et doit toujours être fournie
/// explicitement :
///
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.42:8000/api/v1
///
/// `10.0.2.2` est l'alias que l'émulateur Android utilise pour joindre `127.0.0.1` sur la
/// machine hôte — `127.0.0.1` depuis l'émulateur pointerait vers l'émulateur lui-même, pas
/// vers le serveur Laravel de développement. Un appareil physique doit utiliser l'IP réelle
/// de la machine sur le réseau local.
class Env {
  const Env._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );

  /// Hôte du serveur Reverb (WebSocket), sans schéma ni port — voir core/realtime/
  /// reverb_service.dart (PusherChannelsOptions.fromHost les prend séparément).
  static const String reverbHost = String.fromEnvironment(
    'REVERB_HOST',
    defaultValue: '10.0.2.2',
  );

  static const int reverbPort = int.fromEnvironment(
    'REVERB_PORT',
    defaultValue: 8080,
  );

  static const bool reverbUseTls = bool.fromEnvironment(
    'REVERB_USE_TLS',
    defaultValue: false,
  );

  static const String reverbAppKey = String.fromEnvironment(
    'REVERB_APP_KEY',
    defaultValue: '',
  );

  /// Vide par défaut : Sentry n'est initialisé (voir main.dart) que si un vrai DSN est fourni,
  /// pour que l'app reste utilisable en développement sans compte Sentry configuré.
  ///
  ///   flutter run --dart-define=SENTRY_DSN=https://xxxx@oyyyy.ingest.sentry.io/zzzz
  static const String sentryDsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');

  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
}
