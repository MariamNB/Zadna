import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:zadna/core/api/api_client.dart';
import 'package:zadna/data/models/inventory_item.dart';
import 'package:zadna/data/repositories/inventory_repository.dart';
import 'package:zadna/features/inventory/inventory_provider.dart';

class _Repository extends InventoryRepository {
  final requests = <({String? query, String? category, String? cursor})>[];
  final responses = <Completer<InventoryItemListResponse>>[];

  _Repository() : super(ApiClient());

  @override
  Future<InventoryItemListResponse> listItems({
    String? category,
    String? storageLocationId,
    int limit = 50,
    String? cursor,
    String? searchQuery,
  }) {
    requests.add((query: searchQuery, category: category, cursor: cursor));
    final response = Completer<InventoryItemListResponse>();
    responses.add(response);
    return response.future;
  }
}

void main() {
  test('an older search response cannot replace newer results', () async {
    final repository = _Repository();
    final notifier = InventoryNotifier(repository);
    final first = notifier.search('milk');
    final second = notifier.search('chicken');
    repository.responses[1].complete(const InventoryItemListResponse(
      items: [], nextPageToken: 'new-page',
    ));
    await second;
    repository.responses[0].complete(const InventoryItemListResponse(
      items: [], nextPageToken: 'old-page',
    ));
    await first;
    expect(notifier.state.searchQuery, 'chicken');
    expect(notifier.state.nextPageToken, 'new-page');
    notifier.dispose();
  });

  test('search persists through pagination, category changes, and filter reset',
      () async {
    final repository = _Repository();
    final notifier = InventoryNotifier(repository);
    var request = notifier.search(' milk ');
    repository.responses.last.complete(const InventoryItemListResponse(
      items: [], nextPageToken: 'page-2',
    ));
    await request;
    request = notifier.loadMore();
    expect(repository.requests.last.query, 'milk');
    expect(repository.requests.last.cursor, 'page-2');
    repository.responses.last.complete(
        const InventoryItemListResponse(items: []));
    await request;

    request = notifier.loadItems(category: 'dairy', refresh: true);
    expect(repository.requests.last.query, 'milk');
    expect(repository.requests.last.category, 'dairy');
    repository.responses.last.complete(
        const InventoryItemListResponse(items: []));
    await request;

    notifier.clearFilters();
    expect(repository.requests.last.query, 'milk');
    expect(repository.requests.last.category, isNull);
    repository.responses.last.complete(
        const InventoryItemListResponse(items: []));
    await Future<void>.delayed(Duration.zero);
    notifier.dispose();
  });
}
