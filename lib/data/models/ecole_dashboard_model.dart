import '../../domain/entities/ecole_dashboard_entity.dart';

class EcoleDashboardModel {
  const EcoleDashboardModel({required this.stats, required this.demandesAbonnement});

  final EcoleDashboardStats stats;
  final List<FollowRequestEntity> demandesAbonnement;

  factory EcoleDashboardModel.fromJson(Map<String, dynamic> json) {
    final statsJson = json['stats'] as Map<String, dynamic>;
    final demandes = json['demandes_abonnement'] as List;

    return EcoleDashboardModel(
      stats: EcoleDashboardStats(
        followersCount: statsJson['followers_count'] as int? ?? 0,
        publicationsCount: statsJson['publications_count'] as int? ?? 0,
        likesCount: statsJson['likes_count'] as int? ?? 0,
        commentairesCount: statsJson['commentaires_count'] as int? ?? 0,
      ),
      demandesAbonnement: demandes.map((e) {
        final d = e as Map<String, dynamic>;
        final user = d['user'] as Map<String, dynamic>;
        return FollowRequestEntity(
          id: d['id'] as String,
          userId: user['id'] as String,
          userFullName: user['full_name'] as String,
          userAvatarUrl: user['avatar_url'] as String?,
          createdAt: DateTime.parse(d['created_at'] as String),
        );
      }).toList(),
    );
  }

  EcoleDashboardEntity toEntity() => EcoleDashboardEntity(stats: stats, demandesAbonnement: demandesAbonnement);
}
