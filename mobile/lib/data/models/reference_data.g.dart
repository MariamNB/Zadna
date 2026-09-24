// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reference_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReferenceDataResponseImpl _$$ReferenceDataResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$ReferenceDataResponseImpl(
      categories: (json['categories'] as List<dynamic>)
          .map((e) => LocalizedLabel.fromJson(e as Map<String, dynamic>))
          .toList(),
      units: (json['units'] as List<dynamic>)
          .map((e) => LocalizedLabel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$ReferenceDataResponseImplToJson(
        _$ReferenceDataResponseImpl instance) =>
    <String, dynamic>{
      'categories': instance.categories,
      'units': instance.units,
    };
