import 'dart:convert';
import 'dart:io';
import 'package:sqflite/sqflite.dart' show ConflictAlgorithm;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:csv/csv.dart';
import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/prompt_model.dart';

class BackupRepository {
  final DatabaseHelper _db;

  BackupRepository(this._db);

  Future<String> createBackup() async {
    final db = await _db.database;
    final prompts = await db.query('prompts');
    final collections = await db.query('collections');
    final categories = await db.query('categories');

    final backup = {
      'version': 1,
      'created_at': DateTime.now().toIso8601String(),
      'prompts': prompts,
      'collections': collections,
      'categories': categories,
    };

    final dir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(p.join(dir.path, 'backups'));
    if (!await backupDir.exists()) await backupDir.create(recursive: true);

    final filename = 'enki_backup_${DateTime.now().millisecondsSinceEpoch}.json';
    final file = File(p.join(backupDir.path, filename));
    await file.writeAsString(jsonEncode(backup));
    return file.path;
  }

  Future<int> restoreBackup(String path) async {
    final file = File(path);
    if (!await file.exists()) throw Exception('Backup file not found');

    final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    final db = await _db.database;

    final prompts = (data['prompts'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    await db.transaction((txn) async {
      for (final p in prompts) {
        await txn.insert('prompts', p.cast<String, Object?>(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      final collections = (data['collections'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      for (final c in collections) {
        await txn.insert('collections', c.cast<String, Object?>(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });

    return prompts.length;
  }

  Future<String> exportJson(List<PromptModel> prompts) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'enki_export_${DateTime.now().millisecondsSinceEpoch}.json'));
    final data = prompts.map((p) => p.toMap()).toList();
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
    return file.path;
  }

  Future<String> exportCsv(List<PromptModel> prompts) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'enki_export_${DateTime.now().millisecondsSinceEpoch}.csv'));

    final headers = ['title', 'description', 'body', 'category', 'subcategory', 'tags', 'ai_models', 'difficulty', 'rating'];
    final rows = prompts.map((p) => [
      p.title, p.description, p.body, p.category, p.subcategory,
      p.tags, p.aiModels, p.difficulty, p.rating.toString(),
    ]).toList();

    final csv = const ListToCsvConverter().convert([headers, ...rows]);
    await file.writeAsString(csv);
    return file.path;
  }

  Future<String> exportMarkdown(List<PromptModel> prompts) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'enki_export_${DateTime.now().millisecondsSinceEpoch}.md'));

    final buffer = StringBuffer('# Enki Prompt Vault Export\n\n');
    for (final p in prompts) {
      buffer.writeln('## ${p.title}\n');
      if (p.description.isNotEmpty) buffer.writeln('*${p.description}*\n');
      buffer.writeln('**Category:** ${p.category}');
      if (p.tags.isNotEmpty) buffer.writeln('**Tags:** ${p.tags}');
      if (p.aiModels.isNotEmpty) buffer.writeln('**AI Models:** ${p.aiModels}');
      buffer.writeln('\n```\n${p.body}\n```\n');
      if (p.notes.isNotEmpty) buffer.writeln('> ${p.notes}\n');
      buffer.writeln('---\n');
    }
    await file.writeAsString(buffer.toString());
    return file.path;
  }

  Future<List<PromptModel>> importJson(String path) async {
    final file = File(path);
    final data = jsonDecode(await file.readAsString());
    if (data is List) {
      return data.cast<Map<String, dynamic>>().map(PromptModel.fromMap).toList();
    }
    if (data is Map && data.containsKey('prompts')) {
      return (data['prompts'] as List).cast<Map<String, dynamic>>().map(PromptModel.fromMap).toList();
    }
    return [];
  }

  Future<List<PromptModel>> importCsv(String path) async {
    final file = File(path);
    final csv = const CsvToListConverter().convert(await file.readAsString());
    if (csv.length < 2) return [];

    final headers = csv.first.map((h) => h.toString().toLowerCase().trim()).toList();
    final titleIdx = headers.indexOf('title');
    final bodyIdx = headers.indexOf('body');
    if (titleIdx < 0 || bodyIdx < 0) return [];

    final now = DateTime.now();
    return csv.skip(1).map((row) {
      String col(String name) {
        final idx = headers.indexOf(name);
        return idx >= 0 && idx < row.length ? row[idx].toString() : '';
      }
      return PromptModel(
        id: Uuid().v4(),
        title: row[titleIdx].toString(),
        body: row[bodyIdx].toString(),
        description: col('description'),
        category: col('category').isEmpty ? 'General AI' : col('category'),
        subcategory: col('subcategory'),
        tags: col('tags'),
        aiModels: col('ai_models'),
        difficulty: col('difficulty').isEmpty ? 'Intermediate' : col('difficulty'),
        createdAt: now,
        modifiedAt: now,
      );
    }).toList();
  }

  Future<List<PromptModel>> importMarkdown(String path) async {
    final file = File(path);
    final content = await file.readAsString();
    final sections = content.split(RegExp(r'^## ', multiLine: true));
    final now = DateTime.now();

    return sections.where((s) => s.trim().isNotEmpty).map((section) {
      final lines = section.split('\n');
      final title = lines.first.trim();
      final body = section.contains('```')
          ? RegExp(r'```\n?([\s\S]*?)```').firstMatch(section)?.group(1)?.trim() ?? section
          : lines.skip(1).join('\n').trim();

      return PromptModel(
        id: Uuid().v4(),
        title: title,
        body: body,
        createdAt: now,
        modifiedAt: now,
      );
    }).toList();
  }

  Future<List<PromptModel>> importTxt(String path) async {
    final file = File(path);
    final content = await file.readAsString();
    final now = DateTime.now();
    final filename = p.basenameWithoutExtension(path);

    return [
      PromptModel(
        id: Uuid().v4(),
        title: filename,
        body: content.trim(),
        createdAt: now,
        modifiedAt: now,
      ),
    ];
  }

  Future<List<String>> listBackups() async {
    final dir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(p.join(dir.path, 'backups'));
    if (!await backupDir.exists()) return [];

    final files = await backupDir
        .list()
        .where((e) => e is File && e.path.endsWith('.json'))
        .map((e) => e.path)
        .toList();
    files.sort((a, b) => b.compareTo(a));
    return files;
  }
}
