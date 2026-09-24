// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'localized_label.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LocalizedLabelImpl _$$LocalizedLabelImplFromJson(Map<String, dynamic> json) =>
    _$LocalizedLabelImpl(
      key: json['key'] as String,
      labels: Map<String, String>.from(json['labels'] as Map),
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$$LocalizedLabelImplToJson(
        _$LocalizedLabelImpl instance) =>
    <String, dynamic>{
      'key': instance.key,
      'labels': instance.labels,
      'sortOrder': instance.sortOrder,
      'isActive': instance.isActive,
    };
