import 'package:dio/dio.dart';

import '../../core/api/api_client.dart';
import '../models/inventory_item.dart';
import '../models/reference_data.dart';
import '../models/localized_label.dart';

class InventoryRepository {
  final ApiClient _apiClient;

  InventoryRepository(this._apiClient);

  Future<InventoryItemListResponse> listItems({
    String? category,
    String? storageLocationId,
    int limit = 50,
    String? cursor,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
    };
    if (category != null) queryParams['category'] = category;
    if (storageLocationId != null) queryParams['storage_location_id'] = storageLocationId;
    if (cursor != null) queryParams['cursor'] = cursor;

    final response = await _apiClient.dio.get(
      '/inventory-items',
      queryParameters: queryParams,
    );
    return InventoryItemListResponse.fromJson(response.data);
  }

  Future<InventoryItem> getItem(String itemId) async {
    final response = await _apiClient.dio.get('/inventory-items/$itemId');
    return InventoryItem.fromJson(response.data);
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
    final data = <String, dynamic>{
      'name': name,
      'category_key': categoryKey,
      'quantity': quantity,
      'unit_key': unitKey,
      'storage_location_id': storageLocationId,
      'is_homemade': isHomemade,
      'status': status,
    };
    if (preparedAt != null) data['prepared_at'] = preparedAt;
    if (frozenAt != null) data['frozen_at'] = frozenAt;
    if (openedAt != null) data['opened_at'] = openedAt;
    if (expiresAt != null) data['expires_at'] = expiresAt;
    if (dateAdded != null) data['date_added'] = dateAdded;
    if (notes != null) data['notes'] = notes;

    final response = await _apiClient.dio.post(
      '/inventory-items',
      data: data,
    );
    return InventoryItem.fromJson(response.data);
  }

  Future<InventoryItem> updateItem({
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
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (categoryKey != null) data['category_key'] = categoryKey;
    if (quantity != null) data['quantity'] = quantity;
    if (unitKey != null) data['unit_key'] = unitKey;
    if (storageLocationId != null) data['storage_location_id'] = storageLocationId;
    if (preparedAt != null) data['prepared_at'] = preparedAt;
    if (frozenAt != null) data['frozen_at'] = frozenAt;
    if (openedAt != null) data['opened_at'] = openedAt;
    if (expiresAt != null) data['expires_at'] = expiresAt;
    if (isHomemade != null) data['is_homemade'] = isHomemade;
    if (status != null) data['status'] = status;
    if (dateAdded != null) data['date_added'] = dateAdded;
    if (notes != null) data['notes'] = notes;

    final response = await _apiClient.dio.patch(
      '/inventory-items/$itemId',
      data: data,
    );
    return InventoryItem.fromJson(response.data);
  }

  Future<void> deleteItem(String itemId) async {
    await _apiClient.dio.delete('/inventory-items/$itemId');
  }

  Future<ReferenceDataResponse> getReferenceData() async {
    final response = await _apiClient.dio.get('/reference');
    return ReferenceDataResponse.fromJson(response.data);
  }

  Future<List<LocalizedLabel>> getCategories() async {
    final response = await _apiClient.dio.get('/reference/categories');
    return (response.data as List)
        .map((e) => LocalizedLabel.fromJson(e))
        .toList();
  }

  Future<List<LocalizedLabel>> getUnits() async {
    final response = await _apiClient.dio.get('/reference/units');
    return (response.data as List)
        .map((e) => LocalizedLabel.fromJson(e))
        .toList();
  }

  Future<List<StorageLocation>> getStorageLocations() async {
    final response = await _apiClient.dio.get('/storage-locations');
    return (response.data as List)
        .map((e) => StorageLocation.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}