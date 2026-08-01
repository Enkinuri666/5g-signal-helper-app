class CollectionModel {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String parentId;
  final bool isPinned;
  final int sortOrder;
  final int promptCount;
  final DateTime createdAt;
  final DateTime modifiedAt;

  const CollectionModel({
    required this.id,
    required this.name,
    this.description = '',
    this.icon = 'folder',
    this.parentId = '',
    this.isPinned = false,
    this.sortOrder = 0,
    this.promptCount = 0,
    required this.createdAt,
    required this.modifiedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'icon': icon,
        'parent_id': parentId,
        'is_pinned': isPinned ? 1 : 0,
        'sort_order': sortOrder,
        'created_at': createdAt.toIso8601String(),
        'modified_at': modifiedAt.toIso8601String(),
      };

  factory CollectionModel.fromMap(Map<String, dynamic> map) => CollectionModel(
        id: map['id'] as String,
        name: map['name'] as String,
        description: (map['description'] ?? '') as String,
        icon: (map['icon'] ?? 'folder') as String,
        parentId: (map['parent_id'] ?? '') as String,
        isPinned: (map['is_pinned'] ?? 0) == 1,
        sortOrder: (map['sort_order'] ?? 0) as int,
        promptCount: (map['prompt_count'] ?? 0) as int,
        createdAt: DateTime.parse(map['created_at'] as String),
        modifiedAt: DateTime.parse(map['modified_at'] as String),
      );

  CollectionModel copyWith({
    String? name,
    String? description,
    String? icon,
    String? parentId,
    bool? isPinned,
    int? sortOrder,
    int? promptCount,
    DateTime? modifiedAt,
  }) =>
      CollectionModel(
        id: id,
        name: name ?? this.name,
        description: description ?? this.description,
        icon: icon ?? this.icon,
        parentId: parentId ?? this.parentId,
        isPinned: isPinned ?? this.isPinned,
        sortOrder: sortOrder ?? this.sortOrder,
        promptCount: promptCount ?? this.promptCount,
        createdAt: createdAt,
        modifiedAt: modifiedAt ?? this.modifiedAt,
      );
}
