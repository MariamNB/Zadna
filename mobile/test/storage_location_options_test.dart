import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zadna/core/api/api_client.dart';
import 'package:zadna/data/repositories/inventory_repository.dart';

Map<String, dynamic> location(String id, String name, {String? parentId}) => {
      'id': id,
      'householdId': 'household',
      'parentId': parentId,
      'name': name,
      'type': parentId == null ? 'freezer' : 'drawer',
      'sortOrder': 0,
      'createdBy': 'member',
      'updatedBy': 'member',
      'createdAt': '2026-09-30T00:00:00Z',
      'updatedAt': '2026-09-30T00:00:00Z',
    };

void main() {
  test('item location options include every level and newly added locations',
      () async {
    final levels = <String?, List<Map<String, dynamic>>>{
      null: [location('freezer', 'Freezer'), location('pantry', 'Pantry')],
      'freezer': [location('drawer', 'Top drawer', parentId: 'freezer')],
      'drawer': [location('section', 'Left section', parentId: 'drawer')],
    };
    final dio = Dio();
    final client = ApiClient(dio: dio);
    // Resolve HTTP requests without platform storage or a live backend.
    dio.interceptors.clear();
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      expect(options.path, '/storage-locations');
      final parent = options.queryParameters['parent_id'] as String?;
      handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: levels[parent] ?? <Map<String, dynamic>>[],
      ));
    }));
    final repository = InventoryRepository(client);

    final options = await repository.getStorageLocations();
    expect(options.map((loc) => loc.id),
        ['freezer', 'drawer', 'section', 'pantry']);
    expect(options[1].parentId, 'freezer');

    levels['pantry'] = [location('shelf', 'New shelf', parentId: 'pantry')];
    final refreshed = await repository.getStorageLocations();
    expect(refreshed.map((loc) => loc.id),
        ['freezer', 'drawer', 'section', 'pantry', 'shelf']);
    dio.close();
  });

  test('a failed child request reports an error instead of hiding locations',
      () async {
    final dio = Dio();
    final client = ApiClient(dio: dio);
    dio.interceptors.clear();
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      if (options.queryParameters['parent_id'] != null) {
        handler.reject(DioException(requestOptions: options));
      } else {
        handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: [location('freezer', 'Freezer')],
        ));
      }
    }));

    await expectLater(InventoryRepository(client).getStorageLocations(),
        throwsA(isA<DioException>()));
    dio.close();
  });
}
