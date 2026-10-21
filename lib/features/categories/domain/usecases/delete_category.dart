import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/usecase/usecase.dart';
import 'package:dynora_finance/features/categories/domain/repositories/category_repository.dart';
import 'package:fpdart/fpdart.dart';

class DeleteCategory implements UseCase<Unit, String> {
  const DeleteCategory(this._repository);

  final CategoryRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(String id) {
    return _repository.deleteCategory(id);
  }
}
