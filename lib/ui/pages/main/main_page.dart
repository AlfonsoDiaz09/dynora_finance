import 'package:dynora_finance/ui/pages/budget/budget_page.dart';
import 'package:dynora_finance/ui/pages/home/home_page.dart';
import 'package:dynora_finance/ui/pages/movements/movements_page.dart';
import 'package:dynora_finance/ui/pages/profile/profile_page.dart';
import 'package:dynora_finance/ui/pages/stats/stats_page.dart';
import 'package:dynora_finance/ui/widgets/add_transaction_sheet.dart';
import 'package:dynora_finance/ui/widgets/bottom_nav/bottom_nav_bar.dart';
import 'package:dynora_finance/ui/widgets/bottom_nav/quick_action_button.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 2;

  final List<Widget> _pages = const [
    MovementsPage(),
    StatsPage(),
    HomePage(),
    BudgetPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onFastActionTap() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AddTransactionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xff0F0F1A),
      body: IndexedStack(index: _currentIndex, children: _pages),
      floatingActionButton: QuickActionButton(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        onFastActionTap: _onFastActionTap,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped
      ),
    );
  }
}
