// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InventoryItemImpl _$$InventoryItemImplFromJson(Map<String, dynamic> json) =>
    _$InventoryItemImpl(
      id: json['id'] as String,
      householdId: json['householdId'] as String,
      name: json['name'] as String,
      categoryKey: json['categoryKey'] as String,
      quantity: json['quantity'] as String,
      unitKey: json['unitKey'] as String,
      storageLocationId: json['storageLocationId'] as String,
      preparedAt: json['preparedAt'] as String?,
      frozenAt: json['frozenAt'] as String?,
      openedAt: json['openedAt'] as String?,
      expiresAt: json['expiresAt'] as String?,
      isHomemade: json['isHomemade'] as bool,
      status: json['status'] as String,
      dateAdded: json['dateAdded'] as String,
      notes: json['notes'] as String?,
      createdBy: json['createdBy'] as String,
      updatedBy: json['updatedBy'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      category:
          LocalizedLabel.fromJson(json['category'] as Map<String, dynamic>),
      unit: LocalizedLabel.fromJson(json['unit'] as Map<String, dynamic>),
      storageLocation: StorageLocation.fromJson(
          json['storageLocation'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$InventoryItemImplToJson(_$InventoryItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'householdId': instance.householdId,
      'name': instance.name,
      'categoryKey': instance.categoryKey,
      'quantity': instance.quantity,
      'unitKey': instance.unitKey,
      'storageLocationId': instance.storageLocationId,
      'preparedAt': instance.preparedAt,
      'frozenAt': instance.frozenAt,
      'openedAt': instance.openedAt,
      'expiresAt': instance.expiresAt,
      'isHomemade': instance.isHomemade,
      'status': instance.status,
      'dateAdded': instance.dateAdded,
      'notes': instance.notes,
      'createdBy': instance.createdBy,
      'updatedBy': instance.updatedBy,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'category': instance.category,
      'unit': instance.unit,
      'storageLocation': instance.storageLocation,
    };

_$StorageLocationImpl _$$StorageLocationImplFromJson(
        Map<String, dynamic> json) =>
    _$StorageLocationImpl(
      id: json['id'] as String,
      householdId: json['householdId'] as String,
      parentId: json['parentId'] as String?,
      name: json['name'] as String,
      type: json['type'] as String,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      createdBy: json['createdBy'] as String,
      updatedBy: json['updatedBy'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$$StorageLocationImplToJson(
        _$StorageLocationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'householdId': instance.householdId,
      'parentId': instance.parentId,
      'name': instance.name,
      'type': instance.type,
      'sortOrder': instance.sortOrder,
      'createdBy': instance.createdBy,
      'updatedBy': instance.updatedBy,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

_$InventoryItemListResponseImpl _$$InventoryItemListResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$InventoryItemListResponseImpl(
      items: (json['items'] as List<dynamic>)
          .map((e) => InventoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextPageToken: json['nextPageToken'] as String?,
    );

Map<String, dynamic> _$$InventoryItemListResponseImplToJson(
        _$InventoryItemListResponseImpl instance) =>
    <String, dynamic>{
      'items': instance.items,
      'nextPageToken': instance.nextPageToken,
    };
