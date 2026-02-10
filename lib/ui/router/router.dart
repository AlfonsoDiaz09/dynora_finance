import 'package:dynora_finance/ui/bloc/navigation/navigation_bloc.dart';
import 'package:dynora_finance/ui/pages/about/about_page.dart';
import 'package:dynora_finance/ui/pages/auth/login/login_page.dart';
import 'package:dynora_finance/ui/pages/splash/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

abstract class AppRoutes {
  static const splash = '/splash';
  static const about = '/about';
  static const login = '/login';
}

abstract class LoaderIds {
  static const splashLoader = 'splash_loader';
}

GoRouter createRouter(NavigationBloc navigationBloc) {
  final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRoutes.login,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: AppRoutes.splash,
        builder: (_, __) => SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.login,
        builder: (_, __) => LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.about,
        name: AppRoutes.about,
        builder: (_, __) => AboutPage(),
      ),
    ],
  );

  router.routerDelegate.addListener(() {
    final currentName = router.state.name;
    if (currentName != null) {
      navigationBloc.add(RouteChanged(currentName));
    }
  });

  return router;
}
