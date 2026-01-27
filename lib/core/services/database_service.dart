import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'agrivision.db');
    final db = await openDatabase(
      path, 
      version: 4, 
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
    await _seedData(db);
    await _seedEncyclopedia(db);
    return db;
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE notifications (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          description TEXT,
          icon TEXT,
          time TEXT,
          isUnread INTEGER DEFAULT 1
        )
      ''');
    }
    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE history ADD COLUMN isSynced INTEGER DEFAULT 0');
      } catch (e) {
        // Column might already exist if dev hot-reloaded awkwardly, ignore
      }
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE plants (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT UNIQUE,
          scientificName TEXT,
          indianName TEXT,
          description TEXT,
          uses TEXT,
          category TEXT
        )
      ''');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE diseases (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE treatments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        disease_name TEXT,
        type TEXT, -- Chemical, Organic, Prevention
        instruction TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        imagePath TEXT,
        diseaseName TEXT,
        confidence REAL,
        date TEXT,
        isSynced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        icon TEXT,
        time TEXT,
        isUnread INTEGER DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE chat_messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        message TEXT,
        isUser INTEGER,
        timestamp TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE plants (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE,
        scientificName TEXT,
        indianName TEXT,
        description TEXT,
        uses TEXT,
        category TEXT
      )
    ''');
  }

  Future<void> _seedData(Database db) async {
    // Check if seeded
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM diseases'));
    if (count != null && count > 0) return;

    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/treatments.json',
      );
      final Map<String, dynamic> data = json.decode(jsonString);

      for (var key in data.keys) {
        String diseaseName = key
            .replaceAll('___', ' ')
            .replaceAll('_', ' ')
            .replaceAll(RegExp(r'\s+'), ' ') 
            .trim();

        await db.insert('diseases', {
          'name': diseaseName,
          'description': 'Description for $diseaseName',
        }, conflictAlgorithm: ConflictAlgorithm.ignore);

        final treatment = data[key];

        if (treatment['chemical'] != null) {
          await db.insert('treatments', {
            'disease_name': diseaseName,
            'type': 'Chemical',
            'instruction': treatment['chemical'],
          });
        }
        if (treatment['organic'] != null) {
          await db.insert('treatments', {
            'disease_name': diseaseName,
            'type': 'Organic',
            'instruction': treatment['organic'],
          });
        }
        if (treatment['tips'] != null) {
          await db.insert('treatments', {
            'disease_name': diseaseName,
            'type': 'Prevention',
            'instruction': treatment['tips'],
          });
        }
      }
      
      // Seed initial notifications
      await db.insert('notifications', {
        'title': 'Welcome to Plantify! 🌱',
        'description': 'Start exploring your plants and diagnosing their health with our AI tools.',
        'icon': 'eco',
        'time': DateTime.now().toIso8601String(),
        'isUnread': 0,
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _seedEncyclopedia(Database db) async {
    // Check if seeded
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM plants'));
    if (count != null && count > 0) return;

    try {
      final jsonString = await rootBundle.loadString('assets/data/plant_encyclopedia.json');
      final Map<String, dynamic> data = json.decode(jsonString);

      if (data.containsKey('plants')) {
        final plantsData = data['plants'] as Map<String, dynamic>;
        for (var categoryEntry in plantsData.entries) {
          final String category = categoryEntry.key;
          final categoryData = categoryEntry.value as Map<String, dynamic>;
          
          for (var plantEntry in categoryData.entries) {
            final String name = plantEntry.key;
            final info = plantEntry.value as Map<String, dynamic>;
            
            await db.insert('plants', {
              'name': name,
              'scientificName': info['scientificName'],
              'indianName': info['indianName'],
              'description': info['description'],
              'uses': info['uses'],
              'category': category,
            }, conflictAlgorithm: ConflictAlgorithm.ignore);
          }
        }
      }
    } catch (e) {
      print('Seeding encyclopedia failed: $e');
    }
  }

  Future<Map<String, dynamic>?> getPlant(String name) async {
    final db = await database;
    final results = await db.query(
      'plants',
      where: 'name = ?',
      whereArgs: [name],
    );

    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getTreatments(String diseaseName) async {
    final db = await database;
    return await db.query(
      'treatments',
      where: 'disease_name = ?',
      whereArgs: [diseaseName],
    );
  }

  Future<int> saveScan(
    String imagePath,
    String diseaseName,
    double confidence, {
    bool isSynced = false,
  }) async {
    final db = await database;
    await db.insert('history', {
      'imagePath': imagePath,
      'diseaseName': diseaseName,
      'confidence': confidence,
      'date': DateTime.now().toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
    });
    return 1;
  }

  Future<List<Map<String, dynamic>>> getUnsyncedScans() async {
    final db = await database;
    return await db.query('history', where: 'isSynced = 0');
  }

  Future<void> markAsSynced(int id) async {
    final db = await database;
    await db.update(
      'history',
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getHistory() async {
    final db = await database;
    return await db.query('history', orderBy: 'date DESC');
  }

  Future<int> deleteHistoryItem(int id) async {
    final db = await database;
    return await db.delete('history', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> saveNotification({
    required String title,
    required String description,
    required String icon,
  }) async {
    final db = await database;
    return await db.insert('notifications', {
      'title': title,
      'description': description,
      'icon': icon,
      'time': DateTime.now().toIso8601String(),
      'isUnread': 1,
    });
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final db = await database;
    return await db.query('notifications', orderBy: 'time DESC');
  }

  // Chat Methods
  Future<void> saveChatMessage(String message, bool isUser) async {
    final db = await database;
    await db.insert('chat_messages', {
      'message': message,
      'isUser': isUser ? 1 : 0,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getChatMessages() async {
    final db = await database;
    return await db.query('chat_messages', orderBy: 'timestamp ASC');
  }

  Future<void> clearChatHistory() async {
    final db = await database;
    await db.delete('chat_messages');
  }
}
