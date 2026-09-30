import 'package:flutter/material.dart';

import '../../core/kitchen_theme.dart';
import '../../data/models/inventory_item.dart';

class StorageLocationPicker extends StatelessWidget {
  final String? value;
  final List<StorageLocation> locations;
  final ValueChanged<String> onChanged;

  const StorageLocationPicker({
    super.key,
    required this.value,
    required this.locations,
    required this.onChanged,
  });

  String _label() {
    final byId = {for (final location in locations) location.id: location};
    final names = <String>[];
    final visited = <String>{};
    StorageLocation? current = byId[value];
    while (current != null && visited.add(current.id)) {
      names.add(current.name);
      current = byId[current.parentId];
    }
    return names.reversed.join(' › ');
  }

  @override
  Widget build(BuildContext context) => FormField<String>(
        initialValue: value,
        validator: (id) => id == null ? 'Select a location' : null,
        builder: (field) => InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () async {
            final selected = await showDialog<String>(
              context: context,
              builder: (_) => _LocationTree(
                locations: locations,
                selectedId: value,
              ),
            );
            if (selected != null && field.mounted) {
              field.didChange(selected);
              onChanged(selected);
            }
          },
          child: InputDecorator(
            isEmpty: value == null,
            decoration: InputDecoration(
              labelText: 'Storage Location',
              errorText: field.errorText,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value == null ? '' : _label(),
                    style: KT.poppins(weight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      );
}

class _LocationTree extends StatefulWidget {
  final List<StorageLocation> locations;
  final String? selectedId;

  const _LocationTree({required this.locations, required this.selectedId});

  @override
  State<_LocationTree> createState() => _LocationTreeState();
}

class _LocationTreeState extends State<_LocationTree> {
  final _expanded = <String>{};
  late final Map<String?, List<StorageLocation>> _children;

  @override
  void initState() {
    super.initState();
    _children = {};
    final byId = {for (final loc in widget.locations) loc.id: loc};
    for (final location in widget.locations) {
      (_children[location.parentId] ??= []).add(location);
    }
    // Reopen the tree with the selected partition visible.
    var parentId = byId[widget.selectedId]?.parentId;
    while (parentId != null && _expanded.add(parentId)) {
      parentId = byId[parentId]?.parentId;
    }
  }

  void _toggle(String id) => setState(() {
        if (!_expanded.add(id)) _expanded.remove(id);
      });

  Widget _node(StorageLocation location, int depth) {
    final children = _children[location.id] ?? [];
    final hasChildren = children.isNotEmpty;
    final expanded = _expanded.contains(location.id);
    final selected = widget.selectedId == location.id;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(left: depth * 20.0),
          child: ListTile(
            leading: hasChildren
                ? IconButton(
                    tooltip: '${expanded ? 'Collapse' : 'Expand'} ${location.name}',
                    onPressed: () => _toggle(location.id),
                    icon: Icon(expanded
                        ? Icons.expand_more
                        : Icons.chevron_right),
                  )
                : const SizedBox(width: 48, child: Icon(Icons.place_outlined)),
            title: Text(location.name,
                style: KT.poppins(weight: FontWeight.w500)),
            selected: selected,
            selectedTileColor: KT.kLightGreen,
            onTap: () => hasChildren
                ? _toggle(location.id)
                : Navigator.of(context).pop(location.id),
            trailing: IconButton(
              tooltip: 'Select ${location.name}',
              icon: Icon(selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked),
              color: KT.kGreen,
              onPressed: () => Navigator.of(context).pop(location.id),
            ),
          ),
        ),
        if (expanded)
          for (final child in children) _node(child, depth + 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        backgroundColor: KT.kLightYellow,
        title: Text('Storage Location',
            style: KT.poppins(size: 20, weight: FontWeight.w700)),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        content: SizedBox(
          width: 460,
          height: MediaQuery.sizeOf(context).height * 0.5,
          child: widget.locations.isEmpty
              ? Center(child: Text('No locations yet', style: KT.poppins()))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      for (final location in _children[null] ?? <StorageLocation>[])
                        _node(location, 0),
                    ],
                  ),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      );
}
