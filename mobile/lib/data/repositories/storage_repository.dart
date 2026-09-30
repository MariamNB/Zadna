import '../../core/api/api_client.dart';
import '../models/inventory_item.dart';

class StorageRepository {
  final ApiClient _apiClient;

  StorageRepository(this._apiClient);

  Future<List<StorageLocation>> listLocations({String? parentId}) async {
    final query = <String, dynamic>{};
    if (parentId != null) query['parent_id'] = parentId;
    // No parent_id param → backend returns top-level (parent_id IS NULL)

    final response = await _apiClient.dio.get(
      '/storage-locations',
      queryParameters: query.isEmpty ? null : query,
    );
    return (response.data as List)
        .map((e) => StorageLocation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<StorageLocation> createLocation({
    required String name,
    required String type,
    String? parentId,
    int sortOrder = 0,
  }) async {
    final data = <String, dynamic>{
      'name': name,
      'type': type,
      'sort_order': sortOrder,
    };
    if (parentId != null) data['parent_id'] = parentId;

    final response = await _apiClient.dio.post('/storage-locations', data: data);
    return StorageLocation.fromJson(response.data);
  }

  Future<StorageLocation> updateLocation({
    required String id,
    String? name,
    String? type,
    int? sortOrder,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (type != null) data['type'] = type;
    if (sortOrder != null) data['sort_order'] = sortOrder;

    final response = await _apiClient.dio.patch('/storage-locations/$id', data: data);
    return StorageLocation.fromJson(response.data);
  }

  Future<void> deleteLocation(String id) async {
    await _apiClient.dio.delete('/storage-locations/$id');
  }
}
