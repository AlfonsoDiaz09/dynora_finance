import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/features/debts/domain/entities/person_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class PersonRepository {
  /// Emits people sorted by name and every subsequent change.
  Stream<Either<Failure, List<PersonEntity>>> watchPeople();

  /// Returns the person called [name] (case-insensitive), creating it when
  /// it does not exist yet.
  Future<Either<Failure, PersonEntity>> findOrCreate(String name);
}
