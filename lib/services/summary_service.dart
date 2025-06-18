import '../models/shopping_item.dart';
import '../models/summary_data.dart';
import 'database.dart';

class SummaryService {
  static final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Get summary for today with items
  static Future<Map<String, dynamic>> getTodaySummaryWithItems() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return await getSummaryWithItemsByDateRange(startOfDay, endOfDay);
  }

  // Get summary for this week with items
  static Future<Map<String, dynamic>> getWeeklySummaryWithItems() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final endOfWeek = startOfWeekDay.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

    return await getSummaryWithItemsByDateRange(startOfWeekDay, endOfWeek);
  }

  // Get summary for this month with items
  static Future<Map<String, dynamic>> getMonthlySummaryWithItems() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return await getSummaryWithItemsByDateRange(startOfMonth, endOfMonth);
  }

  // Get summary for this year with items
  static Future<Map<String, dynamic>> getYearlySummaryWithItems() async {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31, 23, 59, 59);

    return await getSummaryWithItemsByDateRange(startOfYear, endOfYear);
  }

  // Get summary with items by custom date range
  static Future<Map<String, dynamic>> getSummaryWithItemsByDateRange(DateTime startDate, DateTime endDate) async {
    // Adjust end date to include the entire day
    final adjustedEndDate = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

    final summary = await _databaseHelper.getSummaryByDateRange(startDate, adjustedEndDate);
    final items = await _databaseHelper.getItemsByDateRange(startDate, adjustedEndDate);

    final summaryData = SummaryData(
      totalAmount: (summary['total_amount'] ?? 0.0).toDouble(),
      totalItems: (summary['total_items'] ?? 0).toInt(),
      totalQuantity: (summary['total_quantity'] ?? 0).toInt(),
      startDate: startDate,
      endDate: adjustedEndDate,
    );

    return {
      'summary': summaryData,
      'items': items,
    };
  }

  // Legacy methods for backward compatibility
  static Future<SummaryData> getTodaySummary() async {
    final result = await getTodaySummaryWithItems();
    return result['summary'];
  }

  static Future<SummaryData> getWeeklySummary() async {
    final result = await getWeeklySummaryWithItems();
    return result['summary'];
  }

  static Future<SummaryData> getMonthlySummary() async {
    final result = await getMonthlySummaryWithItems();
    return result['summary'];
  }

  static Future<SummaryData> getYearlySummary() async {
    final result = await getYearlySummaryWithItems();
    return result['summary'];
  }

  static Future<SummaryData> getSummaryByDateRange(DateTime startDate, DateTime endDate) async {
    final result = await getSummaryWithItemsByDateRange(startDate, endDate);
    return result['summary'];
  }

  static Future<List<ShoppingItem>> getItemsByDateRange(DateTime startDate, DateTime endDate) async {
    final result = await getSummaryWithItemsByDateRange(startDate, endDate);
    return result['items'];
  }

  // Get daily summary for chart
  static Future<List<Map<String, dynamic>>> getDailySummaryForMonth(DateTime month) async {
    return await _databaseHelper.getDailySummaryForMonth(month);
  }
}
