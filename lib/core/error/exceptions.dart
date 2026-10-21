class LocalDatabaseException implements Exception {
  const LocalDatabaseException(this.message);

  final String message;

  @override
  String toString() => 'LocalDatabaseException: $message';
}

class RemoteDataSourceException implements Exception {
  const RemoteDataSourceException(this.message);

  final String message;

  @override
  String toString() => 'RemoteDataSourceException: $message';
}

class NotFoundException implements Exception {
  const NotFoundException(this.message);

  final String message;

  @override
  String toString() => 'NotFoundException: $message';
}
