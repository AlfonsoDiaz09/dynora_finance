import 'package:dynora_finance/main.dart';
import 'package:dynora_finance/ui/bloc/navigation/navigation_bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState>navigatorKey = GlobalKey();

abstract class AppRoutes {
  static const home = '/home';
}

abstract class LoaderIds {
  static const homeLoader = 'home_loader';
}

GoRouter createRouter(NavigationBloc navigationBloc) {
  final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        name: AppRoutes.home,
        builder: (_, __) => MyApp(),
      ),
    ]
  );

  router.routerDelegate.addListener(() {
    final currentName = router.state.name;
    if (currentName != null) {
      navigationBloc.add(RouteChanged(currentName));
    }
  });

  return router;
}