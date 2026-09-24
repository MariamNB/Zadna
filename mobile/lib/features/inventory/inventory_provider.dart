import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/inventory_item.dart';
import '../../data/models/reference_data.dart';
import '../../data/models/localized_label.dart';
import '../../data/repositories/inventory_repository.dart';

class InventoryState {
  final List<InventoryItem> items;
  final bool isLoading;
  final bool isLoadingMore;
  final String? nextPageToken;
  final String? error;
  final String? filterCategory;
  final String? filterStorageLocation;

  const InventoryState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.nextPageToken,
    this.error,
    this.filterCategory,
    this.filterStorageLocation,
  });

  InventoryState copyWith({
    List<InventoryItem>? items,
    bool? isLoading,
    bool? isLoadingMore,
    String? nextPageToken,
    String? error,
    String? filterCategory,
    String? filterStorageLocation,
  }) {
    return InventoryState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      nextPageToken: nextPageToken ?? this.nextPageToken,
      error: error ?? this.error,
      filterCategory: filterCategory ?? this.filterCategory,
      filterStorageLocation: filterStorageLocation ?? this.filterStorageLocation,
    );
  }
}

class InventoryNotifier extends StateNotifier<InventoryState> {
  final InventoryRepository _repository;

  InventoryNotifier(this._repository) : super(const InventoryState());

  Future<void> loadItems({
    String? category,
    String? storageLocationId,
    bool refresh = false,
  }) async {
    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        filterCategory: category,
        filterStorageLocation: storageLocationId,
        items: [],
        nextPageToken: null,
      );
    } else if (state.isLoading || state.isLoadingMore) {
      return;
    } else {
      state = state.copyWith(isLoadingMore: true, error: null);
    }

    try {
      final response = await _repository.listItems(
        category: category,
        storageLocationId: storageLocationId,
        cursor: refresh ? null : state.nextPageToken,
      );

      final newItems = refresh ? response.items : [...state.items, ...response.items];

      state = state.copyWith(
        items: newItems,
        nextPageToken: response.nextPageToken,
        isLoading: false,
        isLoadingMore: false,
        filterCategory: category ?? state.filterCategory,
        filterStorageLocation: storageLocationId ?? state.filterStorageLocation,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadItems(
      category: state.filterCategory,
      storageLocationId: state.filterStorageLocation,
      refresh: true,
    );
  }

  Future<void> loadMore() async {
    if (state.nextPageToken != null && !state.isLoadingMore) {
      await loadItems(
        category: state.filterCategory,
        storageLocationId: state.filterStorageLocation,
      );
    }
  }

  void clearFilters() {
    state = state.copyWith(
      filterCategory: null,
      filterStorageLocation: null,
      items: [],
      nextPageToken: null,
    );
    loadItems(refresh: true);
  }

  Future<InventoryItem> createItem({
    required String name,
    required String categoryKey,
    required String quantity,
    required String unitKey,
    required String storageLocationId,
    String? preparedAt,
    String? frozenAt,
    String? openedAt,
    String? expiresAt,
    required bool isHomemade,
    String status = 'stored',
    String? dateAdded,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final item = await _repository.createItem(
        name: name,
        categoryKey: categoryKey,
        quantity: quantity,
        unitKey: unitKey,
        storageLocationId: storageLocationId,
        preparedAt: preparedAt,
        frozenAt: frozenAt,
        openedAt: openedAt,
        expiresAt: expiresAt,
        isHomemade: isHomemade,
        status: status,
        dateAdded: dateAdded,
        notes: notes,
      );
      // Refresh the full list from backend to avoid duplicates from
      // any stale optimistic state.
      await loadItems(
        category: state.filterCategory,
        storageLocationId: state.filterStorageLocation,
        refresh: true,
      );
      return item;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> updateItem({
    required String itemId,
    String? name,
    String? categoryKey,
    String? quantity,
    String? unitKey,
    String? storageLocationId,
    String? preparedAt,
    String? frozenAt,
    String? openedAt,
    String? expiresAt,
    bool? isHomemade,
    String? status,
    String? dateAdded,
    String? notes,
  }) async {
    try {
      final updatedItem = await _repository.updateItem(
        itemId: itemId,
        name: name,
        categoryKey: categoryKey,
        quantity: quantity,
        unitKey: unitKey,
        storageLocationId: storageLocationId,
        preparedAt: preparedAt,
        frozenAt: frozenAt,
        openedAt: openedAt,
        expiresAt: expiresAt,
        isHomemade: isHomemade,
        status: status,
        dateAdded: dateAdded,
        notes: notes,
      );
      state = state.copyWith(
        items: state.items.map((item) => item.id == itemId ? updatedItem : item).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteItem(String itemId) async {
    try {
      await _repository.deleteItem(itemId);
      state = state.copyWith(
        items: state.items.where((item) => item.id != itemId).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<ReferenceDataResponse> getReferenceData() async {
    return _repository.getReferenceData();
  }

  Future<List<LocalizedLabel>> getCategories() async {
    return _repository.getCategories();
  }

  Future<List<LocalizedLabel>> getUnits() async {
    return _repository.getUnits();
  }

  Future<List<StorageLocation>> getStorageLocations() async {
    return _repository.getStorageLocations();
  }
}