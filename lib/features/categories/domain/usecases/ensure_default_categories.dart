import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/usecase/usecase.dart';
import 'package:dynora_finance/features/categories/domain/entities/default_categories.dart';
import 'package:dynora_finance/features/categories/domain/repositories/category_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Inserts [defaultCategories] the first time the app runs.
class EnsureDefaultCategories implements UseCase<Unit, NoParams> {
  const EnsureDefaultCategories(this._repository);

  final CategoryRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(NoParams params) {
    return _repository.seedDefaults(defaultCategories);
  }
}
