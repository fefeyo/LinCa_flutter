import 'package:freezed_annotation/freezed_annotation.dart';

part 'qr_code_read_state.freezed.dart';
part 'qr_code_read_state.g.dart';

@freezed
abstract class QrCodeReadState with _$QrCodeReadState {
  const factory QrCodeReadState({
    @Default('') String name,
  }) = _QrCodeReadState;

  factory QrCodeReadState.fromJson(Map<String, dynamic> json) =>
      _$QrCodeReadStateFromJson(json);
}
