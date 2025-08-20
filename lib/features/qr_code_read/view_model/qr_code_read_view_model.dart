import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../data/qr_code_read_state.dart';

final StateNotifierProvider<QrCodeReadViewModel, QrCodeReadState>
    qrCodeReadViewModelProvider =
    StateNotifierProvider<QrCodeReadViewModel, QrCodeReadState>(
        (Ref ref) => QrCodeReadViewModel());

class QrCodeReadViewModel extends StateNotifier<QrCodeReadState> {
  QrCodeReadViewModel() : super(const QrCodeReadState());
}
