class PromptModel {
  final String id;
  final String title;
  final String description;
  final String body;
  final String category;
  final String subcategory;
  final String tags;
  final String aiModels;
  final String difficulty;
  final String variables;
  final String expectedOutput;
  final String example;
  final String notes;
  final int rating;
  final bool isFavorite;
  final bool isPinned;
  final String source;
  final String personalNotes;
  final String collectionId;
  final int copyCount;
  final int useCount;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final DateTime? lastUsedAt;

  const PromptModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.body,
    this.category = 'General AI',
    this.subcategory = '',
    this.tags = '',
    this.aiModels = '',
    this.difficulty = 'Intermediate',
    this.variables = '',
    this.expectedOutput = '',
    this.example = '',
    this.notes = '',
    this.rating = 0,
    this.isFavorite = false,
    this.isPinned = false,
    this.source = '',
    this.personalNotes = '',
    this.collectionId = '',
    this.copyCount = 0,
    this.useCount = 0,
    required this.createdAt,
    required this.modifiedAt,
    this.lastUsedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'body': body,
        'category': category,
        'subcategory': subcategory,
        'tags': tags,
        'ai_models': aiModels,
        'difficulty': difficulty,
        'variables': variables,
        'expected_output': expectedOutput,
        'example': example,
        'notes': notes,
        'rating': rating,
        'is_favorite': isFavorite ? 1 : 0,
        'is_pinned': isPinned ? 1 : 0,
        'source': source,
        'personal_notes': personalNotes,
        'collection_id': collectionId,
        'copy_count': copyCount,
        'use_count': useCount,
        'created_at': createdAt.toIso8601String(),
        'modified_at': modifiedAt.toIso8601String(),
        'last_used_at': lastUsedAt?.toIso8601String(),
      };

  factory PromptModel.fromMap(Map<String, dynamic> map) => PromptModel(
        id: map['id'] as String,
        title: map['title'] as String,
        description: (map['description'] ?? '') as String,
        body: map['body'] as String,
        category: (map['category'] ?? 'General AI') as String,
        subcategory: (map['subcategory'] ?? '') as String,
        tags: (map['tags'] ?? '') as String,
        aiModels: (map['ai_models'] ?? '') as String,
        difficulty: (map['difficulty'] ?? 'Intermediate') as String,
        variables: (map['variables'] ?? '') as String,
        expectedOutput: (map['expected_output'] ?? '') as String,
        example: (map['example'] ?? '') as String,
        notes: (map['notes'] ?? '') as String,
        rating: (map['rating'] ?? 0) as int,
        isFavorite: (map['is_favorite'] ?? 0) == 1,
        isPinned: (map['is_pinned'] ?? 0) == 1,
        source: (map['source'] ?? '') as String,
        personalNotes: (map['personal_notes'] ?? '') as String,
        collectionId: (map['collection_id'] ?? '') as String,
        copyCount: (map['copy_count'] ?? 0) as int,
        useCount: (map['use_count'] ?? 0) as int,
        createdAt: DateTime.parse(map['created_at'] as String),
        modifiedAt: DateTime.parse(map['modified_at'] as String),
        lastUsedAt: map['last_used_at'] != null
            ? DateTime.parse(map['last_used_at'] as String)
            : null,
      );

  PromptModel copyWith({
    String? title,
    String? description,
    String? body,
    String? category,
    String? subcategory,
    String? tags,
    String? aiModels,
    String? difficulty,
    String? variables,
    String? expectedOutput,
    String? example,
    String? notes,
    int? rating,
    bool? isFavorite,
    bool? isPinned,
    String? source,
    String? personalNotes,
    String? collectionId,
    int? copyCount,
    int? useCount,
    DateTime? modifiedAt,
    DateTime? lastUsedAt,
  }) =>
      PromptModel(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        body: body ?? this.body,
        category: category ?? this.category,
        subcategory: subcategory ?? this.subcategory,
        tags: tags ?? this.tags,
        aiModels: aiModels ?? this.aiModels,
        difficulty: difficulty ?? this.difficulty,
        variables: variables ?? this.variables,
        expectedOutput: expectedOutput ?? this.expectedOutput,
        example: example ?? this.example,
        notes: notes ?? this.notes,
        rating: rating ?? this.rating,
        isFavorite: isFavorite ?? this.isFavorite,
        isPinned: isPinned ?? this.isPinned,
        source: source ?? this.source,
        personalNotes: personalNotes ?? this.personalNotes,
        collectionId: collectionId ?? this.collectionId,
        copyCount: copyCount ?? this.copyCount,
        useCount: useCount ?? this.useCount,
        createdAt: createdAt,
        modifiedAt: modifiedAt ?? this.modifiedAt,
        lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      );

  List<String> get tagList =>
      tags.isEmpty ? [] : tags.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();

  List<String> get aiModelList =>
      aiModels.isEmpty ? [] : aiModels.split(',').map((m) => m.trim()).where((m) => m.isNotEmpty).toList();

  Map<String, String> get variableMap {
    if (variables.isEmpty) return {};
    final map = <String, String>{};
    for (final v in variables.split('||')) {
      final parts = v.split('::');
      if (parts.length == 2) {
        map[parts[0].trim()] = parts[1].trim();
      }
    }
    return map;
  }
}
