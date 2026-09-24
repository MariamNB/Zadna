import 'package:freezed_annotation/freezed_annotation.dart';

import 'localized_label.dart';

part 'inventory_item.freezed.dart';
part 'inventory_item.g.dart';

@freezed
class InventoryItem with _$InventoryItem {
  const factory InventoryItem({
    required String id,
    required String householdId,
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
    required String status,
    required String dateAdded,
    String? notes,
    required String createdBy,
    required String updatedBy,
    required String createdAt,
    required String updatedAt,
    required LocalizedLabel category,
    required LocalizedLabel unit,
    required StorageLocation storageLocation,
  }) = _InventoryItem;

  factory InventoryItem.fromJson(Map<String, dynamic> json) =>
      _$InventoryItemFromJson(json);
}

@freezed
class StorageLocation with _$StorageLocation {
  const factory StorageLocation({
    required String id,
    required String householdId,
    String? parentId,
    required String name,
    required String type,
    required int sortOrder,
    required String createdBy,
    required String updatedBy,
    required String createdAt,
    required String updatedAt,
  }) = _StorageLocation;

  factory StorageLocation.fromJson(Map<String, dynamic> json) =>
      _$StorageLocationFromJson(json);
}

@freezed
class InventoryItemListResponse with _$InventoryItemListResponse {
  const factory InventoryItemListResponse({
    required List<InventoryItem> items,
    String? nextPageToken,
  }) = _InventoryItemListResponse;

  factory InventoryItemListResponse.fromJson(Map<String, dynamic> json) =>
      _$InventoryItemListResponseFromJson(json);
}