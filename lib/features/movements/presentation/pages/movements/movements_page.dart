import 'package:dynora_finance/app/router/router.dart';
import 'package:dynora_finance/features/movements/presentation/cubit/movements_cubit.dart';
import 'package:dynora_finance/features/movements/presentation/widgets/movement_form_sheet.dart';
import 'package:dynora_finance/init_dependencies.dart';
import 'package:dynora_finance/shared/bloc/view_status.dart';
import 'package:dynora_finance/shared/widgets/empty_state.dart';
import 'package:dynora_finance/shared/widgets/month_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'widgets/movement_filters.dart';
import 'widgets/movement_group.dart';
import 'widgets/movement_statement_group.dart';
import 'widgets/movements_summary_card.dart';

class MovementsPage extends StatelessWidget {
  const MovementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<MovementsCubit>()..start(),
      child: BlocBuilder<MovementsCubit, MovementsState>(
        builder: (context, state) {
          final cubit = context.read<MovementsCubit>();

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
                sliver: SliverList.list(
                  children: [
                    MonthSwitcher(
                      month: state.month.start,
                      onPrevious: cubit.previousMonth,
                      onNext: cubit.nextMonth,
                      onToday: cubit.currentMonth,
                    ),
                    SizedBox(height: 12.h),
                    MovementsSummaryCard(
                      income: state.ledger.income,
                      expense: state.ledger.expense,
                    ),
                    SizedBox(height: 16.h),
                    MovementFilters(
                      typeFilter: state.typeFilter,
                      query: state.query,
                      onTypeChanged: cubit.changeTypeFilter,
                      onSearch: cubit.search,
                    ),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
              ..._list(context, state),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _list(BuildContext context, MovementsState state) {
    Widget message(Widget child) => SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      sliver: SliverToBoxAdapter(child: child),
    );

    switch (state.status) {
      case ViewStatus.loading:
        return [
          SliverPadding(
            padding: EdgeInsets.only(top: 40.h),
            sliver: const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        ];
      case ViewStatus.failure:
        return [
          message(
            EmptyState(
              icon: Icons.error_outline_rounded,
              message: state.error ?? 'No se pudieron cargar los movimientos',
            ),
          ),
        ];
      case ViewStatus.loaded:
        final groups = state.groups;
        if (groups.isEmpty) {
          return [
            message(
              EmptyState(
                icon: state.isFiltered
                    ? Icons.search_off_rounded
                    : Icons.receipt_long_rounded,
                message: state.isFiltered
                    ? 'Ningún movimiento coincide con tu búsqueda'
                    : 'Sin movimientos este mes.\n'
                          'Mantén presionado el botón de inicio para '
                          'agregar uno.',
              ),
            ),
          ];
        }
        return [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 110.h),
            sliver: SliverList.separated(
              itemCount: groups.length,
              separatorBuilder: (_, __) => SizedBox(height: 20.h),
              itemBuilder: (context, index) => switch (groups[index]) {
                final MovementDayGroup group => MovementGroup(
                  group: group,
                  categories: state.categories,
                  cards: state.cards,
                  debts: state.debts,
                  onMovementTap: (movement) =>
                      MovementFormSheet.show(context, movement: movement),
                ),
                final MovementStatementGroup group => MovementStatementView(
                  group: group,
                  categories: state.categories,
                  debts: state.debts,
                  onMovementTap: (movement) =>
                      MovementFormSheet.show(context, movement: movement),
                  onCardTap: () =>
                      context.push(AppRoutes.cardDetailPath(group.card.id)),
                ),
              },
            ),
          ),
        ];
    }
  }
}
