import 'dart:async';

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

/// Stream version of [guard]: errors are emitted as a `Left` value that ends
/// the stream.
///
/// Implemented as a transform rather than an `async*` generator: generators
/// wrapping Isar watch streams stall when combined with others
/// (`Rx.combineLatest`), which left screens loading forever.
Stream<Either<Failure, T>> guardStream<T>(Stream<T> Function() source) {
  final Stream<T> stream;
  try {
    stream = source();
  } catch (error) {
    return Stream.value(left(mapExceptionToFailure(error)));
  }
  return stream.transform(
    StreamTransformer<T, Either<Failure, T>>.fromHandlers(
      handleData: (value, sink) => sink.add(right(value)),
      handleError: (error, _, sink) {
        sink
          ..add(left(mapExceptionToFailure(error)))
          ..close();
      },
    ),
  );
}

Failure mapExceptionToFailure(Object error) {
  return switch (error) {
    LocalDatabaseException(:final message) => LocalDatabaseFailure(message),
    RemoteDataSourceException(:final message) => RemoteFailure(message),
    NotFoundException(:final message) => NotFoundFailure(message),
    _ => UnexpectedFailure(error.toString()),
  };
}
