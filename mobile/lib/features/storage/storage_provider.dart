import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/inventory_item.dart';
import '../../data/repositories/storage_repository.dart';

class StorageState {
  final List<StorageLocation> topLevel;
  final Map<String, List<StorageLocation>> children;
  final Set<String> expanded;
  final bool isLoading;
  final String? error;

  const StorageState({
    this.topLevel = const [],
    this.children = const {},
    this.expanded = const {},
    this.isLoading = false,
    this.error,
  });

  StorageState copyWith({
    List<StorageLocation>? topLevel,
    Map<String, List<StorageLocation>>? children,
    Set<String>? expanded,
    bool? isLoading,
    String? error,
  }) {
    return StorageState(
      topLevel: topLevel ?? this.topLevel,
      children: children ?? this.children,
      expanded: expanded ?? this.expanded,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class StorageNotifier extends StateNotifier<StorageState> {
  final StorageRepository _repository;

  StorageNotifier(this._repository) : super(const StorageState());

  Future<void> loadTopLevel() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final locations = await _repository.listLocations();
      state = state.copyWith(topLevel: locations, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> toggleExpand(String locationId) async {
    final expanded = Set<String>.from(state.expanded);
    if (expanded.contains(locationId)) {
      expanded.remove(locationId);
      state = state.copyWith(expanded: expanded);
      return;
    }

    expanded.add(locationId);
    state = state.copyWith(expanded: expanded);

    if (!state.children.containsKey(locationId)) {
      try {
        final kids = await _repository.listLocations(parentId: locationId);
        final updated = Map<String, List<StorageLocation>>.from(state.children);
        updated[locationId] = kids;
        state = state.copyWith(children: updated);
      } catch (e) {
        state = state.copyWith(error: e.toString());
      }
    }
  }

  Future<void> addLocation({
    required String name,
    required String type,
    String? parentId,
  }) async {
    try {
      final loc = await _repository.createLocation(
        name: name,
        type: type,
        parentId: parentId,
      );
      if (parentId == null) {
        state = state.copyWith(topLevel: [...state.topLevel, loc]);
      } else {
        final updated = Map<String, List<StorageLocation>>.from(state.children);
        final existing = updated[parentId] ?? [];
        updated[parentId] = [...existing, loc];
        state = state.copyWith(children: updated);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> renameLocation({
    required String id,
    required String name,
    String? parentId,
  }) async {
    try {
      final updated = await _repository.updateLocation(id: id, name: name);
      _replaceInState(updated, parentId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> removeLocation({
    required String id,
    String? parentId,
  }) async {
    await _repository.deleteLocation(id);
    if (parentId == null) {
      state = state.copyWith(
        topLevel: state.topLevel.where((l) => l.id != id).toList(),
      );
    } else {
      final updated = Map<String, List<StorageLocation>>.from(state.children);
      updated[parentId] = (updated[parentId] ?? []).where((l) => l.id != id).toList();
      state = state.copyWith(children: updated);
    }
    final expandedCopy = Set<String>.from(state.expanded)..remove(id);
    final childrenCopy = Map<String, List<StorageLocation>>.from(state.children)..remove(id);
    state = state.copyWith(expanded: expandedCopy, children: childrenCopy);
  }

  void _replaceInState(StorageLocation updated, String? parentId) {
    if (parentId == null) {
      state = state.copyWith(
        topLevel: state.topLevel.map((l) => l.id == updated.id ? updated : l).toList(),
      );
    } else {
      final map = Map<String, List<StorageLocation>>.from(state.children);
      map[parentId] = (map[parentId] ?? []).map((l) => l.id == updated.id ? updated : l).toList();
      state = state.copyWith(children: map);
    }
  }
}
