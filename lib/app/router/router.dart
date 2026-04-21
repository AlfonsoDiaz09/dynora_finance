import 'package:dynora_finance/app/bloc/navigation/navigation_bloc.dart';
import 'package:dynora_finance/app/layouts/app_shell.dart';
import 'package:dynora_finance/app/layouts/main_navigation.dart';
import 'package:dynora_finance/features/about/presentation/pages/about/about_page.dart';
import 'package:dynora_finance/features/auth/presentation/pages/login/login_page.dart';
import 'package:dynora_finance/features/auth/presentation/pages/register/register_page.dart';
import 'package:dynora_finance/features/splash/presentation/pages/splash/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

abstract class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const about = '/about';
  static const main = '/main';
}

abstract class LoaderIds {
  static const splashLoader = 'splash_loader';
}

GoRouter createRouter(NavigationBloc navigationBloc) {
  final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRoutes.main,
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
        path: AppRoutes.register,
        name: AppRoutes.register,
        builder: (_, __) => RegisterPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.about,
            name: AppRoutes.about,
            builder: (_, __) => AboutPage(),
          ),
          GoRoute(
            path: AppRoutes.main,
            name: AppRoutes.main,
            builder: (_, __) => MainNavigation(),
          ),
        ],
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
