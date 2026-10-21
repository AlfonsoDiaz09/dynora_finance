import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:equatable/equatable.dart';

class MovementFilter extends Equatable {
  const MovementFilter({this.from, this.to, this.type, this.categoryId});

  /// Inclusive lower bound of the movement date.
  final DateTime? from;

  /// Inclusive upper bound of the movement date.
  final DateTime? to;
  final MovementType? type;
  final String? categoryId;

  static const MovementFilter all = MovementFilter();

  @override
  List<Object?> get props => [from, to, type, categoryId];
}
