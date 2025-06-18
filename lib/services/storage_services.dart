import '../models/shopping_item.dart';
import 'database.dart';

class StorageService {
  static final DatabaseHelper _databaseHelper = DatabaseHelper();

  static Future<void> init() async {
    // Initialize database - akan otomatis dibuat saat pertama kali diakses
    await _databaseHelper.database;
  }

  static Future<int> addItem(ShoppingItem item) async {
    return await _databaseHelper.insertItem(item);
  }

  static Future<int> updateItem(ShoppingItem item) async {
    return await _databaseHelper.updateItem(item);
  }

  static Future<int> deleteItem(int id) async {
    return await _databaseHelper.deleteItem(id);
  }

  static Future<List<ShoppingItem>> getAllItems() async {
    return await _databaseHelper.getAllItems();
  }

  static Future<ShoppingItem?> getItem(int id) async {
    return await _databaseHelper.getItem(id);
  }

  static Future<int> clearAll() async {
    return await _databaseHelper.deleteAllItems();
  }

  static Future<void> close() async {
    await _databaseHelper.close();
  }
}
