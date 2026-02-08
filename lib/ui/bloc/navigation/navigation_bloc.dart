import 'package:dynora_finance/ui/router/router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'navigation_state.dart';
part 'navigation_event.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(NavigationState.initial()) {
    on<NavigationEvent>((event, emit) {

    });

    on<NavigateTo>((event, emit) {
      emit(state.copyWith(navigateTo: event.route, isPushNavigation: event.isPush));
    });

    on<RouteChanged>((event, emit) {
      emit(state.copyWith(currentRoute: event.route, navigateTo: null, isPushNavigation: false));
    });
  }
}