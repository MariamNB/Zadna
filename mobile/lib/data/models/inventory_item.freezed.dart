// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

InventoryItem _$InventoryItemFromJson(Map<String, dynamic> json) {
  return _InventoryItem.fromJson(json);
}

/// @nodoc
mixin _$InventoryItem {
  String get id => throw _privateConstructorUsedError;
  String get householdId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get categoryKey => throw _privateConstructorUsedError;
  String get quantity => throw _privateConstructorUsedError;
  String get unitKey => throw _privateConstructorUsedError;
  String get storageLocationId => throw _privateConstructorUsedError;
  String? get preparedAt => throw _privateConstructorUsedError;
  String? get frozenAt => throw _privateConstructorUsedError;
  String? get openedAt => throw _privateConstructorUsedError;
  String? get expiresAt => throw _privateConstructorUsedError;
  bool get isHomemade => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get dateAdded => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  String get updatedBy => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String get updatedAt => throw _privateConstructorUsedError;
  LocalizedLabel get category => throw _privateConstructorUsedError;
  LocalizedLabel get unit => throw _privateConstructorUsedError;
  StorageLocation get storageLocation => throw _privateConstructorUsedError;

  /// Serializes this InventoryItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InventoryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InventoryItemCopyWith<InventoryItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InventoryItemCopyWith<$Res> {
  factory $InventoryItemCopyWith(
          InventoryItem value, $Res Function(InventoryItem) then) =
      _$InventoryItemCopyWithImpl<$Res, InventoryItem>;
  @useResult
  $Res call(
      {String id,
      String householdId,
      String name,
      String categoryKey,
      String quantity,
      String unitKey,
      String storageLocationId,
      String? preparedAt,
      String? frozenAt,
      String? openedAt,
      String? expiresAt,
      bool isHomemade,
      String status,
      String dateAdded,
      String? notes,
      String createdBy,
      String updatedBy,
      String createdAt,
      String updatedAt,
      LocalizedLabel category,
      LocalizedLabel unit,
      StorageLocation storageLocation});

  $LocalizedLabelCopyWith<$Res> get category;
  $LocalizedLabelCopyWith<$Res> get unit;
  $StorageLocationCopyWith<$Res> get storageLocation;
}

