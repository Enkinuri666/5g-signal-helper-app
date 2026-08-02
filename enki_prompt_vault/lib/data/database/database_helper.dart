import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/constants/app_constants.dart';
import 'schema.dart';
import 'seed_data.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._();

  factory DatabaseHelper() => _instance ??= DatabaseHelper._();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, AppConstants.dbName);
    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onConfigure: (db) async {
        // PRAGMA journal_mode returns a row, so it must run through rawQuery;
        // execute() throws "Queries can be performed using ... query or
        // rawQuery methods only" on Android.
        await db.rawQuery('PRAGMA journal_mode=WAL');
        await db.execute('PRAGMA synchronous=NORMAL');
        await db.execute('PRAGMA foreign_keys=ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();
    for (final sql in DatabaseSchema.createStatements) {
      batch.execute(sql);
    }
    await batch.commit(noResult: true);

    await SeedData.insertDefaults(db);
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
