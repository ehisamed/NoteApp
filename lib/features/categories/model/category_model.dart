import 'package:equatable/equatable.dart';

class CategoryModel extends Equatable {
  final int? id;
  final String name;
  final String? color;
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryModel({
    this.id,
    required this.name,
    this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] is int ? map['id'] as int : int.tryParse('${map['id']}'),
      name: map['name'] ?? '',
      color: map['color'],
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, name, color, createdAt, updatedAt];
}
