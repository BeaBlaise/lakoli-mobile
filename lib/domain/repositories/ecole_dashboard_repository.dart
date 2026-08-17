import '../../core/utils/result.dart';
import '../entities/ecole_dashboard_entity.dart';

abstract interface class EcoleDashboardRepository {
  Future<Result<EcoleDashboardEntity>> fetch();

  Future<Result<void>> acceptFollowRequest(String followId);
  Future<Result<void>> refuseFollowRequest(String followId);
}
