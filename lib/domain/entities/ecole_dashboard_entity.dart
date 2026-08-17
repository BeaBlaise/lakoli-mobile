import 'package:equatable/equatable.dart';

class EcoleDashboardStats extends Equatable {
  const EcoleDashboardStats({
    required this.followersCount,
    required this.publicationsCount,
    required this.likesCount,
    required this.commentairesCount,
  });

  final int followersCount;
  final int publicationsCount;
  final int likesCount;
  final int commentairesCount;

  @override
  List<Object?> get props => [followersCount, publicationsCount, likesCount, commentairesCount];
}

class FollowRequestEntity extends Equatable {
  const FollowRequestEntity({
    required this.id,
    required this.userId,
    required this.userFullName,
    required this.createdAt,
    this.userAvatarUrl,
  });

  final String id;
  final String userId;
  final String userFullName;
  final String? userAvatarUrl;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, userId, userFullName, userAvatarUrl, createdAt];
}

/// Correspond à Api\V1\Ecole\DashboardController::index() — délibérément sans les pourcentages
/// de croissance sur 30 jours ni le graphe d'engagement sur 7 jours du tableau de bord web
/// (Ecole/Dashboard.tsx), voir le commentaire de ce contrôleur côté Laravel.
class EcoleDashboardEntity extends Equatable {
  const EcoleDashboardEntity({required this.stats, required this.demandesAbonnement});

  final EcoleDashboardStats stats;
  final List<FollowRequestEntity> demandesAbonnement;

  EcoleDashboardEntity copyWithoutRequest(String requestId) {
    return EcoleDashboardEntity(
      stats: stats,
      demandesAbonnement: demandesAbonnement.where((r) => r.id != requestId).toList(),
    );
  }

  @override
  List<Object?> get props => [stats, demandesAbonnement];
}
