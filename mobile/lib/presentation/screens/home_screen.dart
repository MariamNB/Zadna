import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import '../../data/models/localized_label.dart';
import '../../core/kitchen_theme.dart';
import '../widgets/inventory_item_card.dart';
import '../widgets/category_filter_chip.dart';
import 'add_item_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authState = ref.read(authNotifierProvider);
      if (authState is! Authenticated) {
        if (mounted) Navigator.of(context).pushReplacementNamed('/login');
        return;
      }
      ref.read(inventoryNotifierProvider.notifier).loadItems(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final inventoryState = ref.watch(inventoryNotifierProvider);

    return Scaffold(
      backgroundColor: KT.kLightYellow,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(child: _buildBody(inventoryState)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddItemScreen()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: Text('Add Item', style: KT.poppins(weight: FontWeight.w700, color: Colors.white)),
        backgroundColor: KT.kGreen,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: KT.kDarkBlue,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 8,
        bottom: 24,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('My Kitchen', style: KT.poppins(size: 13, color: KT.kDarkYellow, weight: FontWeight.w500)),
                Text('Inventory Board', style: KT.poppins(size: 22, weight: FontWeight.w800, color: KT.kLightYellow)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined, color: KT.kLightYellow2),
            onPressed: () => _showFilterDialog(context),
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: KT.kLightYellow2),
            onPressed: () => ref.read(inventoryNotifierProvider.notifier).refresh(),
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: KT.kLightYellow2),
            onSelected: (value) async {
              if (value == 'logout') {
                await ref.read(authNotifierProvider.notifier).logout();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(children: [
                  const Icon(Icons.logout, size: 18),
                  const SizedBox(width: 8),
                  Text('Logout', style: KT.poppins()),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody(InventoryState state) {
    if (state.isLoading && state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: KT.kGreen),
            const SizedBox(height: 16),
            Text('Loading...', style: KT.poppins(weight: FontWeight.w500, color: KT.kDarkBlue)),
          ],
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: KT.kPalePink,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: KT.kRed.withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('😬', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text('Something went wrong', style: KT.poppins(size: 18, weight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(state.error!, style: KT.poppins(size: 12, color: Colors.black54), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => ref.read(inventoryNotifierProvider.notifier).refresh(),
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: KT.kRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                color: KT.kLightGreen,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: KT.kGreen.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: const Center(child: Text('🛒', style: TextStyle(fontSize: 52))),
            ),
            const SizedBox(height: 24),
            Text('No items yet', style: KT.poppins(size: 20, weight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'Tap "Add Item" to start\ntracking your kitchen',
              style: KT.poppins(size: 14, color: Colors.black45),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Active filters bar
        if (state.filterCategory != null || state.filterStorageLocation != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.filter_alt, size: 16, color: KT.kGreen),
                const SizedBox(width: 6),
                if (state.filterCategory != null)
                  CategoryFilterChip(
                    label: state.filterCategory!,
                    onDeleted: () => ref.read(inventoryNotifierProvider.notifier).clearFilters(),
                  ),
                if (state.filterStorageLocation != null)
                  CategoryFilterChip(
                    label: state.filterStorageLocation!,
                    onDeleted: () => ref.read(inventoryNotifierProvider.notifier).clearFilters(),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: () => ref.read(inventoryNotifierProvider.notifier).clearFilters(),
                  style: TextButton.styleFrom(foregroundColor: KT.kRed),
                  child: Text('Clear', style: KT.poppins(size: 12, weight: FontWeight.w600, color: KT.kRed)),
                ),
              ],
            ),
          ),

        // Grid
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref.read(inventoryNotifierProvider.notifier).refresh(),
            color: KT.kGreen,
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.82,
              ),
              itemCount: state.items.length + (state.nextPageToken != null ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.items.length) {
                  if (state.isLoadingMore) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ref.read(inventoryNotifierProvider.notifier).loadMore();
                  });
                  return const SizedBox.shrink();
                }
                return InventoryItemCard(item: state.items[index]);
              },
            ),
          ),
        ),
      ],
    );
  }

  void _showFilterDialog(BuildContext context) {
    final categoriesAsync = ref.read(inventoryNotifierProvider.notifier).getCategories();
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: KT.kLightYellow,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filter by Category', style: KT.poppins(size: 16, weight: FontWeight.w700)),
              const SizedBox(height: 16),
              FutureBuilder<List<LocalizedLabel>>(
                future: categoriesAsync,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _chip(context, 'All', null),
                      ...snapshot.data!.map((c) => _chip(context, c.labels['en'] ?? c.key, c.key)),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Close', style: KT.poppins(weight: FontWeight.w600, color: KT.kDarkBlue)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(BuildContext context, String label, String? key) {
    final selected = key == null
        ? ref.read(inventoryNotifierProvider).filterCategory == null
        : ref.read(inventoryNotifierProvider).filterCategory == key;
    return GestureDetector(
      onTap: () {
        if (key == null) {
          ref.read(inventoryNotifierProvider.notifier).clearFilters();
        } else {
          ref.read(inventoryNotifierProvider.notifier).loadItems(category: key, refresh: true);
        }
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? KT.kDarkBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? KT.kDarkBlue : Colors.black12),
        ),
        child: Text(
          label,
          style: KT.poppins(size: 12, weight: FontWeight.w600, color: selected ? KT.kLightYellow : KT.kDarkBlue),
        ),
      ),
    );
  }
}