/// @nodoc
class _$InventoryItemCopyWithImpl<$Res, $Val extends InventoryItem>
    implements $InventoryItemCopyWith<$Res> {
  _$InventoryItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InventoryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? householdId = null,
    Object? name = null,
    Object? categoryKey = null,
    Object? quantity = null,
    Object? unitKey = null,
    Object? storageLocationId = null,
    Object? preparedAt = freezed,
    Object? frozenAt = freezed,
    Object? openedAt = freezed,
    Object? expiresAt = freezed,
    Object? isHomemade = null,
    Object? status = null,
    Object? dateAdded = null,
    Object? notes = freezed,
    Object? createdBy = null,
    Object? updatedBy = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? category = null,
    Object? unit = null,
    Object? storageLocation = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      householdId: null == householdId
          ? _value.householdId
          : householdId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      categoryKey: null == categoryKey
          ? _value.categoryKey
          : categoryKey // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as String,
      unitKey: null == unitKey
          ? _value.unitKey
          : unitKey // ignore: cast_nullable_to_non_nullable
              as String,
      storageLocationId: null == storageLocationId
          ? _value.storageLocationId
          : storageLocationId // ignore: cast_nullable_to_non_nullable
              as String,
      preparedAt: freezed == preparedAt
          ? _value.preparedAt
          : preparedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      frozenAt: freezed == frozenAt
          ? _value.frozenAt
          : frozenAt // ignore: cast_nullable_to_non_nullable
              as String?,
      openedAt: freezed == openedAt
          ? _value.openedAt
          : openedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as String?,
      isHomemade: null == isHomemade
          ? _value.isHomemade
          : isHomemade // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      dateAdded: null == dateAdded
          ? _value.dateAdded
          : dateAdded // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      updatedBy: null == updatedBy
          ? _value.updatedBy
          : updatedBy // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as LocalizedLabel,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as LocalizedLabel,
      storageLocation: null == storageLocation
          ? _value.storageLocation
          : storageLocation // ignore: cast_nullable_to_non_nullable
              as StorageLocation,
    ) as $Val);
  }

  /// Create a copy of InventoryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocalizedLabelCopyWith<$Res> get category {
    return $LocalizedLabelCopyWith<$Res>(_value.category, (value) {
      return _then(_value.copyWith(category: value) as $Val);
    });
  }

  /// Create a copy of InventoryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocalizedLabelCopyWith<$Res> get unit {
    return $LocalizedLabelCopyWith<$Res>(_value.unit, (value) {
      return _then(_value.copyWith(unit: value) as $Val);
    });
  }

  /// Create a copy of InventoryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StorageLocationCopyWith<$Res> get storageLocation {
    return $StorageLocationCopyWith<$Res>(_value.storageLocation, (value) {
      return _then(_value.copyWith(storageLocation: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$InventoryItemImplCopyWith<$Res>
    implements $InventoryItemCopyWith<$Res> {
  factory _$$InventoryItemImplCopyWith(
          _$InventoryItemImpl value, $Res Function(_$InventoryItemImpl) then) =
      __$$InventoryItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String householdId,
      String name,
      String categoryKey,
      String quantity,
      String unitKey,
      String storageLocationId,
      String? preparedAt,
      String? frozenAt,
      String? openedAt,
      String? expiresAt,
      bool isHomemade,
      String status,
      String dateAdded,
      String? notes,
      String createdBy,
      String updatedBy,
      String createdAt,
      String updatedAt,
      LocalizedLabel category,
      LocalizedLabel unit,
      StorageLocation storageLocation});

  @override
  $LocalizedLabelCopyWith<$Res> get category;
  @override
  $LocalizedLabelCopyWith<$Res> get unit;
  @override
  $StorageLocationCopyWith<$Res> get storageLocation;
}

/// @nodoc
class __$$InventoryItemImplCopyWithImpl<$Res>
    extends _$InventoryItemCopyWithImpl<$Res, _$InventoryItemImpl>
    implements _$$InventoryItemImplCopyWith<$Res> {
  __$$InventoryItemImplCopyWithImpl(
      _$InventoryItemImpl _value, $Res Function(_$InventoryItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of InventoryItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? householdId = null,
    Object? name = null,
    Object? categoryKey = null,
    Object? quantity = null,
    Object? unitKey = null,
    Object? storageLocationId = null,
    Object? preparedAt = freezed,
    Object? frozenAt = freezed,
    Object? openedAt = freezed,
    Object? expiresAt = freezed,
    Object? isHomemade = null,
    Object? status = null,
    Object? dateAdded = null,
    Object? notes = freezed,
    Object? createdBy = null,
    Object? updatedBy = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? category = null,
    Object? unit = null,
    Object? storageLocation = null,
  }) {
    return _then(_$InventoryItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      householdId: null == householdId
          ? _value.householdId
          : householdId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      categoryKey: null == categoryKey
          ? _value.categoryKey
          : categoryKey // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _value.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as String,
      unitKey: null == unitKey
          ? _value.unitKey
          : unitKey // ignore: cast_nullable_to_non_nullable
              as String,
      storageLocationId: null == storageLocationId
          ? _value.storageLocationId
          : storageLocationId // ignore: cast_nullable_to_non_nullable
              as String,
      preparedAt: freezed == preparedAt
          ? _value.preparedAt
          : preparedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      frozenAt: freezed == frozenAt
          ? _value.frozenAt
          : frozenAt // ignore: cast_nullable_to_non_nullable
              as String?,
      openedAt: freezed == openedAt
          ? _value.openedAt
          : openedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as String?,
      isHomemade: null == isHomemade
          ? _value.isHomemade
          : isHomemade // ignore: cast_nullable_to_non_nullable
              as bool,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      dateAdded: null == dateAdded
          ? _value.dateAdded
          : dateAdded // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      updatedBy: null == updatedBy
          ? _value.updatedBy
          : updatedBy // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as LocalizedLabel,
      unit: null == unit
          ? _value.unit
          : unit // ignore: cast_nullable_to_non_nullable
              as LocalizedLabel,
      storageLocation: null == storageLocation
          ? _value.storageLocation
          : storageLocation // ignore: cast_nullable_to_non_nullable
              as StorageLocation,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InventoryItemImpl implements _InventoryItem {
  const _$InventoryItemImpl(
      {required this.id,
      required this.householdId,
      required this.name,
      required this.categoryKey,
      required this.quantity,
      required this.unitKey,
      required this.storageLocationId,
      this.preparedAt,
      this.frozenAt,
      this.openedAt,
      this.expiresAt,
      required this.isHomemade,
      required this.status,
      required this.dateAdded,
      this.notes,
      required this.createdBy,
      required this.updatedBy,
      required this.createdAt,
      required this.updatedAt,
      required this.category,
      required this.unit,
      required this.storageLocation});

  factory _$InventoryItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$InventoryItemImplFromJson(json);

  @override
  final String id;
  @override
  final String householdId;
  @override
  final String name;
  @override
  final String categoryKey;
  @override
  final String quantity;
  @override
  final String unitKey;
  @override
  final String storageLocationId;
  @override
  final String? preparedAt;
  @override
  final String? frozenAt;
  @override
  final String? openedAt;
  @override
  final String? expiresAt;
  @override
  final bool isHomemade;
  @override
  final String status;
  @override
  final String dateAdded;
  @override
  final String? notes;
  @override
  final String createdBy;
  @override
  final String updatedBy;
  @override
  final String createdAt;
  @override
  final String updatedAt;
  @override
  final LocalizedLabel category;
  @override
  final LocalizedLabel unit;
  @override
  final StorageLocation storageLocation;

  @override
  String toString() {
    return 'InventoryItem(id: $id, householdId: $householdId, name: $name, categoryKey: $categoryKey, quantity: $quantity, unitKey: $unitKey, storageLocationId: $storageLocationId, preparedAt: $preparedAt, frozenAt: $frozenAt, openedAt: $openedAt, expiresAt: $expiresAt, isHomemade: $isHomemade, status: $status, dateAdded: $dateAdded, notes: $notes, createdBy: $createdBy, updatedBy: $updatedBy, createdAt: $createdAt, updatedAt: $updatedAt, category: $category, unit: $unit, storageLocation: $storageLocation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InventoryItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.householdId, householdId) ||
                other.householdId == householdId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.categoryKey, categoryKey) ||
                other.categoryKey == categoryKey) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.unitKey, unitKey) || other.unitKey == unitKey) &&
            (identical(other.storageLocationId, storageLocationId) ||
                other.storageLocationId == storageLocationId) &&
            (identical(other.preparedAt, preparedAt) ||
                other.preparedAt == preparedAt) &&
            (identical(other.frozenAt, frozenAt) ||
                other.frozenAt == frozenAt) &&
            (identical(other.openedAt, openedAt) ||
                other.openedAt == openedAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            (identical(other.isHomemade, isHomemade) ||
                other.isHomemade == isHomemade) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.dateAdded, dateAdded) ||
                other.dateAdded == dateAdded) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.updatedBy, updatedBy) ||
                other.updatedBy == updatedBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.storageLocation, storageLocation) ||
                other.storageLocation == storageLocation));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        householdId,
        name,
        categoryKey,
        quantity,
        unitKey,
        storageLocationId,
        preparedAt,
        frozenAt,
        openedAt,
        expiresAt,
        isHomemade,
        status,
        dateAdded,
        notes,
        createdBy,
        updatedBy,
        createdAt,
        updatedAt,
        category,
        unit,
        storageLocation
      ]);

  /// Create a copy of InventoryItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InventoryItemImplCopyWith<_$InventoryItemImpl> get copyWith =>
      __$$InventoryItemImplCopyWithImpl<_$InventoryItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InventoryItemImplToJson(
      this,
    );
  }
}

