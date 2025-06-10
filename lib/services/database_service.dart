import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/report.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'ecoguardian.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE reports(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category INTEGER NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        imagePath TEXT,
        createdAt TEXT NOT NULL,
        status INTEGER NOT NULL,
        reporterName TEXT NOT NULL,
        reporterEmail TEXT
      )
    ''');
  }

  Future<int> insertReport(Report report) async {
    final db = await database;
    return await db.insert('reports', report.toJson());
  }

  Future<List<Report>> getAllReports() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('reports');
    return List.generate(maps.length, (i) {
      return Report.fromJson(maps[i]);
    });
  }

  Future<Report?> getReport(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reports',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Report.fromJson(maps.first);
    }
    return null;
  }

  Future<int> updateReport(Report report) async {
    final db = await database;
    return await db.update(
      'reports',
      report.toJson(),
      where: 'id = ?',
      whereArgs: [report.id],
    );
  }

  Future<int> deleteReport(String id) async {
    final db = await database;
    return await db.delete(
      'reports',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Report>> getReportsByCategory(ReportCategory category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reports',
      where: 'category = ?',
      whereArgs: [category.index],
    );
    return List.generate(maps.length, (i) {
      return Report.fromJson(maps[i]);
    });
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
} 