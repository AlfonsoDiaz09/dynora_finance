import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/features/budget/presentation/cubit/budget_cubit.dart';
import 'package:dynora_finance/features/budget/presentation/widgets/budget_form_sheet.dart';
import 'package:dynora_finance/init_dependencies.dart';
import 'package:dynora_finance/shared/bloc/view_status.dart';
import 'package:dynora_finance/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'widgets/budget_summary_card.dart';
import 'widgets/category_budget_card.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<BudgetCubit>()..start(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocBuilder<BudgetCubit, BudgetState>(
          builder: (context, state) {
            return ListView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              children: [
                SizedBox(height: 20.h),
                BudgetSummaryCard(
                  total: state.totalLimit,
                  spent: state.totalSpent,
                ),
                SizedBox(height: 30.h),
                Text(
                  "Por categoría",
                  style: TextStyle(
                    color: AppColors.textPrimary70,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 15.h),
                ..._content(context, state),
                SizedBox(height: 80.h),
              ],
            );
          },
        ),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: 120.h),
          child: Builder(
            builder: (context) => FloatingActionButton(
              backgroundColor: Colors.purpleAccent,
              onPressed: () => BudgetFormSheet.show(context),
              child: Icon(Icons.add),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _content(BuildContext context, BudgetState state) {
    switch (state.status) {
      case ViewStatus.loading:
        return const [Center(child: CircularProgressIndicator())];
      case ViewStatus.failure:
        return [
          EmptyState(
            icon: Icons.error_outline_rounded,
            message: state.error ?? 'No se pudieron cargar los presupuestos',
          ),
        ];
      case ViewStatus.loaded:
        if (state.items.isEmpty) {
          return const [
            EmptyState(
              icon: Icons.savings_rounded,
              message: 'Aún no tienes presupuestos.\n'
                  'Toca + para definir un límite por categoría.',
            ),
          ];
        }
        return [
          for (final (index, item) in state.items.indexed) ...[
            if (index > 0) SizedBox(height: 15.h),
            CategoryBudgetCard(
              category: item.category.name,
              spent: item.spent,
              total: item.budget.amount,
              onTap: () => BudgetFormSheet.show(context, budget: item.budget),
            ),
          ],
        ];
    }
  }
}
