import 'package:dynora_finance/ui/bloc/navigation/navigation_bloc.dart';
import 'package:dynora_finance/ui/widgets/app_bar/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatelessWidget {
  MainLayout({super.key, required this.child});

  final Widget child;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<NavigationBloc, NavigationState>(
      listenWhen: (prev, curr) => curr.navigateTo != null,
      listener: (context, state) {
        context.go(state.navigateTo!);
      },
      child: PopScope(
        canPop: false,
        child: Scaffold(
          key: scaffoldKey,
          appBar: CustomAppbar(),
          body: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(18, 18, 18, 1),
                  Color.fromRGBO(30, 30, 30, 1),
                  Color.fromRGBO(42, 42, 42, 1),
                ],
              ),
            ),
            child: SafeArea(child: child),
          ),
        ),
      ),
    );
  }
}
