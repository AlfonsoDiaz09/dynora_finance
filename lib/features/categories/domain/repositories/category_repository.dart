import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:dynora_finance/core/error/failures.dart';
import 'package:dynora_finance/features/categories/domain/entities/category_entity.dart';
import 'package:dynora_finance/features/categories/domain/entities/default_categories.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class CategoryRepository {
  /// Returns every category, or only those of [type] when given.
  Future<Either<Failure, List<CategoryEntity>>> getCategories({
    MovementType? type,
  });

  Stream<Either<Failure, List<CategoryEntity>>> watchCategories({
    MovementType? type,
  });

  Future<Either<Failure, CategoryEntity>> getCategoryById(String id);

  Future<Either<Failure, CategoryEntity>> createCategory({
    required String name,
    required MovementType type,
    required String iconKey,
    required int colorValue,
  });

  Future<Either<Failure, CategoryEntity>> updateCategory(
    CategoryEntity category,
  );

  Future<Either<Failure, Unit>> deleteCategory(String id);

  /// Inserts [defaults] only when no category was ever stored.
  Future<Either<Failure, Unit>> seedDefaults(List<DefaultCategory> defaults);
}
