import '../../core/utils/result.dart';
import '../entities/ecole_entity.dart';
import '../entities/paginated_result.dart';

abstract interface class EcoleRepository {
  Future<Result<PaginatedResult<EcoleSummaryEntity>>> search({String? query, int page = 1});

  Future<Result<EcoleEntity>> show(String ecoleId);

  /// Retourne le nouveau [FollowStatus] tel que rapporté par le serveur — utile pour distinguer
  /// un abonnement immédiatement accepté (école "publique") d'une demande en attente (école
  /// "privée"), sans avoir à recharger tout le profil.
  Future<Result<FollowStatus>> follow(String ecoleId);

  Future<Result<void>> unfollow(String ecoleId);
}
