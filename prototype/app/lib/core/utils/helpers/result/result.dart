sealed class Result<T extends FailureType, S> {
  const Result();

  B fold<B>(
    B Function(FailureInfo<T>) onFailure,
    B Function(S) onSuccess,
  ) {
    return switch (this) {
      Failure<T, S>(error: final error) => onFailure(error),
      Success<T, S>(object: final value) => onSuccess(value),
    };
  }
}

final class Success<T extends FailureType, S> extends Result<T, S> {
  const Success(this.object);

  final S object;
}

final class Failure<T extends FailureType, S> extends Result<T, S> {
  const Failure(this.error);

  final FailureInfo<T> error;
}

abstract class FailureType {}

class FailureInfo<T extends FailureType> {
  const FailureInfo({
    required this.type,
    this.message,
  });

  final T type;
  final String? message;
}
