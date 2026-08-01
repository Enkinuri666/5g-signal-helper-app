import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/prompt_model.dart';

class PromptRepository {
  final DatabaseHelper _db;
  static const _uuid = Uuid();

  PromptRepository(this._db);

  Future<List<PromptModel>> getAll({
    int limit = 50,
    int offset = 0,
    String orderBy = 'modified_at DESC',
  }) async {
    final db = await _db.database;
    final rows = await db.query(
      'prompts',
      limit: limit,
      offset: offset,
      orderBy: orderBy,
    );
    return rows.map(PromptModel.fromMap).toList();
  }

  Future<PromptModel?> getById(String id) async {
    final db = await _db.database;
    final rows = await db.query('prompts', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : PromptModel.fromMap(rows.first);
  }

  Future<String> insert(PromptModel prompt) async {
    final db = await _db.database;
    final id = prompt.id.isEmpty ? _uuid.v4() : prompt.id;
    final now = DateTime.now();
    final model = PromptModel(
      id: id,
      title: prompt.title,
      description: prompt.description,
      body: prompt.body,
      category: prompt.category,
      subcategory: prompt.subcategory,
      tags: prompt.tags,
      aiModels: prompt.aiModels,
      difficulty: prompt.difficulty,
      variables: prompt.variables,
      expectedOutput: prompt.expectedOutput,
      example: prompt.example,
      notes: prompt.notes,
      rating: prompt.rating,
      isFavorite: prompt.isFavorite,
      isPinned: prompt.isPinned,
      source: prompt.source,
      personalNotes: prompt.personalNotes,
      collectionId: prompt.collectionId,
      createdAt: now,
      modifiedAt: now,
    );
    await db.insert('prompts', model.toMap());
    return id;
  }

  Future<void> update(PromptModel prompt) async {
    final db = await _db.database;
    final updated = prompt.copyWith(modifiedAt: DateTime.now());
    await db.update('prompts', updated.toMap(), where: 'id = ?', whereArgs: [prompt.id]);
  }

  Future<void> delete(String id) async {
    final db = await _db.database;
    await db.delete('prompts', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> toggleFavorite(String id) async {
    final db = await _db.database;
    await db.rawUpdate(
      'UPDATE prompts SET is_favorite = CASE WHEN is_favorite = 1 THEN 0 ELSE 1 END, modified_at = ? WHERE id = ?',
      [DateTime.now().toIso8601String(), id],
    );
  }

  Future<void> togglePin(String id) async {
    final db = await _db.database;
    await db.rawUpdate(
      'UPDATE prompts SET is_pinned = CASE WHEN is_pinned = 1 THEN 0 ELSE 1 END, modified_at = ? WHERE id = ?',
      [DateTime.now().toIso8601String(), id],
    );
  }

  Future<void> incrementCopyCount(String id) async {
    final db = await _db.database;
    final now = DateTime.now().toIso8601String();
    await db.rawUpdate(
      'UPDATE prompts SET copy_count = copy_count + 1, last_used_at = ? WHERE id = ?',
      [now, id],
    );
    await db.insert('copy_history', {
      'id': _uuid.v4(),
      'prompt_id': id,
      'copied_at': now,
    });
  }

  Future<void> incrementUseCount(String id) async {
    final db = await _db.database;
    await db.rawUpdate(
      'UPDATE prompts SET use_count = use_count + 1, last_used_at = ? WHERE id = ?',
      [DateTime.now().toIso8601String(), id],
    );
  }

  Future<void> setRating(String id, int rating) async {
    final db = await _db.database;
    await db.rawUpdate(
      'UPDATE prompts SET rating = ?, modified_at = ? WHERE id = ?',
      [rating, DateTime.now().toIso8601String(), id],
    );
  }

  Future<List<PromptModel>> getFavorites({int limit = 50, int offset = 0}) async {
    final db = await _db.database;
    final rows = await db.query(
      'prompts',
      where: 'is_favorite = 1',
      orderBy: 'modified_at DESC',
      limit: limit,
      offset: offset,
    );
    return rows.map(PromptModel.fromMap).toList();
  }

  Future<List<PromptModel>> getPinned() async {
    final db = await _db.database;
    final rows = await db.query(
      'prompts',
      where: 'is_pinned = 1',
      orderBy: 'modified_at DESC',
    );
    return rows.map(PromptModel.fromMap).toList();
  }

  Future<List<PromptModel>> getRecent({int limit = 20}) async {
    final db = await _db.database;
    final rows = await db.query(
      'prompts',
      where: 'last_used_at IS NOT NULL',
      orderBy: 'last_used_at DESC',
      limit: limit,
    );
    return rows.map(PromptModel.fromMap).toList();
  }

  Future<List<PromptModel>> getByCategory(String category, {int limit = 50, int offset = 0}) async {
    final db = await _db.database;
    final rows = await db.query(
      'prompts',
      where: 'category = ? OR subcategory = ?',
      whereArgs: [category, category],
      orderBy: 'modified_at DESC',
      limit: limit,
      offset: offset,
    );
    return rows.map(PromptModel.fromMap).toList();
  }

  Future<List<PromptModel>> getByCollection(String collectionId, {int limit = 50, int offset = 0}) async {
    final db = await _db.database;
    final rows = await db.query(
      'prompts',
      where: 'collection_id = ?',
      whereArgs: [collectionId],
      orderBy: 'modified_at DESC',
      limit: limit,
      offset: offset,
    );
    return rows.map(PromptModel.fromMap).toList();
  }

  Future<List<PromptModel>> search(String query, {int limit = 50}) async {
    final db = await _db.database;
    if (query.trim().isEmpty) return [];

    final ftsQuery = query.split(' ').map((w) => '$w*').join(' ');

    final rows = await db.rawQuery('''
      SELECT p.* FROM prompts p
      INNER JOIN prompts_fts ON prompts_fts.rowid = p.rowid
      WHERE prompts_fts MATCH ?
      ORDER BY rank
      LIMIT ?
    ''', [ftsQuery, limit]);

    return rows.map(PromptModel.fromMap).toList();
  }

  Future<int> count() async {
    final db = await _db.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM prompts');
    return result.first['count'] as int;
  }

  Future<int> countByCategory(String category) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM prompts WHERE category = ?',
      [category],
    );
    return result.first['count'] as int;
  }

  Future<int> favoriteCount() async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM prompts WHERE is_favorite = 1',
    );
    return result.first['count'] as int;
  }

  Future<Map<String, int>> categoryStats() async {
    final db = await _db.database;
    final rows = await db.rawQuery(
      'SELECT category, COUNT(*) as count FROM prompts GROUP BY category ORDER BY count DESC',
    );
    return {for (final r in rows) r['category'] as String: r['count'] as int};
  }

  Future<List<Map<String, dynamic>>> getCopyHistory({int limit = 20}) async {
    final db = await _db.database;
    return db.rawQuery('''
      SELECT ch.copied_at, p.id, p.title, p.category
      FROM copy_history ch
      INNER JOIN prompts p ON p.id = ch.prompt_id
      ORDER BY ch.copied_at DESC
      LIMIT ?
    ''', [limit]);
  }

  Future<List<PromptModel>> getFrequentlyUsed({int limit = 10}) async {
    final db = await _db.database;
    final rows = await db.query(
      'prompts',
      where: 'use_count > 0',
      orderBy: 'use_count DESC',
      limit: limit,
    );
    return rows.map(PromptModel.fromMap).toList();
  }

  Future<void> bulkInsert(List<PromptModel> prompts) async {
    final db = await _db.database;
    final batch = db.batch();
    for (final p in prompts) {
      batch.insert('prompts', p.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<List<Map<String, dynamic>>> exportAll() async {
    final db = await _db.database;
    return db.query('prompts', orderBy: 'created_at ASC');
  }
}
