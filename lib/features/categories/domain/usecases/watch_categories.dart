import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/core/usecase/usecase.dart';
import 'package:dynora_finance/features/categories/domain/entities/category_entity.dart';
import 'package:dynora_finance/features/categories/domain/repositories/category_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Pass `null` to watch every category.
class WatchCategories
    implements StreamUseCase<List<CategoryEntity>, MovementType?> {
  const WatchCategories(this._repository);

  final CategoryRepository _repository;

  @override
  Stream<Either<Failure, List<CategoryEntity>>> call(MovementType? type) {
    return _repository.watchCategories(type: type);
  }
}
