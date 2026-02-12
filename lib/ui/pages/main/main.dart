import 'package:dynora_finance/ui/pages/budget/budget_page.dart';
import 'package:dynora_finance/ui/pages/home/home_page.dart';
import 'package:dynora_finance/ui/pages/movements/movements_page.dart';
import 'package:dynora_finance/ui/pages/profile/profile_page.dart';
import 'package:dynora_finance/ui/pages/stats/stats_page.dart';
import 'package:dynora_finance/ui/widgets/add_transaction_sheet.dart';
import 'package:dynora_finance/ui/widgets/custom_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
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
      floatingActionButton: GestureDetector(
        onTap: () => _onItemTapped(2),
        onLongPress: _onFastActionTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          width: 60.w,
          height: 60.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xff7F00FF), Color(0xffE100FF)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.purpleAccent,
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            _currentIndex == 2 ? Icons.home_rounded : Icons.home_outlined,
            color: Colors.white,
            size: 28.sp,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        onFastActionTap: _onFastActionTap,
      ),
    );
  }
}
