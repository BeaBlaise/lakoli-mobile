import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:flutter/foundation.dart';

import '../config/env.dart';
import '../storage/secure_storage_service.dart';

/// Client temps réel — Reverb parle le protocole Pusher, donc un client compatible avec ce
/// protocole peut s'y connecter (le web utilise laravel-echo + pusher-js pour la même raison ;
/// voir CLAUDE.md du dépôt lakoli, section Reverb).
///
/// dart_pusher_channels a été choisi après avoir écarté pusher_channels_flutter (le paquet
/// "officiel" Pusher) : son code natif Android/iOS n'appelle jamais que `setCluster()`, sans
/// jamais exposer de `setHost()`/`setWsPort()` depuis Dart (vérifié dans le code source jusqu'à
/// sa version 2.6.0, la plus récente) — il ne peut tout simplement pas se connecter à un serveur
/// Reverb auto-hébergé sous un nom d'hôte personnalisé. dart_pusher_channels est en Dart pur
/// (s'appuie sur package:http + web_socket_channel), expose explicitement
/// `PusherChannelsOptions.fromHost(host:, port:)` pour ce cas, et est nettement plus mature que
/// l'alternative pusher_reverb_flutter (publiée en version 0.0.10 seulement quelques jours avant
/// ce choix).
///
/// Un seul [PusherChannelsClient] partagé pour toute l'app (voir
/// core/providers/core_providers.dart) — se connecte une fois, puis s'abonne/se désabonne aux
/// canaux au fil de la navigation (communautés, messagerie privée).
class ReverbService {
  ReverbService(this._secureStorage) : _client = _buildClient();

  final SecureStorageService _secureStorage;
  final PusherChannelsClient _client;

  static PusherChannelsClient _buildClient() {
    final options = PusherChannelsOptions.fromHost(
      scheme: Env.reverbUseTls ? 'wss' : 'ws',
      host: Env.reverbHost,
      port: Env.reverbPort,
      key: Env.reverbAppKey,
    );

    return PusherChannelsClient.websocket(
      options: options,
      connectionErrorHandler: (exception, trace, refresh) {
        if (kDebugMode) debugPrint('Reverb connection error: $exception');
        // Le réseau mobile faible est une contrainte produit explicite ici (voir
        // core/config/env.dart et ApiClient) — on retente plutôt que d'abandonner
        // silencieusement la connexion temps réel.
        refresh();
      },
    );
  }

  Stream<void> get onConnectionEstablished => _client.onConnectionEstablished;

  Future<void> connect() => _client.connect();

  Future<void> disconnect() => _client.disconnect();

  PublicChannel publicChannel(String channelName) => _client.publicChannel(channelName);

  /// Canal privé authentifié via POST /api/v1/broadcasting/auth (voir CLAUDE.md du dépôt lakoli
  /// — équivalent Sanctum de la route web par défaut, qui n'accepte que la session cookie). Le
  /// token est lu une fois au moment de la création du canal plutôt que passé de façon
  /// statique/codée en dur : cette méthode est asynchrone pour cette seule raison.
  Future<PrivateChannel> privateChannel(String channelName) async {
    final token = await _secureStorage.readToken();

    return _client.privateChannel(
      channelName,
      authorizationDelegate: EndpointAuthorizableChannelTokenAuthorizationDelegate.forPrivateChannel(
        authorizationEndpoint: Uri.parse('${Env.apiBaseUrl}/broadcasting/auth'),
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      ),
    );
  }
}
