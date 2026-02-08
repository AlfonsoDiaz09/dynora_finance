part of 'navigation_bloc.dart';

class NavigationEvent {}

class NavigateTo extends NavigationEvent {
  final String route;
  final bool isPush;
  NavigateTo(this.route, {this.isPush = false});
}

class RouteChanged extends NavigationEvent {
  final String route;
  RouteChanged(this.route);
}