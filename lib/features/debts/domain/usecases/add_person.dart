import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/usecase/usecase.dart';
import 'package:dynora_finance/features/debts/domain/entities/person_entity.dart';
import 'package:dynora_finance/features/debts/domain/repositories/person_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Adds a person, or returns the existing one with the same name.
class AddPerson implements UseCase<PersonEntity, String> {
  const AddPerson(this._repository);

  final PersonRepository _repository;

  @override
  Future<Either<Failure, PersonEntity>> call(String name) async {
    final clean = name.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (clean.isEmpty) {
      return left(const ValidationFailure('Escribe el nombre de la persona'));
    }
    return _repository.findOrCreate(clean);
  }
}
