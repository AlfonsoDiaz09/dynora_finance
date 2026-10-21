import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/features/cards/presentation/cubit/card_detail_cubit.dart';
import 'package:dynora_finance/features/cards/presentation/pages/card_detail/widgets/card_header.dart';
import 'package:dynora_finance/features/cards/presentation/pages/card_detail/widgets/month_section.dart';
import 'package:dynora_finance/features/cards/presentation/pages/card_detail/widgets/statement_section.dart';
import 'package:dynora_finance/features/cards/presentation/widgets/card_form_sheet.dart';
import 'package:dynora_finance/features/movements/presentation/widgets/movement_form_sheet.dart';
import 'package:dynora_finance/init_dependencies.dart';
import 'package:dynora_finance/shared/bloc/view_status.dart';
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
                    onEdit: () => CardFormSheet.show(context, card: card),
                  ),
                  SizedBox(height: 24.h),
                  if (card.hasBillingCycle)
                    for (final statement in state.statements) ...[
                      StatementSection(
                        statement: statement,
                        categories: state.categories,
                        onMovementTap: (movement) =>
                            MovementFormSheet.show(context, movement: movement),
                      ),
                      SizedBox(height: 24.h),
                    ]
                  else if (state.months.isEmpty)
                    const EmptyState(
                      icon: Icons.receipt_long_rounded,
                      message: 'Aún no hay movimientos con esta tarjeta',
                    )
                  else
                    for (final month in state.months) ...[
                      MonthSection(
                        month: month,
                        categories: state.categories,
                        onMovementTap: (movement) =>
                            MovementFormSheet.show(context, movement: movement),
                      ),
                      SizedBox(height: 24.h),
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
