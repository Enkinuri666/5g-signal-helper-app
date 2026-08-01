class CategoryModel {
  final String id;
  final String name;
  final String parentId;
  final String icon;
  final String color;
  final int sortOrder;
  final int promptCount;

  const CategoryModel({
    required this.id,
    required this.name,
    this.parentId = '',
    this.icon = '',
    this.color = '',
    this.sortOrder = 0,
    this.promptCount = 0,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'parent_id': parentId,
        'icon': icon,
        'color': color,
        'sort_order': sortOrder,
      };

  factory CategoryModel.fromMap(Map<String, dynamic> map) => CategoryModel(
        id: map['id'] as String,
        name: map['name'] as String,
        parentId: (map['parent_id'] ?? '') as String,
        icon: (map['icon'] ?? '') as String,
        color: (map['color'] ?? '') as String,
        sortOrder: (map['sort_order'] ?? 0) as int,
        promptCount: (map['prompt_count'] ?? 0) as int,
      );
}
