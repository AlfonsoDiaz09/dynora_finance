import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/usecase/usecase.dart';
import 'package:dynora_finance/features/categories/domain/entities/category_entity.dart';
import 'package:dynora_finance/features/categories/domain/repositories/category_repository.dart';
import 'package:fpdart/fpdart.dart';

class AddCategory implements UseCase<CategoryEntity, AddCategoryParams> {
  const AddCategory(this._repository);

  final CategoryRepository _repository;

  @override
  Future<Either<Failure, CategoryEntity>> call(AddCategoryParams params) async {
    if (params.name.trim().isEmpty) {
      return left(const ValidationFailure('El nombre es obligatorio'));
    }

    return _repository.createCategory(
      name: params.name.trim(),
      type: params.type,
      iconCodePoint: params.iconCodePoint,
      colorValue: params.colorValue,
    );
  }
}

class AddCategoryParams {
  const AddCategoryParams({
    required this.name,
    required this.type,
    required this.iconCodePoint,
    required this.colorValue,
  });

  final String name;
  final MovementType type;
  final int iconCodePoint;
  final int colorValue;
}
