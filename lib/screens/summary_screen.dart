import 'package:flutter/material.dart';
import '../models/summary_data.dart';
import '../models/shopping_item.dart';
import '../services/summary_service.dart';
import '../widget/expandable_summary_card.dart';
import '../widget/date_range_picker.dart';
import '../widget/shopping_item_card.dart';
import '../utils/currency.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  // Summary data with items
  SummaryData? _dailySummary;
  List<ShoppingItem> _dailyItems = [];

  SummaryData? _weeklySummary;
  List<ShoppingItem> _weeklyItems = [];

  SummaryData? _monthlySummary;
  List<ShoppingItem> _monthlyItems = [];

  SummaryData? _yearlySummary;
  List<ShoppingItem> _yearlyItems = [];

  // Custom filter
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  SummaryData? _customSummary;
  List<ShoppingItem> _customItems = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSummaryData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSummaryData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait([
        SummaryService.getTodaySummaryWithItems(),
        SummaryService.getWeeklySummaryWithItems(),
        SummaryService.getMonthlySummaryWithItems(),
        SummaryService.getYearlySummaryWithItems(),
      ]);

      setState(() {
        _dailySummary = results[0]['summary'];
        _dailyItems = results[0]['items'];

        _weeklySummary = results[1]['summary'];
        _weeklyItems = results[1]['items'];

        _monthlySummary = results[2]['summary'];
        _monthlyItems = results[2]['items'];

        _yearlySummary = results[3]['summary'];
        _yearlyItems = results[3]['items'];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading summary: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCustomSummary() async {
    if (_customStartDate == null || _customEndDate == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await SummaryService.getSummaryWithItemsByDateRange(
        _customStartDate!,
        _customEndDate!,
      );

      setState(() {
        _customSummary = result['summary'];
        _customItems = result['items'];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading custom summary: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onDateRangeSelected(DateTime? startDate, DateTime? endDate) {
    setState(() {
      _customStartDate = startDate;
      _customEndDate = endDate;
      if (startDate == null || endDate == null) {
        _customSummary = null;
        _customItems = [];
      }
    });

    if (startDate != null && endDate != null) {
      _loadCustomSummary();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ringkasan Belanja'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Ringkasan'),
            Tab(text: 'Filter Custom'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildSummaryTab(),
          _buildCustomFilterTab(),
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
    return RefreshIndicator(
      onRefresh: _loadSummaryData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_dailySummary != null)
              ExpandableSummaryCard(
                title: 'Hari Ini',
                summaryData: _dailySummary!,
                items: _dailyItems,
                color: Colors.green.shade600,
                icon: Icons.today,
              ),
            const SizedBox(height: 16),
            if (_weeklySummary != null)
              ExpandableSummaryCard(
                title: 'Minggu Ini',
                summaryData: _weeklySummary!,
                items: _weeklyItems,
                color: Colors.blue.shade600,
                icon: Icons.date_range,
              ),
            const SizedBox(height: 16),
            if (_monthlySummary != null)
              ExpandableSummaryCard(
                title: 'Bulan Ini',
                summaryData: _monthlySummary!,
                items: _monthlyItems,
                color: Colors.orange.shade600,
                icon: Icons.calendar_month,
              ),
            const SizedBox(height: 16),
            if (_yearlySummary != null)
              ExpandableSummaryCard(
                title: 'Tahun Ini',
                summaryData: _yearlySummary!,
                items: _yearlyItems,
                color: Colors.purple.shade600,
                icon: Icons.calendar_today,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomFilterTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          DateRangePicker(
            startDate: _customStartDate,
            endDate: _customEndDate,
            onDateRangeSelected: _onDateRangeSelected,
          ),
          if (_customSummary != null) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal.shade600, Colors.teal.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.shade200,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Total Periode',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    CurrencyFormatter.format(_customSummary!.totalAmount),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text(
                            '${_customSummary!.totalItems}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Items',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '${_customSummary!.totalQuantity}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Quantity',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_customItems.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text(
                      'Detail Pembelian',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_customItems.length} items',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _customItems.length,
                itemBuilder: (context, index) {
                  return ShoppingItemCard(
                    item: _customItems[index],
                    showActions: false,
                    showDate: true, onEdit: () {  }, onDelete: () {  },
                  );
                },
              ),
            ] else if (_customSummary != null) ...[
              const Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Tidak ada pembelian pada periode ini',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}