abstract class _InventoryItem implements InventoryItem {
  const factory _InventoryItem(
      {required final String id,
      required final String householdId,
      required final String name,
      required final String categoryKey,
      required final String quantity,
      required final String unitKey,
      required final String storageLocationId,
      final String? preparedAt,
      final String? frozenAt,
      final String? openedAt,
      final String? expiresAt,
      required final bool isHomemade,
      required final String status,
      required final String dateAdded,
      final String? notes,
      required final String createdBy,
      required final String updatedBy,
      required final String createdAt,
      required final String updatedAt,
      required final LocalizedLabel category,
      required final LocalizedLabel unit,
      required final StorageLocation storageLocation}) = _$InventoryItemImpl;

  factory _InventoryItem.fromJson(Map<String, dynamic> json) =
      _$InventoryItemImpl.fromJson;

  @override
  String get id;
  @override
  String get householdId;
  @override
  String get name;
  @override
  String get categoryKey;
  @override
  String get quantity;
  @override
  String get unitKey;
  @override
  String get storageLocationId;
  @override
  String? get preparedAt;
  @override
  String? get frozenAt;
  @override
  String? get openedAt;
  @override
  String? get expiresAt;
  @override
  bool get isHomemade;
  @override
  String get status;
  @override
  String get dateAdded;
  @override
  String? get notes;
  @override
  String get createdBy;
  @override
  String get updatedBy;
  @override
  String get createdAt;
  @override
  String get updatedAt;
  @override
  LocalizedLabel get category;
  @override
  LocalizedLabel get unit;
  @override
  StorageLocation get storageLocation;

  /// Create a copy of InventoryItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InventoryItemImplCopyWith<_$InventoryItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StorageLocation _$StorageLocationFromJson(Map<String, dynamic> json) {
  return _StorageLocation.fromJson(json);
}

