import 'package:freezed_annotation/freezed_annotation.dart';

part 'localized_label.freezed.dart';
part 'localized_label.g.dart';

@freezed
class LocalizedLabel with _$LocalizedLabel {
  const factory LocalizedLabel({
    required String key,
    required Map<String, String> labels,
    required int sortOrder,
    required bool isActive,
  }) = _LocalizedLabel;

  factory LocalizedLabel.fromJson(Map<String, dynamic> json) =>
      _$LocalizedLabelFromJson(json);
}