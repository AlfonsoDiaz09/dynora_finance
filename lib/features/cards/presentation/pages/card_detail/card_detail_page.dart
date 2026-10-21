import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/core/utils/month_range.dart';
import 'package:dynora_finance/features/cards/domain/entities/billing_period.dart';
import 'package:dynora_finance/features/cards/presentation/cubit/card_detail_cubit.dart';
import 'package:dynora_finance/features/cards/presentation/pages/card_detail/widgets/card_header.dart';
import 'package:dynora_finance/features/cards/presentation/pages/card_detail/widgets/month_section.dart';
import 'package:dynora_finance/features/cards/presentation/pages/card_detail/widgets/period_filter.dart';
import 'package:dynora_finance/features/cards/presentation/pages/card_detail/widgets/statement_section.dart';
import 'package:dynora_finance/features/cards/presentation/widgets/card_form_sheet.dart';
import 'package:dynora_finance/features/cards/presentation/widgets/card_payment_sheet.dart';
import 'package:dynora_finance/features/movements/presentation/widgets/movement_form_sheet.dart';
import 'package:dynora_finance/init_dependencies.dart';
import 'package:dynora_finance/shared/bloc/view_status.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:dynora_finance/shared/widgets/app_bar/custom_appbar.dart';
import 'package:dynora_finance/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class CardDetailPage extends StatelessWidget {
  const CardDetailPage({super.key, required this.cardId});

  final String cardId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CardDetailCubit(
        cardId: cardId,
        watchCards: serviceLocator(),
        watchMovements: serviceLocator(),
        watchCategories: serviceLocator(),
        watchCardPayments: serviceLocator(),
        watchDebts: serviceLocator(),
        watchPeople: serviceLocator(),
      )..start(),
      child: BlocConsumer<CardDetailCubit, CardDetailState>(
        // Leave the page once the card is deleted from its edit form.
        listenWhen: (prev, curr) =>
            prev.card != null &&
            curr.status == ViewStatus.loaded &&
            curr.card == null,
        listener: (context, _) => context.pop(),
        builder: (context, state) {
          final card = state.card;
          final cubit = context.read<CardDetailCubit>();

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: CustomAppbar(title: card?.name ?? 'Tarjeta', canBack: true),
            floatingActionButton: card == null
                ? null
                : FloatingActionButton(
                    backgroundColor: Colors.purpleAccent,
                    tooltip: 'Agregar movimiento con esta tarjeta',
                    onPressed: () =>
                        MovementFormSheet.show(context, initialCardId: card.id),
                    child: const Icon(Icons.add),
                  ),
            body: switch (state.status) {
              ViewStatus.loading => const Center(
                child: CircularProgressIndicator(),
              ),
              ViewStatus.failure => Padding(
                padding: EdgeInsets.all(20.r),
                child: EmptyState(
                  icon: Icons.error_outline_rounded,
                  message: state.error ?? 'No se pudo cargar la tarjeta',
                ),
              ),
              ViewStatus.loaded when card == null => Padding(
                padding: EdgeInsets.all(20.r),
                child: const EmptyState(message: 'Esta tarjeta ya no existe'),
              ),
              ViewStatus.loaded => ListView(
                padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 100.h),
                children: [
                  CardHeader(
                    card: card!,
                    statement: card.hasBillingCycle
                        ? state.selectedStatement
                        : null,
                    onEdit: () => CardFormSheet.show(context, card: card),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    card.hasBillingCycle ? 'Periodo' : 'Mes',
                    style: TextStyle(
                      color: AppColors.textPrimary70,
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  if (card.hasBillingCycle) ...[
                    PeriodFilter<BillingPeriod>(
                      items: [
                        for (final s in state.statements.reversed) s.period,
                      ],
                      selected: state.selectedPeriod,
                      label: (p) => Formatters.monthShortYear(p.paymentDate),
                      tense: (p) => _periodTense(p, DateTime.now()),
                      onSelected: cubit.selectPeriod,
                    ),
                    SizedBox(height: 20.h),
                    if (state.selectedStatement case final statement?)
                      StatementSection(
                        statement: statement,
                        categories: state.categories,
                        debtors: state.debtors,
                        onMovementTap: (movement) =>
                            MovementFormSheet.show(context, movement: movement),
                        onPaymentTap: () => CardPaymentSheet.show(
                          context,
                          card: card,
                          statement: statement,
                        ),
                      ),
                  ] else ...[
                    PeriodFilter<MonthRange>(
                      items: [for (final m in state.months.reversed) m.month],
                      selected: state.selectedMonth,
                      label: (m) => Formatters.monthShortYear(m.start),
                      tense: (m) => _monthTense(m, DateTime.now()),
                      onSelected: cubit.selectMonth,
                    ),
                    SizedBox(height: 20.h),
                    if (state.selectedMonthMovements case final month?)
                      MonthSection(
                        month: month,
                        categories: state.categories,
                        debtors: state.debtors,
                        onMovementTap: (movement) =>
                            MovementFormSheet.show(context, movement: movement),
                      ),
                  ],
                ],
              ),
            },
          );
        },
      ),
    );
  }
}

PeriodTense _periodTense(BillingPeriod period, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  if (period.end.isBefore(today)) return PeriodTense.past;
  if (period.start.isAfter(today)) return PeriodTense.future;
  return PeriodTense.current;
}

PeriodTense _monthTense(MonthRange month, DateTime now) {
  if (month.contains(now)) return PeriodTense.current;
  return month.end.isBefore(now) ? PeriodTense.past : PeriodTense.future;
}
