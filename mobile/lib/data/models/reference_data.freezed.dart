// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reference_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ReferenceDataResponse _$ReferenceDataResponseFromJson(
    Map<String, dynamic> json) {
  return _ReferenceDataResponse.fromJson(json);
}

/// @nodoc
mixin _$ReferenceDataResponse {
  List<LocalizedLabel> get categories => throw _privateConstructorUsedError;
  List<LocalizedLabel> get units => throw _privateConstructorUsedError;

  /// Serializes this ReferenceDataResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReferenceDataResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReferenceDataResponseCopyWith<ReferenceDataResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReferenceDataResponseCopyWith<$Res> {
  factory $ReferenceDataResponseCopyWith(ReferenceDataResponse value,
          $Res Function(ReferenceDataResponse) then) =
      _$ReferenceDataResponseCopyWithImpl<$Res, ReferenceDataResponse>;
  @useResult
  $Res call({List<LocalizedLabel> categories, List<LocalizedLabel> units});
}

/// @nodoc
class _$ReferenceDataResponseCopyWithImpl<$Res,
        $Val extends ReferenceDataResponse>
    implements $ReferenceDataResponseCopyWith<$Res> {
  _$ReferenceDataResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReferenceDataResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categories = null,
    Object? units = null,
  }) {
    return _then(_value.copyWith(
      categories: null == categories
          ? _value.categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<LocalizedLabel>,
      units: null == units
          ? _value.units
          : units // ignore: cast_nullable_to_non_nullable
              as List<LocalizedLabel>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReferenceDataResponseImplCopyWith<$Res>
    implements $ReferenceDataResponseCopyWith<$Res> {
  factory _$$ReferenceDataResponseImplCopyWith(
          _$ReferenceDataResponseImpl value,
          $Res Function(_$ReferenceDataResponseImpl) then) =
      __$$ReferenceDataResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<LocalizedLabel> categories, List<LocalizedLabel> units});
}

/// @nodoc
class __$$ReferenceDataResponseImplCopyWithImpl<$Res>
    extends _$ReferenceDataResponseCopyWithImpl<$Res,
        _$ReferenceDataResponseImpl>
    implements _$$ReferenceDataResponseImplCopyWith<$Res> {
  __$$ReferenceDataResponseImplCopyWithImpl(_$ReferenceDataResponseImpl _value,
      $Res Function(_$ReferenceDataResponseImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReferenceDataResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categories = null,
    Object? units = null,
  }) {
    return _then(_$ReferenceDataResponseImpl(
      categories: null == categories
          ? _value._categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<LocalizedLabel>,
      units: null == units
          ? _value._units
          : units // ignore: cast_nullable_to_non_nullable
              as List<LocalizedLabel>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReferenceDataResponseImpl implements _ReferenceDataResponse {
  const _$ReferenceDataResponseImpl(
      {required final List<LocalizedLabel> categories,
      required final List<LocalizedLabel> units})
      : _categories = categories,
        _units = units;

  factory _$ReferenceDataResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReferenceDataResponseImplFromJson(json);

  final List<LocalizedLabel> _categories;
  @override
  List<LocalizedLabel> get categories {
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categories);
  }

  final List<LocalizedLabel> _units;
  @override
  List<LocalizedLabel> get units {
    if (_units is EqualUnmodifiableListView) return _units;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_units);
  }

  @override
  String toString() {
    return 'ReferenceDataResponse(categories: $categories, units: $units)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReferenceDataResponseImpl &&
            const DeepCollectionEquality()
                .equals(other._categories, _categories) &&
            const DeepCollectionEquality().equals(other._units, _units));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_categories),
      const DeepCollectionEquality().hash(_units));

  /// Create a copy of ReferenceDataResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReferenceDataResponseImplCopyWith<_$ReferenceDataResponseImpl>
      get copyWith => __$$ReferenceDataResponseImplCopyWithImpl<
          _$ReferenceDataResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReferenceDataResponseImplToJson(
      this,
    );
  }
}

abstract class _ReferenceDataResponse implements ReferenceDataResponse {
  const factory _ReferenceDataResponse(
      {required final List<LocalizedLabel> categories,
      required final List<LocalizedLabel> units}) = _$ReferenceDataResponseImpl;

  factory _ReferenceDataResponse.fromJson(Map<String, dynamic> json) =
      _$ReferenceDataResponseImpl.fromJson;

  @override
  List<LocalizedLabel> get categories;
  @override
  List<LocalizedLabel> get units;

  /// Create a copy of ReferenceDataResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReferenceDataResponseImplCopyWith<_$ReferenceDataResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}
