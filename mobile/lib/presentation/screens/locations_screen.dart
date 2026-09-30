import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/kitchen_theme.dart';
import '../../data/models/inventory_item.dart';
import '../../providers.dart';

const _locationTypes = [
  ('fridge', '🧊', 'Fridge'),
  ('freezer', '❄️', 'Freezer'),
  ('pantry', '🏠', 'Pantry'),
  ('garage_freezer', '🚗', 'Garage Freezer'),
  ('drawer', '📦', 'Drawer'),
  ('shelf', '📚', 'Shelf'),
  ('section', '📂', 'Section'),
  ('other', '📌', 'Other'),
];

String _typeEmoji(String type) =>
    _locationTypes.firstWhere((t) => t.$1 == type, orElse: () => ('other', '📌', 'Other')).$2;

String _typeLabel(String type) =>
    _locationTypes.firstWhere((t) => t.$1 == type, orElse: () => ('other', '📌', 'Other')).$3;

class LocationsScreen extends ConsumerStatefulWidget {
  const LocationsScreen({super.key});

  @override
  ConsumerState<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends ConsumerState<LocationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(storageNotifierProvider.notifier).loadTopLevel();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(storageNotifierProvider);

    return Scaffold(
      backgroundColor: KT.kLightYellow,
      body: Column(
        children: [
          _buildHeader(context),
          if (state.error != null)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: KT.kPalePink,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: KT.kRed, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(state.error!, style: KT.poppins(size: 12, color: KT.kRed)),
                  ),
                ],
              ),
            ),
          Expanded(child: _buildBody(state)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, parentId: null),
        icon: const Icon(Icons.add_rounded),
        label: Text('Add Location', style: KT.poppins(weight: FontWeight.w700, color: Colors.white)),
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
        left: 8,
        right: 20,
        bottom: 24,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: KT.kLightYellow2),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Settings', style: KT.poppins(size: 13, color: KT.kDarkYellow, weight: FontWeight.w500)),
                Text('Storage Locations', style: KT.poppins(size: 22, weight: FontWeight.w800, color: KT.kLightYellow)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: KT.kLightYellow2),
            onPressed: () => ref.read(storageNotifierProvider.notifier).loadTopLevel(),
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }

  Widget _buildBody(StorageState state) {
    if (state.isLoading && state.topLevel.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: KT.kGreen));
    }

    if (state.topLevel.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: KT.kLightGreen,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: KT.kGreen.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: const Center(child: Text('🗄️', style: TextStyle(fontSize: 44))),
            ),
            const SizedBox(height: 24),
            Text('No locations yet', style: KT.poppins(size: 18, weight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'Tap "Add Location" to start\norganising your storage',
              style: KT.poppins(size: 13, color: Colors.black45),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
      itemCount: state.topLevel.length,
      itemBuilder: (context, i) => _LocationNode(
        location: state.topLevel[i],
        parentId: null,
        depth: 0,
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context, {required String? parentId}) async {
    final nameCtrl = TextEditingController();
    String selectedType = parentId == null ? 'fridge' : 'shelf';
    bool saving = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: KT.kLightYellow,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parentId == null ? 'Add Top-Level Location' : 'Add Sub-Location',
                  style: KT.poppins(size: 16, weight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    hintText: parentId == null ? 'e.g. Fridge, Pantry' : 'e.g. Top Shelf',
                  ),
                  style: KT.poppins(),
                ),
                const SizedBox(height: 12),
                Text('Type', style: KT.poppins(size: 12, weight: FontWeight.w600, color: Colors.black54)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _locationTypes.map((t) {
                    final isSelected = selectedType == t.$1;
                    return GestureDetector(
                      onTap: () => setLocal(() => selectedType = t.$1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? KT.kDarkBlue : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? KT.kDarkBlue : Colors.black12),
                        ),
                        child: Text(
                          '${t.$2} ${t.$3}',
                          style: KT.poppins(
                            size: 12,
                            weight: FontWeight.w600,
                            color: isSelected ? KT.kLightYellow : KT.kDarkBlue,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('Cancel', style: KT.poppins(weight: FontWeight.w600, color: Colors.black54)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: saving
                          ? null
                          : () async {
                              final name = nameCtrl.text.trim();
                              if (name.isEmpty) return;
                              setLocal(() => saving = true);
                              try {
                                await ref.read(storageNotifierProvider.notifier).addLocation(
                                      name: name,
                                      type: selectedType,
                                      parentId: parentId,
                                    );
                                if (ctx.mounted) Navigator.pop(ctx);
                              } catch (e) {
                                setLocal(() => saving = false);
                                if (ctx.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(_friendlyError(e))),
                                  );
                                }
                              }
                            },
                      child: saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LocationNode extends ConsumerWidget {
  final StorageLocation location;
  final String? parentId;
  final int depth;

  const _LocationNode({
    required this.location,
    required this.parentId,
    required this.depth,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(storageNotifierProvider);
    final isExpanded = state.expanded.contains(location.id);
    final children = state.children[location.id];
    final isTopLevel = depth == 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTile(context, ref, isExpanded, isTopLevel),
        if (isExpanded) ...[
          if (children == null)
            const Padding(
              padding: EdgeInsets.only(left: 56, bottom: 8),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: KT.kGreen),
              ),
            )
          else ...[
            if (children.isNotEmpty)
              ...children.map(
                (child) => Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: _LocationNode(
                    location: child,
                    parentId: location.id,
                    depth: depth + 1,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 8),
              child: TextButton.icon(
                onPressed: () => _showAddSubDialog(context, ref),
                icon: const Icon(Icons.add, size: 16),
                label: Text('Add sub-location', style: KT.poppins(size: 12, weight: FontWeight.w600, color: KT.kGreen)),
                style: TextButton.styleFrom(foregroundColor: KT.kGreen, padding: const EdgeInsets.symmetric(horizontal: 8)),
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildTile(BuildContext context, WidgetRef ref, bool isExpanded, bool isTopLevel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isTopLevel ? Colors.white : KT.kLightYellow2.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isTopLevel
            ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))]
            : null,
        border: !isTopLevel ? Border.all(color: Colors.black12) : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isTopLevel ? KT.kLightGreen : KT.kLavender,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(_typeEmoji(location.type), style: const TextStyle(fontSize: 20)),
          ),
        ),
        title: Text(location.name, style: KT.poppins(weight: FontWeight.w600)),
        subtitle: Text(_typeLabel(location.type), style: KT.poppins(size: 11, color: Colors.black45)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isTopLevel)
              AnimatedRotation(
                turns: isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: IconButton(
                  icon: const Icon(Icons.expand_more_rounded, color: KT.kDarkBlue),
                  onPressed: () => ref.read(storageNotifierProvider.notifier).toggleExpand(location.id),
                ),
              ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black38, size: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              onSelected: (value) => _handleAction(context, ref, value),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'rename',
                  child: Row(children: [
                    const Icon(Icons.drive_file_rename_outline, size: 18),
                    const SizedBox(width: 8),
                    Text('Rename', style: KT.poppins()),
                  ]),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    const Icon(Icons.delete_outline, size: 18, color: KT.kRed),
                    const SizedBox(width: 8),
                    Text('Delete', style: KT.poppins(color: KT.kRed)),
                  ]),
                ),
              ],
            ),
          ],
        ),
        onTap: isTopLevel
            ? () => ref.read(storageNotifierProvider.notifier).toggleExpand(location.id)
            : null,
      ),
    );
  }

  Future<void> _handleAction(BuildContext context, WidgetRef ref, String action) async {
    if (action == 'rename') {
      await _showRenameDialog(context, ref);
    } else if (action == 'delete') {
      await _confirmDelete(context, ref);
    }
  }

  Future<void> _showRenameDialog(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController(text: location.name);
    bool saving = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: KT.kLightYellow,
          title: Text('Rename', style: KT.poppins(size: 16, weight: FontWeight.w700)),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Name'),
            style: KT.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: KT.poppins(weight: FontWeight.w600, color: Colors.black54)),
            ),
            ElevatedButton(
              onPressed: saving
                  ? null
                  : () async {
                      final name = ctrl.text.trim();
                      if (name.isEmpty) return;
                      setLocal(() => saving = true);
                      try {
                        await ref.read(storageNotifierProvider.notifier).renameLocation(
                              id: location.id,
                              name: name,
                              parentId: parentId,
                            );
                        if (ctx.mounted) Navigator.pop(ctx);
                      } catch (e) {
                        setLocal(() => saving = false);
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(_friendlyError(e))),
                          );
                        }
                      }
                    },
              child: saving
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: KT.kLightYellow,
        title: Text('Delete "${location.name}"?', style: KT.poppins(size: 16, weight: FontWeight.w700)),
        content: Text(
          'This cannot be undone. Locations with sub-locations or stored items cannot be deleted.',
          style: KT.poppins(size: 13, color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: KT.poppins(weight: FontWeight.w600, color: Colors.black54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: KT.kRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(storageNotifierProvider.notifier).removeLocation(
            id: location.id,
            parentId: parentId,
          );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_friendlyError(e)),
            backgroundColor: KT.kRed,
          ),
        );
      }
    }
  }

  Future<void> _showAddSubDialog(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    String selectedType = 'shelf';
    bool saving = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: KT.kLightYellow,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add to "${location.name}"', style: KT.poppins(size: 16, weight: FontWeight.w700)),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'e.g. Top Shelf, Door',
                  ),
                  style: KT.poppins(),
                ),
                const SizedBox(height: 12),
                Text('Type', style: KT.poppins(size: 12, weight: FontWeight.w600, color: Colors.black54)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _locationTypes.map((t) {
                    final isSelected = selectedType == t.$1;
                    return GestureDetector(
                      onTap: () => setLocal(() => selectedType = t.$1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? KT.kDarkBlue : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? KT.kDarkBlue : Colors.black12),
                        ),
                        child: Text(
                          '${t.$2} ${t.$3}',
                          style: KT.poppins(
                            size: 12,
                            weight: FontWeight.w600,
                            color: isSelected ? KT.kLightYellow : KT.kDarkBlue,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('Cancel', style: KT.poppins(weight: FontWeight.w600, color: Colors.black54)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: saving
                          ? null
                          : () async {
                              final name = nameCtrl.text.trim();
                              if (name.isEmpty) return;
                              setLocal(() => saving = true);
                              try {
                                await ref.read(storageNotifierProvider.notifier).addLocation(
                                      name: name,
                                      type: selectedType,
                                      parentId: location.id,
                                    );
                                if (ctx.mounted) Navigator.pop(ctx);
                              } catch (e) {
                                setLocal(() => saving = false);
                                if (ctx.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(_friendlyError(e))),
                                  );
                                }
                              }
                            },
                      child: saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _friendlyError(Object e) {
  if (e is DioException) {
    final data = e.response?.data;
    if (data is Map) {
      final code = data['code'];
      if (code == 'HAS_CHILDREN') return 'Cannot delete: this location has sub-locations.';
      if (code == 'HAS_ITEMS') return 'Cannot delete: this location has stored items.';
      final detail = data['detail'];
      if (detail is String) return detail;
    }
    return 'Network error (${e.response?.statusCode ?? 'unknown'})';
  }
  return e.toString();
}
