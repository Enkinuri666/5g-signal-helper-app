import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/collection_model.dart';

class CollectionRepository {
  final DatabaseHelper _db;
  static const _uuid = Uuid();

  CollectionRepository(this._db);

  Future<List<CollectionModel>> getAll() async {
    final db = await _db.database;
    final rows = await db.rawQuery('''
      SELECT c.*, (SELECT COUNT(*) FROM prompts WHERE collection_id = c.id) as prompt_count
      FROM collections c
      ORDER BY c.is_pinned DESC, c.sort_order ASC, c.name ASC
    ''');
    return rows.map(CollectionModel.fromMap).toList();
  }

  Future<List<CollectionModel>> getChildren(String parentId) async {
    final db = await _db.database;
    final rows = await db.rawQuery('''
      SELECT c.*, (SELECT COUNT(*) FROM prompts WHERE collection_id = c.id) as prompt_count
      FROM collections c
      WHERE c.parent_id = ?
      ORDER BY c.sort_order ASC, c.name ASC
    ''', [parentId]);
    return rows.map(CollectionModel.fromMap).toList();
  }

  Future<String> insert(CollectionModel collection) async {
    final db = await _db.database;
    final id = collection.id.isEmpty ? _uuid.v4() : collection.id;
    final now = DateTime.now();
    await db.insert('collections', {
      ...collection.toMap(),
      'id': id,
      'created_at': now.toIso8601String(),
      'modified_at': now.toIso8601String(),
    });
    return id;
  }

  Future<void> update(CollectionModel collection) async {
    final db = await _db.database;
    final updated = collection.copyWith(modifiedAt: DateTime.now());
    await db.update('collections', updated.toMap(), where: 'id = ?', whereArgs: [collection.id]);
  }

  Future<void> delete(String id) async {
    final db = await _db.database;
    await db.rawUpdate("UPDATE prompts SET collection_id = '' WHERE collection_id = ?", [id]);
    await db.delete('collections', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> togglePin(String id) async {
    final db = await _db.database;
    await db.rawUpdate(
      'UPDATE collections SET is_pinned = CASE WHEN is_pinned = 1 THEN 0 ELSE 1 END WHERE id = ?',
      [id],
    );
  }

  Future<int> count() async {
    final db = await _db.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM collections');
    return result.first['count'] as int;
  }
}
