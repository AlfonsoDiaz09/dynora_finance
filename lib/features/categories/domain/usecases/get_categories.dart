import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/usecase/usecase.dart';
import 'package:dynora_finance/features/categories/domain/entities/category_entity.dart';
import 'package:dynora_finance/features/categories/domain/repositories/category_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Pass `null` to get every category.
class GetCategories implements UseCase<List<CategoryEntity>, MovementType?> {
  const GetCategories(this._repository);

  final CategoryRepository _repository;

  @override
  Future<Either<Failure, List<CategoryEntity>>> call(MovementType? type) {
    return _repository.getCategories(type: type);
  }
}
