import 'package:typing_speed_test_app/import_export_file.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'typing_test.db');
    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE typing_tests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        test_type TEXT NOT NULL,
        original_text TEXT NOT NULL,
        typed_text TEXT NOT NULL,
        wpm REAL NOT NULL,
        accuracy REAL NOT NULL,
        correct_words INTEGER NOT NULL,
        wrong_words INTEGER NOT NULL,
        total_words INTEGER NOT NULL,
        time_seconds INTEGER NOT NULL,
        test_date TEXT NOT NULL
      )
    ''');
  }

  Future<void> saveTypingTest(TypingTestModel test) async {
    final db = await database;
    await db.insert('typing_tests', test.toMap());
  }

  Future<List<TypingTestModel>> getTypingHistory(String testType) async {
    final db = await database;
    final maps = await db.query(
      'typing_tests',
      where: 'test_type = ?',
      whereArgs: [testType],
      orderBy: 'test_date DESC',
      limit: 50,
    );
    return maps.map((map) => TypingTestModel.fromMap(map)).toList();
  }

  Future<void> clearHistory(String testType) async {
    final db = await database;
    await db.delete(
      'typing_tests',
      where: 'test_type = ?',
      whereArgs: [testType],
    );
  }

  Future<void> cleanupFiniteWordRecords() async {
    final db = await database;
    await db.delete(
      'typing_tests',
      where: 'test_type = ? AND (total_words = ? OR total_words = ?)',
      whereArgs: ['word', 25, 50],
    );
  }
}
