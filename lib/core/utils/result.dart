import '../errors/app_exception.dart';

/// Résultat d'une opération pouvant échouer, sans lever d'exception jusqu'à la couche
/// présentation — les repositories renvoient toujours un [Result], jamais une exception
/// brute, pour forcer chaque écran à gérer explicitement l'état d'erreur (voir les États UI
/// obligatoires : Loading/Loaded/Empty/Error/Offline).
sealed class Result<T> {
  const Result();

  const factory Result.success(T data) = Success<T>;
  const factory Result.failure(AppException exception) = Failure<T>;

  R when<R>({
    required R Function(T data) success,
    required R Function(AppException exception) failure,
  }) {
    final self = this;
    return switch (self) {
      Success<T>() => success(self.data),
      Failure<T>() => failure(self.exception),
    };
  }

  bool get isSuccess => this is Success<T>;
}

final class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

final class Failure<T> extends Result<T> {
  const Failure(this.exception);
  final AppException exception;
}
