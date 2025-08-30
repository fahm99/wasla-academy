import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/course.dart';
import '../models/user.dart';
import '../models/enrollment.dart';
import '../models/category.dart';

/// Local Database Service
/// This service manages local SQLite database operations for offline functionality
class LocalDatabaseService {
  static final LocalDatabaseService _instance = LocalDatabaseService._internal();
  factory LocalDatabaseService() => _instance;
  LocalDatabaseService._internal();

  static Database? _database;
  final String _dbName = 'wasla_local.db';

  /// Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  /// Create database tables
  Future<void> _createDB(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        phone TEXT,
        avatar TEXT,
        bio TEXT,
        role TEXT NOT NULL,
        account_type TEXT,
        institution_name TEXT,
        institution_license TEXT,
        specialization TEXT,
        experience_years INTEGER,
        email_verified INTEGER DEFAULT 0,
        verification_status TEXT,
        is_active INTEGER DEFAULT 1,
        last_login_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create categories table
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        icon TEXT,
        parent_id TEXT,
        courses_count INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create courses table
    await db.execute('''
      CREATE TABLE courses (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        thumbnail TEXT,
        instructor_id TEXT NOT NULL,
        instructor_name TEXT NOT NULL,
        instructor_avatar TEXT,
        status TEXT NOT NULL,
        level TEXT NOT NULL,
        price REAL NOT NULL,
        discount_price REAL,
        duration INTEGER NOT NULL,
        lessons_count INTEGER NOT NULL,
        rating REAL DEFAULT 0.0,
        reviews_count INTEGER DEFAULT 0,
        enrolled_count INTEGER DEFAULT 0,
        category TEXT,
        tags TEXT,
        is_featured INTEGER DEFAULT 0,
        published_at TEXT,
        metadata TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create enrollments table
    await db.execute('''
      CREATE TABLE enrollments (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        course_id TEXT NOT NULL,
        enrolled_at TEXT NOT NULL,
        completed_at TEXT,
        progress INTEGER NOT NULL DEFAULT 0,
        last_accessed_at TEXT,
        UNIQUE(user_id, course_id)
      )
    ''');

    // Create offline_data table for caching API responses
    await db.execute('''
      CREATE TABLE offline_data (
        id TEXT PRIMARY KEY,
        endpoint TEXT NOT NULL,
        data TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
  }

  /// Insert or update user
  Future<void> saveUser(User user) async {
    final db = await database;
    await db.insert(
      'users',
      user.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get user by ID
  Future<User?> getUser(String id) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return User.fromJson(result.first);
    }
    return null;
  }

  /// Insert or update category
  Future<void> saveCategory(Category category) async {
    final db = await database;
    await db.insert(
      'categories',
      category.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all categories
  Future<List<Category>> getCategories() async {
    final db = await database;
    final result = await db.query('categories');
    return result.map((json) => Category.fromJson(json)).toList();
  }

  /// Insert or update course
  Future<void> saveCourse(Course course) async {
    final db = await database;
    await db.insert(
      'courses',
      course.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get course by ID
  Future<Course?> getCourse(String id) async {
    final db = await database;
    final result = await db.query(
      'courses',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return Course.fromJson(result.first);
    }
    return null;
  }

  /// Get all courses
  Future<List<Course>> getCourses() async {
    final db = await database;
    final result = await db.query('courses');
    return result.map((json) => Course.fromJson(json)).toList();
  }

  /// Insert or update enrollment
  Future<void> saveEnrollment(Enrollment enrollment) async {
    final db = await database;
    await db.insert(
      'enrollments',
      enrollment.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get enrollments by user ID
  Future<List<Enrollment>> getEnrollmentsByUser(String userId) async {
    final db = await database;
    final result = await db.query(
      'enrollments',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return result.map((json) => Enrollment.fromJson(json)).toList();
  }

  /// Cache API response for offline use
  Future<void> cacheApiResponse(String endpoint, String data) async {
    final db = await database;
    final cacheData = {
      'id': endpoint,
      'endpoint': endpoint,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await db.insert(
      'offline_data',
      cacheData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get cached API response
  Future<String?> getCachedApiResponse(String endpoint) async {
    final db = await database;
    final result = await db.query(
      'offline_data',
      where: 'endpoint = ?',
      whereArgs: [endpoint],
    );

    if (result.isNotEmpty) {
      return result.first['data'] as String?;
    }
    return null;
  }

  /// Clear old cached data
  Future<void> clearOldCache({int daysOld = 7}) async {
    final db = await database;
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
    await db.delete(
      'offline_data',
      where: 'timestamp < ?',
      whereArgs: [cutoffDate.toIso8601String()],
    );
  }

  /// Clear all cached data
  Future<void> clearAllCache() async {
    final db = await database;
    await db.delete('offline_data');
  }

  /// Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}