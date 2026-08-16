/// Exceptions typées levées par la couche réseau/données, distinctes des exceptions Dart
/// brutes — la couche présentation ne doit jamais avoir à interpréter un DioException
/// directement, seulement ces types métier.
sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Pas de connexion réseau exploitable (avion, zone blanche, timeout). Distinct de
/// [ServerException] pour permettre un message et une action ("Réessayer") différents
/// à l'écran — le réseau mobile faible est une contrainte produit explicite ici.
final class NetworkException extends AppException {
  const NetworkException([super.message = 'Vérifiez votre connexion internet et réessayez.']);
}

/// Le serveur a répondu, mais avec une erreur (4xx/5xx). [statusCode] permet à l'appelant
/// de distinguer les cas (401 → session expirée, 404 → introuvable, 500 → réessayer).
final class ServerException extends AppException {
  const ServerException(super.message, {required this.statusCode, this.errors});

  final int statusCode;

  /// Erreurs de validation par champ, quand le backend en renvoie (422 Laravel classique :
  /// `{"errors": {"phone": ["..."]}}`) — utile pour afficher l'erreur sous le bon champ
  /// de formulaire plutôt qu'un message générique.
  final Map<String, List<String>>? errors;
}

/// Token absent, expiré ou révoqué — signal dédié pour que la couche présentation puisse
/// rediriger vers l'écran de connexion sans avoir à inspecter un code HTTP.
final class UnauthenticatedException extends AppException {
  const UnauthenticatedException([super.message = 'Votre session a expiré. Reconnectez-vous.']);
}

/// Action refusée par le backend pour une raison de permission (403) — distinct d'un
/// simple UnauthenticatedException : l'utilisateur est bien connecté, mais son rôle actif
/// ne l'autorise pas. Le mobile est un client ; le backend reste l'autorité finale.
final class ForbiddenException extends AppException {
  const ForbiddenException([super.message = "Vous n'êtes pas autorisé à effectuer cette action."]);
}

/// Réponse reçue mais dont la forme ne correspond pas à ce qui était attendu — signale un
/// vrai bug (backend qui a changé de forme, modèle Dart désynchronisé) plutôt qu'un
/// problème utilisateur ; ne doit jamais être silencieusement avalée.
final class UnexpectedResponseException extends AppException {
  const UnexpectedResponseException(super.message);
}
