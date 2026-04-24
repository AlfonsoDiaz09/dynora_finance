import 'package:dynora_finance/app/bloc/navigation_cubit/navigation_cubit.dart';
import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/shared/widgets/add_transaction_sheet.dart';
import 'package:dynora_finance/shared/widgets/app_bar/custom_appbar.dart';
import 'package:dynora_finance/shared/widgets/bottom_nav/bottom_nav_bar.dart';
import 'package:dynora_finance/shared/widgets/bottom_nav/quick_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatelessWidget {
  MainLayout({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final List _names = [
    'Movimientos',
    'Estadisticas',
    'Inicio',
    'Presupuesto',
    'Perfil',
  ];
  final List _canBack = [false, true, true, true, false];

  void _onTap(BuildContext context, int index) {
    context.read<NavigationCubit>().changeIndex(index);
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  void _onFastActionTap(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AddTransactionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int currentIndex = navigationShell.currentIndex;
    return PopScope(
      canPop: false,
      child: Scaffold(
        key: scaffoldKey,
        extendBody: true,
        backgroundColor: AppColors.background,
        appBar: CustomAppbar(
          indexCurrent: currentIndex,
          title: _names[currentIndex],
          canBack: _canBack[currentIndex],
        ),
        body: SafeArea(child: navigationShell),
        floatingActionButton: QuickActionButton(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => _onTap(context, index),
          onFastActionTap: () => _onFastActionTap(context),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomNavBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => _onTap(context, index),
        ),
      ),
    );
  }
}
