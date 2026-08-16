import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/commentaire_remote_datasource.dart';
import '../../data/datasources/communaute_remote_datasource.dart';
import '../../data/datasources/ecole_remote_datasource.dart';
import '../../data/datasources/feed_remote_datasource.dart';
import '../../data/datasources/message_remote_datasource.dart';
import '../../data/datasources/notification_remote_datasource.dart';
import '../../data/datasources/publication_remote_datasource.dart';
import '../../data/repositories/commentaire_repository_impl.dart';
import '../../data/repositories/communaute_repository_impl.dart';
import '../../data/repositories/ecole_repository_impl.dart';
import '../../data/repositories/feed_repository_impl.dart';
import '../../data/repositories/message_repository_impl.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../data/repositories/publication_repository_impl.dart';
import '../../domain/repositories/commentaire_repository.dart';
import '../../domain/repositories/communaute_repository.dart';
import '../../domain/repositories/ecole_repository.dart';
import '../../domain/repositories/feed_repository.dart';
import '../../domain/repositories/message_repository.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/repositories/publication_repository.dart';
import '../../presentation/auth/application/auth_controller.dart';
import '../network/api_client.dart';
import '../realtime/reverb_service.dart';
import '../storage/secure_storage_service.dart';

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

/// L'ApiClient a besoin de pouvoir déclencher une déconnexion locale sur un 401 venant de
/// n'importe quel appel réseau, pas seulement ceux de l'écran de connexion — d'où la
/// dépendance vers authControllerProvider ici plutôt que l'inverse.
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    secureStorage: ref.watch(secureStorageServiceProvider),
    onUnauthenticated: () => ref.read(authControllerProvider.notifier).handleUnauthenticated(),
  );
});

/// Un seul client Reverb pour toute l'app — voir core/realtime/reverb_service.dart pour le
/// choix de dart_pusher_channels plutôt que pusher_channels_flutter. Connecté/déconnecté par
/// la couche présentation (au login/logout), pas ici : ce provider ne fait que construire
/// l'instance.
final reverbServiceProvider = Provider<ReverbService>((ref) {
  return ReverbService(ref.watch(secureStorageServiceProvider));
});

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepositoryImpl(FeedRemoteDataSource(ref.watch(apiClientProvider)));
});

final publicationRepositoryProvider = Provider<PublicationRepository>((ref) {
  return PublicationRepositoryImpl(PublicationRemoteDataSource(ref.watch(apiClientProvider)));
});

final ecoleRepositoryProvider = Provider<EcoleRepository>((ref) {
  return EcoleRepositoryImpl(EcoleRemoteDataSource(ref.watch(apiClientProvider)));
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(NotificationRemoteDataSource(ref.watch(apiClientProvider)));
});

final commentaireRepositoryProvider = Provider<CommentaireRepository>((ref) {
  return CommentaireRepositoryImpl(CommentaireRemoteDataSource(ref.watch(apiClientProvider)));
});

final communauteRepositoryProvider = Provider<CommunauteRepository>((ref) {
  return CommunauteRepositoryImpl(CommunauteRemoteDataSource(ref.watch(apiClientProvider)));
});

final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  return MessageRepositoryImpl(MessageRemoteDataSource(ref.watch(apiClientProvider)));
});
