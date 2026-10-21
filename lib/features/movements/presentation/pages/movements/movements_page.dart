import 'package:dynora_finance/features/movements/presentation/cubit/movements_cubit.dart';
import 'package:dynora_finance/features/movements/presentation/widgets/movement_form_sheet.dart';
import 'package:dynora_finance/init_dependencies.dart';
import 'package:dynora_finance/shared/bloc/view_status.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:dynora_finance/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'widgets/movements_summary_card.dart';
import 'widgets/movement_filter_bar.dart';
import 'widgets/movement_group.dart';

class MovementsPage extends StatelessWidget {
  const MovementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<MovementsCubit>()..start(),
      child: BlocBuilder<MovementsCubit, MovementsState>(
        builder: (context, state) {
          final cubit = context.read<MovementsCubit>();

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                child: MovementsSummaryCard(
                  income: state.summary.income,
                  expense: state.summary.expense,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: MovementFilterBar(
                  monthLabel: Formatters.monthYear(state.month.start),
                  onPreviousMonth: cubit.previousMonth,
                  onNextMonth: cubit.nextMonth,
                ),
              ),
              SizedBox(height: 20.h),
              Expanded(child: _MovementsList(state: state)),
            ],
          );
        },
      ),
    );
  }
}

class _MovementsList extends StatelessWidget {
  const _MovementsList({required this.state});

  final MovementsState state;

  @override
  Widget build(BuildContext context) {
    switch (state.status) {
      case ViewStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case ViewStatus.failure:
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Align(
            alignment: Alignment.topCenter,
            child: EmptyState(
              icon: Icons.error_outline_rounded,
              message: state.error ?? 'No se pudieron cargar los movimientos',
            ),
          ),
        );
      case ViewStatus.loaded:
        if (state.groups.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Align(
              alignment: Alignment.topCenter,
              child: EmptyState(
                icon: Icons.receipt_long_rounded,
                message:
                    'Sin movimientos este mes.\n'
                    'Mantén presionado el botón de inicio para agregar uno.',
              ),
            ),
          );
        }
        return ListView.separated(
          padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 50.h),
          itemCount: state.groups.length,
          separatorBuilder: (_, __) => SizedBox(height: 20.h),
          itemBuilder: (context, index) {
            final group = state.groups[index];
            return MovementGroup(
              date: Formatters.relativeDay(group.day),
              movements: group.movements,
              categories: state.categories,
              cards: state.cards,
              debts: state.debts,
              onMovementTap: (movement) =>
                  MovementFormSheet.show(context, movement: movement),
            );
          },
        );
    }
  }
}
