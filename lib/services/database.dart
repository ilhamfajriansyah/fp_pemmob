import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/shopping_item.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'shopping_items.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE shopping_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
  }

  // Insert item
  Future<int> insertItem(ShoppingItem item) async {
    final db = await database;
    return await db.insert('shopping_items', item.toMap());
  }

  // Get all items
  Future<List<ShoppingItem>> getAllItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'shopping_items',
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return ShoppingItem.fromMap(maps[i]);
    });
  }

  // Get items by date range
  Future<List<ShoppingItem>> getItemsByDateRange(DateTime startDate, DateTime endDate) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'shopping_items',
      where: 'created_at >= ? AND created_at <= ?',
      whereArgs: [startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return ShoppingItem.fromMap(maps[i]);
    });
  }

  // Get summary by date range
  Future<Map<String, dynamic>> getSummaryByDateRange(DateTime startDate, DateTime endDate) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_items,
        SUM(quantity) as total_quantity,
        SUM(quantity * price) as total_amount
      FROM shopping_items 
      WHERE created_at >= ? AND created_at <= ?
    ''', [startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch]);

    return result.first;
  }

  // Get daily summary for a specific month
  Future<List<Map<String, dynamic>>> getDailySummaryForMonth(DateTime month) async {
    final db = await database;
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
        DATE(created_at / 1000, 'unixepoch', 'localtime') as date,
        COUNT(*) as total_items,
        SUM(quantity) as total_quantity,
        SUM(quantity * price) as total_amount
      FROM shopping_items 
      WHERE created_at >= ? AND created_at <= ?
      GROUP BY DATE(created_at / 1000, 'unixepoch', 'localtime')
      ORDER BY date DESC
    ''', [startOfMonth.millisecondsSinceEpoch, endOfMonth.millisecondsSinceEpoch]);

    return result;
  }

  // Update item
  Future<int> updateItem(ShoppingItem item) async {
    final db = await database;
    return await db.update(
      'shopping_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  // Delete item
  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete(
      'shopping_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete all items
  Future<int> deleteAllItems() async {
    final db = await database;
    return await db.delete('shopping_items');
  }

  // Get item by id
  Future<ShoppingItem?> getItem(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'shopping_items',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return ShoppingItem.fromMap(maps.first);
    }
    return null;
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}