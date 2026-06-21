import 'package:json_annotation/json_annotation.dart';

part 'category_model.g.dart';

enum CategoryType { income, expense }

@JsonSerializable()
class Category {
  final String id;
  final String name;
  final String? icon;
  final String? color;
  @JsonKey(fromJson: _categoryTypeFromJson, toJson: _categoryTypeToJson)
  final CategoryType type;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    this.icon,
    this.color,
    required this.type,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}

CategoryType _categoryTypeFromJson(String? value) {
  return CategoryType.values.firstWhere(
    (e) => e.toString().split('.').last == value,
    orElse: () => CategoryType.expense,
  );
}

String _categoryTypeToJson(CategoryType type) {
  return type.toString().split('.').last;
}
