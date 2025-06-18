import 'package:flutter/material.dart';
import '../models/summary_data.dart';
import '../models/shopping_item.dart';
import '../utils/currency.dart';
import 'shopping_item_card.dart';

class ExpandableSummaryCard extends StatefulWidget {
  final String title;
  final SummaryData summaryData;
  final List<ShoppingItem> items;
  final Color color;
  final IconData icon;

  const ExpandableSummaryCard({
    super.key,
    required this.title,
    required this.summaryData,
    required this.items,
    required this.color,
    required this.icon,
  });

  @override
  State<ExpandableSummaryCard> createState() => _ExpandableSummaryCardState();
}

class _ExpandableSummaryCardState extends State<ExpandableSummaryCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Summary Header
          InkWell(
            onTap: widget.items.isNotEmpty ? () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            } : null,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [widget.color, widget.color.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(widget.icon, color: Colors.white, size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (widget.items.isNotEmpty)
                        Icon(
                          _isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: Colors.white,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    CurrencyFormatter.format(widget.summaryData.totalAmount),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.summaryData.totalItems} items',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${widget.summaryData.totalQuantity} qty',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  if (widget.items.isNotEmpty)
                    const SizedBox(height: 8),
                  if (widget.items.isNotEmpty)
                    Text(
                      _isExpanded ? 'Tap untuk tutup detail' : 'Tap untuk lihat detail',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Expandable Items List
          if (_isExpanded && widget.items.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Detail Pembelian (${widget.items.length} items)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.items.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: ShoppingItemCard(
                          item: widget.items[index],
                          showActions: false,
                          showDate: true, onEdit: () {  }, onDelete: () {  },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
        ],
      ),
    );
  }
}