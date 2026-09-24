// Core providers for the app

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/api/api_client.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/inventory_repository.dart';
import 'data/models/localized_label.dart';

// Import feature providers first (types need to be available for StateNotifierProvider)
import 'features/auth/auth_provider.dart';
import 'features/inventory/inventory_provider.dart';

// Re-export types for easy access
export 'features/auth/auth_provider.dart';
export 'features/inventory/inventory_provider.dart';
export 'data/models/localized_label.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository(ref.read(apiClientProvider)));
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier(ref.read(authRepositoryProvider)));
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) => InventoryRepository(ref.read(apiClientProvider)));
final inventoryNotifierProvider = StateNotifierProvider<InventoryNotifier, InventoryState>((ref) => InventoryNotifier(ref.read(inventoryRepositoryProvider)));