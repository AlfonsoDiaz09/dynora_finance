import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/usecase/usecase.dart';
import 'package:dynora_finance/features/debts/domain/entities/person_entity.dart';
import 'package:dynora_finance/features/debts/domain/repositories/person_repository.dart';
import 'package:fpdart/fpdart.dart';

class RenamePerson implements UseCase<PersonEntity, RenamePersonParams> {
  const RenamePerson(this._repository);

  final PersonRepository _repository;

  @override
  Future<Either<Failure, PersonEntity>> call(RenamePersonParams params) async {
    final clean = params.name.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (clean.isEmpty) {
      return left(const ValidationFailure('Escribe el nombre de la persona'));
    }
    return _repository.rename(params.id, clean);
  }
}

class RenamePersonParams {
  const RenamePersonParams({required this.id, required this.name});

  final String id;
  final String name;
}
