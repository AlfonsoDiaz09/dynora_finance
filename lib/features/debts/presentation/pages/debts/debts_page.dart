import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/features/debts/presentation/cubit/debts_cubit.dart';
import 'package:dynora_finance/features/debts/presentation/pages/debts/widgets/person_debts_card.dart';
import 'package:dynora_finance/init_dependencies.dart';
import 'package:dynora_finance/shared/bloc/view_status.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:dynora_finance/shared/widgets/app_bar/custom_appbar.dart';
import 'package:dynora_finance/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DebtsPage extends StatelessWidget {
  const DebtsPage({super.key});

  /// Asks the day the money was received (defaults to today).
  static Future<DateTime?> pickPaidDate(BuildContext context) {
    final now = DateTime.now();
    return showDatePicker(
      context: context,
      helpText: '¿Cuándo te pagaron?',
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: now,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<DebtsCubit>()..start(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CustomAppbar(title: 'Me deben', canBack: true),
        body: BlocConsumer<DebtsCubit, DebtsState>(
          listenWhen: (prev, curr) =>
              curr.error != null && prev.error != curr.error,
          listener: (context, state) => ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error!))),
          builder: (context, state) {
            final cubit = context.read<DebtsCubit>();
            switch (state.status) {
              case ViewStatus.loading:
                return const Center(child: CircularProgressIndicator());
              case ViewStatus.failure:
                return Padding(
                  padding: EdgeInsets.all(20.r),
                  child: EmptyState(
                    icon: Icons.error_outline_rounded,
                    message: state.error ?? 'No se pudieron cargar las deudas',
                  ),
                );
              case ViewStatus.loaded:
                final visible = state.visible;
                return ListView(
                  padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 60.h),
                  children: [
                    _TotalCard(state: state),
                    SizedBox(height: 20.h),
                    Wrap(
                      spacing: 8.w,
                      children: [
                        for (final (filter, label) in const [
                          (DebtFilter.pending, 'Pendientes'),
                          (DebtFilter.paid, 'Pagados'),
                          (DebtFilter.all, 'Todos'),
                        ])
                          ChoiceChip(
                            label: Text(label),
                            selected: state.filter == filter,
                            onSelected: (_) => cubit.changeFilter(filter),
                            showCheckmark: false,
                            labelStyle: const TextStyle(color: Colors.white),
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.05,
                            ),
                            selectedColor: AppColors.primary40,
                            side: BorderSide.none,
                          ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    if (visible.isEmpty)
                      EmptyState(
                        icon: Icons.handshake_rounded,
                        message: state.people.isEmpty
                            ? 'Nadie te debe todavía.\n'
                                  'Al registrar un gasto activa '
                                  '"¿Te deben de esta compra?".'
                            : 'No hay deudas en este filtro',
                      )
                    else
                      for (final (index, person) in visible.indexed) ...[
                        if (index > 0) SizedBox(height: 14.h),
                        PersonDebtsCard(
                          person: person,
                          onMarkPaid: (ids) async {
                            final date = await pickPaidDate(context);
                            if (date != null) cubit.markPaid(ids, date);
                          },
                          onMarkPending: cubit.markPending,
                        ),
                      ],
                  ],
                );
            }
          },
        ),
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.state});

  final DebtsState state;

  @override
  Widget build(BuildContext context) {
    final people = state.peopleWithPending;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Te deben en total',
            style: TextStyle(color: AppColors.textPrimary70),
          ),
          SizedBox(height: 6.h),
          Text(
            Formatters.currency(state.totalPending),
            style: TextStyle(
              color: Colors.white,
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6.h),
          Text(switch (people) {
            0 => 'Todos están al corriente',
            1 => '1 persona con saldo pendiente',
            _ => '$people personas con saldo pendiente',
          }, style: TextStyle(color: AppColors.textPrimary85, fontSize: 13.sp)),
        ],
      ),
    );
  }
}
