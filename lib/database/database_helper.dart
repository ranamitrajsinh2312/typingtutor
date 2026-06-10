import 'package:typingtutor/import_export.dart';
import 'package:path/path.dart';
import 'package:typingtutor/constants/app_constants.dart';

class DatabaseHelper {
  static const _databaseName = AppConstants.databaseName;
  static const _databaseVersion = 4; // v4: language_code added to records
  static const String tableName = AppConstants.recordsTableName;
  static const String keyboardLessonsTable = 'keyboard_lessons';
  static const String levelProgressTable = 'level_progress';

  static Database? _database;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create typing records table
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        country TEXT NOT NULL,
        wpm INTEGER NOT NULL,
        accuracy REAL NOT NULL,
        created_at INTEGER NOT NULL,
        language_code TEXT NOT NULL DEFAULT 'en'
      )
    ''');

    // Create keyboard lessons progress table
    await db.execute('''
      CREATE TABLE $keyboardLessonsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lessonId INTEGER NOT NULL,
        languageCode TEXT NOT NULL,
        isCompleted INTEGER DEFAULT 0,
        starsEarned INTEGER DEFAULT 0,
        bestWpm INTEGER DEFAULT 0,
        bestAccuracy REAL DEFAULT 0.0,
        lastAttemptAt INTEGER,
        totalAttempts INTEGER DEFAULT 0,
        UNIQUE(lessonId, languageCode)
      )
    ''');

    // Create level progress table for Words/Sentences/Paragraphs
    await db.execute('''
      CREATE TABLE $levelProgressTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        levelId INTEGER NOT NULL,
        practiceType TEXT NOT NULL,
        languageCode TEXT NOT NULL,
        isCompleted INTEGER DEFAULT 0,
        starsEarned INTEGER DEFAULT 0,
        bestWpm INTEGER DEFAULT 0,
        bestAccuracy REAL DEFAULT 0.0,
        lastAttemptAt INTEGER,
        totalAttempts INTEGER DEFAULT 0,
        UNIQUE(levelId, practiceType, languageCode)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add keyboard lessons table for upgrade from version 1
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $keyboardLessonsTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          lessonId INTEGER NOT NULL,
          languageCode TEXT NOT NULL,
          isCompleted INTEGER DEFAULT 0,
          starsEarned INTEGER DEFAULT 0,
          bestWpm INTEGER DEFAULT 0,
          bestAccuracy REAL DEFAULT 0.0,
          lastAttemptAt INTEGER,
          totalAttempts INTEGER DEFAULT 0,
          UNIQUE(lessonId, languageCode)
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $levelProgressTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          levelId INTEGER NOT NULL,
          practiceType TEXT NOT NULL,
          languageCode TEXT NOT NULL,
          isCompleted INTEGER DEFAULT 0,
          starsEarned INTEGER DEFAULT 0,
          bestWpm INTEGER DEFAULT 0,
          bestAccuracy REAL DEFAULT 0.0,
          lastAttemptAt INTEGER,
          totalAttempts INTEGER DEFAULT 0,
          UNIQUE(levelId, practiceType, languageCode)
        )
      ''');
    }
    if (oldVersion < 4) {
      // Add language_code column to typing records (v4)
      try {
        await db.execute(
          "ALTER TABLE $tableName ADD COLUMN language_code TEXT NOT NULL DEFAULT 'en'",
        );
      } catch (_) {
        // Column may already exist — safe to ignore
      }
    }
  }

  // ── Language-wise stats ──────────────────────────────────────────────────
  /// Returns a map: languageCode → { 'avg_wpm', 'best_wpm', 'avg_accuracy', 'total' }
  Future<Map<String, Map<String, double>>> getStatsByLanguage() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT
        language_code,
        AVG(wpm)      AS avg_wpm,
        MAX(wpm)      AS best_wpm,
        AVG(accuracy) AS avg_accuracy,
        COUNT(*)      AS total
      FROM $tableName
      GROUP BY language_code
    ''');
    final result = <String, Map<String, double>>{};
    for (final r in rows) {
      final lang = (r['language_code'] as String?) ?? 'en';
      result[lang] = {
        'avg_wpm':      (r['avg_wpm']      as num?)?.toDouble() ?? 0,
        'best_wpm':     (r['best_wpm']     as num?)?.toDouble() ?? 0,
        'avg_accuracy': (r['avg_accuracy'] as num?)?.toDouble() ?? 0,
        'total':        (r['total']        as num?)?.toDouble() ?? 0,
      };
    }
    return result;
  }

  // Insert a new typing record
  Future<int> insertRecord(TypingRecord record) async {
    final db = await database;
    return await db.insert(tableName, record.toMap());
  }

  // Fetch all typing records
  Future<List<TypingRecord>> fetchAllRecords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return TypingRecord.fromMap(maps[i]);
    });
  }

  // Fetch the latest record
  Future<TypingRecord?> fetchLatestRecord() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return TypingRecord.fromMap(maps.first);
    }
    return null;
  }

  // Get best WPM and average accuracy statistics
  Future<TypingStats> getStats() async {
    final db = await database;

    // Get best WPM and average WPM
    final wpmResult = await db.rawQuery(
      'SELECT MAX(wpm) as best_wpm, AVG(wpm) as avg_wpm FROM $tableName',
    );
    final int bestWpm = (wpmResult.first['best_wpm'] as int?) ?? 0;
    final int avgWpm = ((wpmResult.first['avg_wpm'] as num?)?.round()) ?? 0;

    // Get average accuracy and total attempts
    final avgResult = await db.rawQuery(
      'SELECT AVG(accuracy) as avg_accuracy, COUNT(*) as total_attempts FROM $tableName',
    );
    final double avgAccuracy =
        (avgResult.first['avg_accuracy'] as num?)?.toDouble() ?? 0.0;
    final int totalAttempts = (avgResult.first['total_attempts'] as int?) ?? 0;

    return TypingStats(
      bestWpm: bestWpm,
      avgWpm: avgWpm,
      avgAccuracy: avgAccuracy,
      totalAttempts: totalAttempts,
    );
  }

  // Get records by username
  Future<List<TypingRecord>> getRecordsByUsername(String username) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'username = ?',
      whereArgs: [username],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return TypingRecord.fromMap(maps[i]);
    });
  }

  // Get user's best WPM
  Future<int> getUserBestWpm(String username) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT MAX(wpm) as best_wpm FROM $tableName WHERE username = ?',
      [username],
    );
    return (result.first['best_wpm'] as int?) ?? 0;
  }

  // Get user's average accuracy
  Future<double> getUserAvgAccuracy(String username) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT AVG(accuracy) as avg_accuracy FROM $tableName WHERE username = ?',
      [username],
    );
    return (result.first['avg_accuracy'] as num?)?.toDouble() ?? 0.0;
  }

  // Get user's total attempts
  Future<int> getUserTotalAttempts(String username) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as total_attempts FROM $tableName WHERE username = ?',
      [username],
    );
    return (result.first['total_attempts'] as int?) ?? 0;
  }

  // Reset all data (delete all records)
  Future<void> resetData() async {
    final db = await database;
    await db.delete(tableName);
  }

  // Reset data for specific user
  Future<void> resetUserData(String username) async {
    final db = await database;
    await db.delete(tableName, where: 'username = ?', whereArgs: [username]);
  }

  // Close the database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  // =========================================================================
  // ⌨️ KEYBOARD LESSON PROGRESS METHODS
  // =========================================================================

  // Save or update keyboard lesson progress
  Future<void> saveKeyboardLessonProgress({
    required int lessonId,
    required String languageCode,
    required bool isCompleted,
    required int starsEarned,
    required int wpm,
    required double accuracy,
  }) async {
    final db = await database;

    // Check if record exists
    final existing = await db.query(
      keyboardLessonsTable,
      where: 'lessonId = ? AND languageCode = ?',
      whereArgs: [lessonId, languageCode],
    );

    if (existing.isEmpty) {
      // Insert new record
      await db.insert(keyboardLessonsTable, {
        'lessonId': lessonId,
        'languageCode': languageCode,
        'isCompleted': isCompleted ? 1 : 0,
        'starsEarned': starsEarned,
        'bestWpm': wpm,
        'bestAccuracy': accuracy,
        'lastAttemptAt': DateTime.now().millisecondsSinceEpoch,
        'totalAttempts': 1,
      });
    } else {
      // Update existing record (keep best scores)
      final currentBestWpm = existing.first['bestWpm'] as int? ?? 0;
      final currentBestAccuracy =
          (existing.first['bestAccuracy'] as num?)?.toDouble() ?? 0.0;
      final currentStars = existing.first['starsEarned'] as int? ?? 0;
      final currentAttempts = existing.first['totalAttempts'] as int? ?? 0;

      await db.update(
        keyboardLessonsTable,
        {
          'isCompleted': 1,
          'starsEarned':
              starsEarned > currentStars ? starsEarned : currentStars,
          'bestWpm': wpm > currentBestWpm ? wpm : currentBestWpm,
          'bestAccuracy':
              accuracy > currentBestAccuracy ? accuracy : currentBestAccuracy,
          'lastAttemptAt': DateTime.now().millisecondsSinceEpoch,
          'totalAttempts': currentAttempts + 1,
        },
        where: 'lessonId = ? AND languageCode = ?',
        whereArgs: [lessonId, languageCode],
      );
    }
  }

  // Get keyboard lesson progress
  Future<Map<String, dynamic>?> getKeyboardLessonProgress(
    int lessonId,
    String languageCode,
  ) async {
    final db = await database;
    final results = await db.query(
      keyboardLessonsTable,
      where: 'lessonId = ? AND languageCode = ?',
      whereArgs: [lessonId, languageCode],
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Get all keyboard lesson progress for a language
  Future<List<Map<String, dynamic>>> getAllKeyboardLessonProgress(
    String languageCode,
  ) async {
    final db = await database;
    return await db.query(
      keyboardLessonsTable,
      where: 'languageCode = ?',
      whereArgs: [languageCode],
      orderBy: 'lessonId ASC',
    );
  }

  // Get total stars earned for a language
  Future<int> getTotalStarsForLanguage(String languageCode) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(starsEarned) as totalStars FROM $keyboardLessonsTable WHERE languageCode = ?',
      [languageCode],
    );
    return (result.first['totalStars'] as int?) ?? 0;
  }

  // Get completed lessons count for a language
  Future<int> getCompletedLessonsCount(String languageCode) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $keyboardLessonsTable WHERE languageCode = ? AND isCompleted = 1',
      [languageCode],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  // Check if a lesson is unlocked based on previous completion
  Future<bool> isLessonUnlocked(
    int lessonId,
    String languageCode,
    int previousLessonId,
  ) async {
    if (lessonId == 1 || lessonId == 101 || lessonId == 201) {
      return true; // First lesson of each language is always unlocked
    }

    final progress = await getKeyboardLessonProgress(
      previousLessonId,
      languageCode,
    );
    return progress != null && (progress['isCompleted'] as int) == 1;
  }

  // Reset keyboard lesson progress for a language
  Future<void> resetKeyboardLessonProgress(String languageCode) async {
    final db = await database;
    await db.delete(
      keyboardLessonsTable,
      where: 'languageCode = ?',
      whereArgs: [languageCode],
    );
  }

  // Get best WPM across all keyboard lessons
  Future<int> getBestKeyboardLessonWpm() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT MAX(bestWpm) as maxWpm FROM $keyboardLessonsTable',
    );
    return (result.first['maxWpm'] as int?) ?? 0;
  }

  // Get average accuracy across all keyboard lessons
  Future<double> getAverageKeyboardLessonAccuracy() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT AVG(bestAccuracy) as avgAccuracy FROM $keyboardLessonsTable WHERE isCompleted = 1',
    );
    return (result.first['avgAccuracy'] as num?)?.toDouble() ?? 0.0;
  }

  // =========================================================================
  // 📊 LEVEL PROGRESS METHODS (Words/Sentences/Paragraphs)
  // =========================================================================

  // Save or update level progress
  Future<void> saveLevelProgress({
    required int levelId,
    required String practiceType,
    required String languageCode,
    required bool isCompleted,
    required int starsEarned,
    required int wpm,
    required double accuracy,
  }) async {
    final db = await database;

    // Check if record exists
    final existing = await db.query(
      levelProgressTable,
      where: 'levelId = ? AND practiceType = ? AND languageCode = ?',
      whereArgs: [levelId, practiceType, languageCode],
    );

    if (existing.isEmpty) {
      // Insert new record
      await db.insert(levelProgressTable, {
        'levelId': levelId,
        'practiceType': practiceType,
        'languageCode': languageCode,
        'isCompleted': isCompleted ? 1 : 0,
        'starsEarned': starsEarned,
        'bestWpm': wpm,
        'bestAccuracy': accuracy,
        'lastAttemptAt': DateTime.now().millisecondsSinceEpoch,
        'totalAttempts': 1,
      });
    } else {
      // Update existing record (keep best scores)
      final currentBestWpm = existing.first['bestWpm'] as int? ?? 0;
      final currentBestAccuracy =
          (existing.first['bestAccuracy'] as num?)?.toDouble() ?? 0.0;
      final currentStars = existing.first['starsEarned'] as int? ?? 0;
      final currentAttempts = existing.first['totalAttempts'] as int? ?? 0;

      await db.update(
        levelProgressTable,
        {
          'isCompleted': 1,
          'starsEarned':
              starsEarned > currentStars ? starsEarned : currentStars,
          'bestWpm': wpm > currentBestWpm ? wpm : currentBestWpm,
          'bestAccuracy':
              accuracy > currentBestAccuracy ? accuracy : currentBestAccuracy,
          'lastAttemptAt': DateTime.now().millisecondsSinceEpoch,
          'totalAttempts': currentAttempts + 1,
        },
        where: 'levelId = ? AND practiceType = ? AND languageCode = ?',
        whereArgs: [levelId, practiceType, languageCode],
      );
    }
  }

  // Get level progress
  Future<Map<String, dynamic>?> getLevelProgress(
    int levelId,
    String practiceType,
    String languageCode,
  ) async {
    final db = await database;
    final results = await db.query(
      levelProgressTable,
      where: 'levelId = ? AND practiceType = ? AND languageCode = ?',
      whereArgs: [levelId, practiceType, languageCode],
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Get all level progress for a practice type and language
  Future<List<Map<String, dynamic>>> getAllLevelProgress(
    String practiceType,
    String languageCode,
  ) async {
    final db = await database;
    return await db.query(
      levelProgressTable,
      where: 'practiceType = ? AND languageCode = ?',
      whereArgs: [practiceType, languageCode],
      orderBy: 'levelId ASC',
    );
  }

  // Get total stars earned for a practice type
  Future<int> getTotalStarsForPracticeType(
    String practiceType,
    String languageCode,
  ) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(starsEarned) as totalStars FROM $levelProgressTable WHERE practiceType = ? AND languageCode = ?',
      [practiceType, languageCode],
    );
    return (result.first['totalStars'] as int?) ?? 0;
  }

  // Get completed levels count for a practice type
  Future<int> getCompletedLevelsCount(
    String practiceType,
    String languageCode,
  ) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $levelProgressTable WHERE practiceType = ? AND languageCode = ? AND isCompleted = 1',
      [practiceType, languageCode],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  // Get best WPM across all levels
  Future<int> getBestLevelWpm() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT MAX(bestWpm) as maxWpm FROM $levelProgressTable',
    );
    return (result.first['maxWpm'] as int?) ?? 0;
  }

  // Get average accuracy across all completed levels
  Future<double> getAverageLevelAccuracy() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT AVG(bestAccuracy) as avgAccuracy FROM $levelProgressTable WHERE isCompleted = 1',
    );
    return (result.first['avgAccuracy'] as num?)?.toDouble() ?? 0.0;
  }

  // Reset level progress for a practice type and language
  Future<void> resetLevelProgress(
    String practiceType,
    String languageCode,
  ) async {
    final db = await database;
    await db.delete(
      levelProgressTable,
      where: 'practiceType = ? AND languageCode = ?',
      whereArgs: [practiceType, languageCode],
    );
  }
}
