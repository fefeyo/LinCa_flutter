import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'app_router.gr.dart';

class AuthGuard extends AutoRouteGuard {
  const AuthGuard();

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      router.push(const LoginRoute());
    } else {
      resolver.next(true);
    }
  }
}