/// @nodoc
mixin _$StorageLocation {
  String get id => throw _privateConstructorUsedError;
  String get householdId => throw _privateConstructorUsedError;
  String? get parentId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  String get updatedBy => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  String get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this StorageLocation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StorageLocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StorageLocationCopyWith<StorageLocation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StorageLocationCopyWith<$Res> {
  factory $StorageLocationCopyWith(
          StorageLocation value, $Res Function(StorageLocation) then) =
      _$StorageLocationCopyWithImpl<$Res, StorageLocation>;
  @useResult
  $Res call(
      {String id,
      String householdId,
      String? parentId,
      String name,
      String type,
      int sortOrder,
      String createdBy,
      String updatedBy,
      String createdAt,
      String updatedAt});
}

/// @nodoc
class _$StorageLocationCopyWithImpl<$Res, $Val extends StorageLocation>
    implements $StorageLocationCopyWith<$Res> {
  _$StorageLocationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StorageLocation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? householdId = null,
    Object? parentId = freezed,
    Object? name = null,
    Object? type = null,
    Object? sortOrder = null,
    Object? createdBy = null,
    Object? updatedBy = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      householdId: null == householdId
          ? _value.householdId
          : householdId // ignore: cast_nullable_to_non_nullable
              as String,
      parentId: freezed == parentId
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      updatedBy: null == updatedBy
          ? _value.updatedBy
          : updatedBy // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StorageLocationImplCopyWith<$Res>
    implements $StorageLocationCopyWith<$Res> {
  factory _$$StorageLocationImplCopyWith(_$StorageLocationImpl value,
          $Res Function(_$StorageLocationImpl) then) =
      __$$StorageLocationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String householdId,
      String? parentId,
      String name,
      String type,
      int sortOrder,
      String createdBy,
      String updatedBy,
      String createdAt,
      String updatedAt});
}

/// @nodoc
class __$$StorageLocationImplCopyWithImpl<$Res>
    extends _$StorageLocationCopyWithImpl<$Res, _$StorageLocationImpl>
    implements _$$StorageLocationImplCopyWith<$Res> {
  __$$StorageLocationImplCopyWithImpl(
      _$StorageLocationImpl _value, $Res Function(_$StorageLocationImpl) _then)
      : super(_value, _then);

  /// Create a copy of StorageLocation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? householdId = null,
    Object? parentId = freezed,
    Object? name = null,
    Object? type = null,
    Object? sortOrder = null,
    Object? createdBy = null,
    Object? updatedBy = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$StorageLocationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      householdId: null == householdId
          ? _value.householdId
          : householdId // ignore: cast_nullable_to_non_nullable
              as String,
      parentId: freezed == parentId
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as String?,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      updatedBy: null == updatedBy
          ? _value.updatedBy
          : updatedBy // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StorageLocationImpl implements _StorageLocation {
  const _$StorageLocationImpl(
      {required this.id,
      required this.householdId,
      this.parentId,
      required this.name,
      required this.type,
      required this.sortOrder,
      required this.createdBy,
      required this.updatedBy,
      required this.createdAt,
      required this.updatedAt});

  factory _$StorageLocationImpl.fromJson(Map<String, dynamic> json) =>
      _$$StorageLocationImplFromJson(json);

  @override
  final String id;
  @override
  final String householdId;
  @override
  final String? parentId;
  @override
  final String name;
  @override
  final String type;
  @override
  final int sortOrder;
  @override
  final String createdBy;
  @override
  final String updatedBy;
  @override
  final String createdAt;
  @override
  final String updatedAt;

  @override
  String toString() {
    return 'StorageLocation(id: $id, householdId: $householdId, parentId: $parentId, name: $name, type: $type, sortOrder: $sortOrder, createdBy: $createdBy, updatedBy: $updatedBy, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StorageLocationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.householdId, householdId) ||
                other.householdId == householdId) &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.updatedBy, updatedBy) ||
                other.updatedBy == updatedBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, householdId, parentId, name,
      type, sortOrder, createdBy, updatedBy, createdAt, updatedAt);

  /// Create a copy of StorageLocation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StorageLocationImplCopyWith<_$StorageLocationImpl> get copyWith =>
      __$$StorageLocationImplCopyWithImpl<_$StorageLocationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StorageLocationImplToJson(
      this,
    );
  }
}

abstract class _StorageLocation implements StorageLocation {
  const factory _StorageLocation(
      {required final String id,
      required final String householdId,
      final String? parentId,
      required final String name,
      required final String type,
      required final int sortOrder,
      required final String createdBy,
      required final String updatedBy,
      required final String createdAt,
      required final String updatedAt}) = _$StorageLocationImpl;

