import '../../core/utils/result.dart';

abstract interface class PublicationRepository {
  Future<Result<void>> like(String publicationId);
  Future<Result<void>> unlike(String publicationId);
}
