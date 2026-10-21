import 'package:equatable/equatable.dart';

/// Someone you share expenses with.
class PersonEntity extends Equatable {
  const PersonEntity({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [id, name, createdAt, updatedAt];
}