  factory _StorageLocation.fromJson(Map<String, dynamic> json) =
      _$StorageLocationImpl.fromJson;

  @override
  String get id;
  @override
  String get householdId;
  @override
  String? get parentId;
  @override
  String get name;
  @override
  String get type;
  @override
  int get sortOrder;
  @override
  String get createdBy;
  @override
  String get updatedBy;
  @override
  String get createdAt;
  @override
  String get updatedAt;

  /// Create a copy of StorageLocation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StorageLocationImplCopyWith<_$StorageLocationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

InventoryItemListResponse _$InventoryItemListResponseFromJson(
    Map<String, dynamic> json) {
  return _InventoryItemListResponse.fromJson(json);
}

/// @nodoc
mixin _$InventoryItemListResponse {
  List<InventoryItem> get items => throw _privateConstructorUsedError;
  String? get nextPageToken => throw _privateConstructorUsedError;

  /// Serializes this InventoryItemListResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InventoryItemListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InventoryItemListResponseCopyWith<InventoryItemListResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InventoryItemListResponseCopyWith<$Res> {
  factory $InventoryItemListResponseCopyWith(InventoryItemListResponse value,
          $Res Function(InventoryItemListResponse) then) =
      _$InventoryItemListResponseCopyWithImpl<$Res, InventoryItemListResponse>;
  @useResult
  $Res call({List<InventoryItem> items, String? nextPageToken});
}

/// @nodoc
class _$InventoryItemListResponseCopyWithImpl<$Res,
        $Val extends InventoryItemListResponse>
    implements $InventoryItemListResponseCopyWith<$Res> {
  _$InventoryItemListResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InventoryItemListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? nextPageToken = freezed,
  }) {
    return _then(_value.copyWith(
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<InventoryItem>,
      nextPageToken: freezed == nextPageToken
          ? _value.nextPageToken
          : nextPageToken // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InventoryItemListResponseImplCopyWith<$Res>
    implements $InventoryItemListResponseCopyWith<$Res> {
  factory _$$InventoryItemListResponseImplCopyWith(
          _$InventoryItemListResponseImpl value,
          $Res Function(_$InventoryItemListResponseImpl) then) =
      __$$InventoryItemListResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<InventoryItem> items, String? nextPageToken});
}

/// @nodoc
class __$$InventoryItemListResponseImplCopyWithImpl<$Res>
    extends _$InventoryItemListResponseCopyWithImpl<$Res,
        _$InventoryItemListResponseImpl>
    implements _$$InventoryItemListResponseImplCopyWith<$Res> {
  __$$InventoryItemListResponseImplCopyWithImpl(
      _$InventoryItemListResponseImpl _value,
      $Res Function(_$InventoryItemListResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of InventoryItemListResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? items = null,
    Object? nextPageToken = freezed,
  }) {
    return _then(_$InventoryItemListResponseImpl(
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<InventoryItem>,
      nextPageToken: freezed == nextPageToken
          ? _value.nextPageToken
          : nextPageToken // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InventoryItemListResponseImpl implements _InventoryItemListResponse {
  const _$InventoryItemListResponseImpl(
      {required final List<InventoryItem> items, this.nextPageToken})
      : _items = items;

  factory _$InventoryItemListResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$InventoryItemListResponseImplFromJson(json);

  final List<InventoryItem> _items;
  @override
  List<InventoryItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final String? nextPageToken;

  @override
  String toString() {
    return 'InventoryItemListResponse(items: $items, nextPageToken: $nextPageToken)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InventoryItemListResponseImpl &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.nextPageToken, nextPageToken) ||
                other.nextPageToken == nextPageToken));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_items), nextPageToken);

  /// Create a copy of InventoryItemListResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InventoryItemListResponseImplCopyWith<_$InventoryItemListResponseImpl>
      get copyWith => __$$InventoryItemListResponseImplCopyWithImpl<
          _$InventoryItemListResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InventoryItemListResponseImplToJson(
      this,
    );
  }
}

abstract class _InventoryItemListResponse implements InventoryItemListResponse {
  const factory _InventoryItemListResponse(
      {required final List<InventoryItem> items,
      final String? nextPageToken}) = _$InventoryItemListResponseImpl;

  factory _InventoryItemListResponse.fromJson(Map<String, dynamic> json) =
      _$InventoryItemListResponseImpl.fromJson;

  @override
  List<InventoryItem> get items;
  @override
  String? get nextPageToken;

  /// Create a copy of InventoryItemListResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InventoryItemListResponseImplCopyWith<_$InventoryItemListResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}
