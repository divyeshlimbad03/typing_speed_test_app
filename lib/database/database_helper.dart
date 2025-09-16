import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/typing_test_model.dart';
// Note: Removed user_stats_model.dart import - using basic calculations instead

// Simple Database Helper for Typing Speed Test App
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  // Get database connection
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  // Initialize database and create tables
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'typing_test.db');
    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  // Create all required tables
  Future<void> _createTables(Database db, int version) async {
    // Main typing tests table - stores complete test data
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

    // Note: Removed user_stats table - using basic calculations instead
  }

  // Save a typing test result (simplified - no user stats tracking)
  Future<void> saveTypingTest(TypingTestModel test) async {
    final db = await database;
    await db.insert('typing_tests', test.toMap());
    // Note: Removed user stats update - using basic calculations instead
  }

  // Get typing test history for a specific test type
  Future<List<TypingTestModel>> getTypingHistory(String testType) async {
    final db = await database;
    final maps = await db.query(
      'typing_tests',
      where: 'test_type = ?',
      whereArgs: [testType],
      orderBy: 'test_date DESC',
      limit: 50, // Only get recent 50 tests
    );
    return maps.map((map) => TypingTestModel.fromMap(map)).toList();
  }

  // Clear all history for a test type (simplified)
  Future<void> clearHistory(String testType) async {
    final db = await database;
    await db.delete(
      'typing_tests',
      where: 'test_type = ?',
      whereArgs: [testType],
    );
    // Note: No user_stats table to clear - using basic calculations
  }

  // Note: Removed getUserStats and _updateUserStats methods
  // Using basic calculations from history instead of separate user_stats table
}
