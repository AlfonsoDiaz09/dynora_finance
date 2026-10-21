import 'package:dynora_finance/core/error/exceptions.dart';
import 'package:dynora_finance/core/error/failures.dart';
import 'package:fpdart/fpdart.dart';

/// Runs [action] and maps data layer exceptions to domain [Failure]s.
Future<Either<Failure, T>> guard<T>(Future<T> Function() action) async {
  try {
    return right(await action());
  } catch (error) {
    return left(mapExceptionToFailure(error));
  }
}

/// Stream version of [guard]: errors are emitted as `Left` values.
Stream<Either<Failure, T>> guardStream<T>(Stream<T> Function() source) async* {
  try {
    await for (final value in source()) {
      yield right(value);
    }
  } catch (error) {
    yield left(mapExceptionToFailure(error));
  }
}

Failure mapExceptionToFailure(Object error) {
  return switch (error) {
    LocalDatabaseException(:final message) => LocalDatabaseFailure(message),
    RemoteDataSourceException(:final message) => RemoteFailure(message),
    NotFoundException(:final message) => NotFoundFailure(message),
    _ => UnexpectedFailure(error.toString()),
  };
}
