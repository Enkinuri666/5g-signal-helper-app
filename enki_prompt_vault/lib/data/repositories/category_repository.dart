import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final DatabaseHelper _db;
  static const _uuid = Uuid();

  CategoryRepository(this._db);

  Future<List<CategoryModel>> getRootCategories() async {
    final db = await _db.database;
    final rows = await db.rawQuery('''
      SELECT c.*, (SELECT COUNT(*) FROM prompts WHERE category = c.name) as prompt_count
      FROM categories c
      WHERE c.parent_id = ''
      ORDER BY c.sort_order ASC, c.name ASC
    ''');
    return rows.map(CategoryModel.fromMap).toList();
  }

  Future<List<CategoryModel>> getSubcategories(String parentId) async {
    final db = await _db.database;
    final parent = await db.query('categories', where: 'id = ?', whereArgs: [parentId]);
    if (parent.isEmpty) return [];
    final parentName = parent.first['name'] as String;

    final rows = await db.rawQuery('''
      SELECT c.*, (SELECT COUNT(*) FROM prompts WHERE subcategory = c.name AND category = ?) as prompt_count
      FROM categories c
      WHERE c.parent_id = ?
      ORDER BY c.sort_order ASC, c.name ASC
    ''', [parentName, parentId]);
    return rows.map(CategoryModel.fromMap).toList();
  }

  Future<List<String>> getAllCategoryNames() async {
    final db = await _db.database;
    final rows = await db.query('categories', columns: ['name'], orderBy: 'sort_order ASC');
    return rows.map((r) => r['name'] as String).toList();
  }

  Future<String> insert(String name, {String parentId = ''}) async {
    final db = await _db.database;
    final id = _uuid.v4();
    await db.insert('categories', {
      'id': id,
      'name': name,
      'parent_id': parentId,
      'icon': '',
      'color': '',
      'sort_order': 0,
    });
    return id;
  }

  Future<void> delete(String id) async {
    final db = await _db.database;
    await db.delete('categories', where: 'parent_id = ?', whereArgs: [id]);
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }
}
