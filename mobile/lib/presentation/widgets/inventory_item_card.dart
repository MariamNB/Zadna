import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../providers.dart';
import '../../data/models/inventory_item.dart';
import '../../core/kitchen_theme.dart';

class InventoryItemCard extends ConsumerWidget {
  final InventoryItem item;
  const InventoryItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (_, accent) = KT.cardPairFor(item.categoryKey);

    final quantity = num.tryParse(item.quantity);
    final quantityLabel = quantity == null
        ? item.quantity
        : NumberFormat('0.###').format(quantity);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _showDetail(context, ref),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 5,
                height: 56,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: KT.poppins(size: 15, weight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                      '${item.category.labels['en'] ?? item.categoryKey} · ${item.storageLocation.name}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: KT.poppins(size: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 10,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _StatusDot(status: item.status, accent: accent),
                        if (item.expiresAt != null)
                          _ExpiryTag(dateStr: item.expiresAt!, accent: accent),
                        if (item.isHomemade)
                          Text('Homemade', style: KT.poppins(size: 10, color: accent)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(quantityLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: KT.poppins(size: 16, weight: FontWeight.w700)),
                    Text(item.unit.labels['en'] ?? item.unitKey,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: KT.poppins(size: 11, color: Colors.black54)),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, size: 18, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, WidgetRef ref) {
    final (fill, accent) = KT.cardPairFor(item.categoryKey);
    final fmt = DateFormat.yMMMd();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: fill,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (_, sc) => SingleChildScrollView(
            controller: sc,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.category.labels['en'] ?? item.categoryKey,
                        style: KT.poppins(size: 11, weight: FontWeight.w700, color: Colors.white),
                      ),
                    ),
                    const Spacer(),
                    _StatusDot(status: item.status, accent: accent, large: true),
                  ],
                ),
                const SizedBox(height: 12),
                Text(item.name,
                    style: KT.poppins(size: 24, weight: FontWeight.w800, color: KT.kDarkBlue)),
                const SizedBox(height: 16),
                Divider(color: accent.withOpacity(0.3), thickness: 1.5),
                const SizedBox(height: 12),
                _Row('Quantity', '${item.quantity} ${item.unit.labels['en'] ?? item.unitKey}', accent),
                _Row('Location', item.storageLocation.name, accent),
                _Row('Added', fmt.format(DateTime.parse(item.dateAdded)), accent),
                if (item.preparedAt != null) _Row('Prepared', fmt.format(DateTime.parse(item.preparedAt!)), accent, icon: '👨‍🍳'),
                if (item.frozenAt != null)   _Row('Frozen',   fmt.format(DateTime.parse(item.frozenAt!)),   accent, icon: '❄️'),
                if (item.openedAt != null)   _Row('Opened',   fmt.format(DateTime.parse(item.openedAt!)),   accent),
                if (item.expiresAt != null)  _Row('Expires',  fmt.format(DateTime.parse(item.expiresAt!)),  accent, icon: '⏰'),
                if (item.isHomemade)         _Row('Type',     '🏠 Homemade', accent),
                if (item.notes != null && item.notes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: accent.withOpacity(0.25)),
                    ),
                    child: Text(
                      item.notes!,
                      style: KT.poppins(size: 13, color: KT.kDarkBlue, style: FontStyle.italic),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Row(children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.edit_outlined, color: accent),
                      label: Text('Edit', style: KT.poppins(weight: FontWeight.w600, color: accent)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: accent, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        await ref.read(inventoryNotifierProvider.notifier).deleteItem(item.id);
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: Text('Remove', style: KT.poppins(weight: FontWeight.w700, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KT.kRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  final String? icon;
  const _Row(this.label, this.value, this.accent, {this.icon});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 88,
              child: Text(
                icon != null ? '$icon $label' : label,
                style: KT.poppins(size: 12, weight: FontWeight.w600, color: Colors.black45),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(value,
                  style: KT.poppins(size: 13, weight: FontWeight.w600, color: KT.kDarkBlue)),
            ),
          ],
        ),
      );
}

class _ExpiryTag extends StatelessWidget {
  final String dateStr;
  final Color accent;
  const _ExpiryTag({required this.dateStr, required this.accent});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return const SizedBox.shrink();
    final diff = date.difference(DateTime.now()).inDays;
    final urgent = diff < 3;
    final label = diff < 0
        ? 'Expired'
        : diff == 0
            ? 'Expires today'
            : 'Exp ${DateFormat.MMMd().format(date)}';
    final color = urgent ? KT.kRed : accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label,
          style: KT.poppins(size: 10, weight: FontWeight.w700, color: color)),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final String status;
  final Color accent;
  final bool large;
  const _StatusDot({required this.status, required this.accent, this.large = false});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'stored'   => KT.kGreen,
      'thawing'  => KT.kBlue,
      'consumed' => Colors.black38,
      'discarded'=> KT.kRed,
      _          => Colors.black26,
    };
    if (large) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Text(status.toUpperCase(),
            style: KT.poppins(size: 11, weight: FontWeight.w700, color: color, letterSpacing: 0.8)),
      );
    }
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(status, style: KT.poppins(size: 10, weight: FontWeight.w600, color: color)),
    ]);
  }
}
