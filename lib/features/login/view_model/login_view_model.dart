import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../data/login_state.dart';

final StateNotifierProvider<LoginViewModel, LoginState>
    loginViewModelProvider =
    StateNotifierProvider<LoginViewModel, LoginState>(
        (Ref ref) => LoginViewModel());

class LoginViewModel extends StateNotifier<LoginState> {
  LoginViewModel() : super(const LoginState());
}
