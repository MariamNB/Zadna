import 'package:freezed_annotation/freezed_annotation.dart';

import 'localized_label.dart';

part 'reference_data.freezed.dart';
part 'reference_data.g.dart';

@freezed
class ReferenceDataResponse with _$ReferenceDataResponse {
  const factory ReferenceDataResponse({
    required List<LocalizedLabel> categories,
    required List<LocalizedLabel> units,
  }) = _ReferenceDataResponse;

  factory ReferenceDataResponse.fromJson(Map<String, dynamic> json) =>
      _$ReferenceDataResponseFromJson(json);
}