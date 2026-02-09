part of 'navigation_bloc.dart';

class NavigationState {
  final String currentRoute;
  final String? navigateTo;
  final bool isPushNavigation;

  const NavigationState({
    required this.currentRoute,
    this.navigateTo,
    this.isPushNavigation = false
  });

  NavigationState copyWith({
    String? currentRoute,
    String? navigateTo,
    bool? isPushNavigation
  }) {
    return NavigationState(
      currentRoute: currentRoute ?? this.currentRoute,
      navigateTo: navigateTo,
      isPushNavigation: isPushNavigation ?? this.isPushNavigation
    );
  }

  static NavigationState initial() => NavigationState(currentRoute: AppRoutes.splash);
}