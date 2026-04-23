import 'package:dynora_finance/app/layouts/main_layout.dart';
import 'package:dynora_finance/features/about/presentation/pages/about/about_page.dart';
import 'package:dynora_finance/features/auth/presentation/pages/login/login_page.dart';
import 'package:dynora_finance/features/auth/presentation/pages/register/register_page.dart';
import 'package:dynora_finance/features/budget/presentation/pages/budget/budget_page.dart';
import 'package:dynora_finance/features/home/presentation/pages/home/home_page.dart';
import 'package:dynora_finance/features/movements/presentation/pages/movements/movements_page.dart';
import 'package:dynora_finance/features/profile/presentation/pages/profile/profile_page.dart';
import 'package:dynora_finance/features/splash/presentation/pages/splash/splash_page.dart';
import 'package:dynora_finance/features/stats/presentation/pages/stats/stats_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

abstract class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const about = '/about';
  static const home = '/home';
  static const movements = '/movements';
  static const stats = '/stats';
  static const budget = '/budget';
  static const profile = '/profile';
}

abstract class LoaderIds {
  static const splashLoader = 'splash_loader';
}

GoRouter createRouter() {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRoutes.home,
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
      GoRoute(
        path: AppRoutes.about,
        name: AppRoutes.about,
        builder: (_, __) => AboutPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainLayout(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.movements,
                name: AppRoutes.movements,
                builder: (_, __) => MovementsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.stats,
                name: AppRoutes.stats,
                builder: (_, __) => StatsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: AppRoutes.home,
                builder: (_, __) => HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.budget,
                name: AppRoutes.budget,
                builder: (_, __) => BudgetPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: AppRoutes.profile,
                builder: (_, __) => ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
