// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'localized_label.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

LocalizedLabel _$LocalizedLabelFromJson(Map<String, dynamic> json) {
  return _LocalizedLabel.fromJson(json);
}

/// @nodoc
mixin _$LocalizedLabel {
  String get key => throw _privateConstructorUsedError;
  Map<String, String> get labels => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this LocalizedLabel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LocalizedLabel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LocalizedLabelCopyWith<LocalizedLabel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocalizedLabelCopyWith<$Res> {
  factory $LocalizedLabelCopyWith(
          LocalizedLabel value, $Res Function(LocalizedLabel) then) =
      _$LocalizedLabelCopyWithImpl<$Res, LocalizedLabel>;
  @useResult
  $Res call(
      {String key, Map<String, String> labels, int sortOrder, bool isActive});
}

/// @nodoc
class _$LocalizedLabelCopyWithImpl<$Res, $Val extends LocalizedLabel>
    implements $LocalizedLabelCopyWith<$Res> {
  _$LocalizedLabelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LocalizedLabel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? labels = null,
    Object? sortOrder = null,
    Object? isActive = null,
  }) {
    return _then(_value.copyWith(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      labels: null == labels
          ? _value.labels
          : labels // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LocalizedLabelImplCopyWith<$Res>
    implements $LocalizedLabelCopyWith<$Res> {
  factory _$$LocalizedLabelImplCopyWith(_$LocalizedLabelImpl value,
          $Res Function(_$LocalizedLabelImpl) then) =
      __$$LocalizedLabelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String key, Map<String, String> labels, int sortOrder, bool isActive});
}

/// @nodoc
class __$$LocalizedLabelImplCopyWithImpl<$Res>
    extends _$LocalizedLabelCopyWithImpl<$Res, _$LocalizedLabelImpl>
    implements _$$LocalizedLabelImplCopyWith<$Res> {
  __$$LocalizedLabelImplCopyWithImpl(
      _$LocalizedLabelImpl _value, $Res Function(_$LocalizedLabelImpl) _then)
      : super(_value, _then);

  /// Create a copy of LocalizedLabel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? key = null,
    Object? labels = null,
    Object? sortOrder = null,
    Object? isActive = null,
  }) {
    return _then(_$LocalizedLabelImpl(
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      labels: null == labels
          ? _value._labels
          : labels // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LocalizedLabelImpl implements _LocalizedLabel {
  const _$LocalizedLabelImpl(
      {required this.key,
      required final Map<String, String> labels,
      required this.sortOrder,
      required this.isActive})
      : _labels = labels;

  factory _$LocalizedLabelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocalizedLabelImplFromJson(json);

  @override
  final String key;
  final Map<String, String> _labels;
  @override
  Map<String, String> get labels {
    if (_labels is EqualUnmodifiableMapView) return _labels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_labels);
  }

  @override
  final int sortOrder;
  @override
  final bool isActive;

  @override
  String toString() {
    return 'LocalizedLabel(key: $key, labels: $labels, sortOrder: $sortOrder, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocalizedLabelImpl &&
            (identical(other.key, key) || other.key == key) &&
            const DeepCollectionEquality().equals(other._labels, _labels) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, key,
      const DeepCollectionEquality().hash(_labels), sortOrder, isActive);

  /// Create a copy of LocalizedLabel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocalizedLabelImplCopyWith<_$LocalizedLabelImpl> get copyWith =>
      __$$LocalizedLabelImplCopyWithImpl<_$LocalizedLabelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LocalizedLabelImplToJson(
      this,
    );
  }
}

abstract class _LocalizedLabel implements LocalizedLabel {
  const factory _LocalizedLabel(
      {required final String key,
      required final Map<String, String> labels,
      required final int sortOrder,
      required final bool isActive}) = _$LocalizedLabelImpl;

  factory _LocalizedLabel.fromJson(Map<String, dynamic> json) =
      _$LocalizedLabelImpl.fromJson;

  @override
  String get key;
  @override
  Map<String, String> get labels;
  @override
  int get sortOrder;
  @override
  bool get isActive;

  /// Create a copy of LocalizedLabel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocalizedLabelImplCopyWith<_$LocalizedLabelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
