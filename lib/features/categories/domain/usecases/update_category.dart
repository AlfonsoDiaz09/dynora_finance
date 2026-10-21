import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/usecase/usecase.dart';
import 'package:dynora_finance/features/categories/domain/entities/category_entity.dart';
import 'package:dynora_finance/features/categories/domain/repositories/category_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateCategory implements UseCase<CategoryEntity, CategoryEntity> {
  const UpdateCategory(this._repository);

  final CategoryRepository _repository;

  @override
  Future<Either<Failure, CategoryEntity>> call(CategoryEntity category) async {
    if (category.name.trim().isEmpty) {
      return left(const ValidationFailure('El nombre es obligatorio'));
    }

    return _repository.updateCategory(
      category.copyWith(name: category.name.trim()),
    );
  }
}
