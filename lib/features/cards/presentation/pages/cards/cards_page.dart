import 'package:dynora_finance/app/router/router.dart';
import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/features/cards/presentation/cubit/cards_cubit.dart';
import 'package:dynora_finance/features/cards/presentation/pages/cards/widgets/card_tile.dart';
import 'package:dynora_finance/features/cards/presentation/pages/cards/widgets/monthly_plan_card.dart';
import 'package:dynora_finance/features/cards/presentation/widgets/card_form_sheet.dart';
import 'package:dynora_finance/init_dependencies.dart';
import 'package:dynora_finance/shared/bloc/view_status.dart';
import 'package:dynora_finance/shared/widgets/app_bar/custom_appbar.dart';
import 'package:dynora_finance/shared/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class CardsPage extends StatelessWidget {
  const CardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<CardsCubit>()..start(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CustomAppbar(title: 'Mis tarjetas', canBack: true),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            backgroundColor: Colors.purpleAccent,
            onPressed: () => CardFormSheet.show(context),
            child: const Icon(Icons.add_card_rounded),
          ),
        ),
        body: BlocBuilder<CardsCubit, CardsState>(
          builder: (context, state) {
            switch (state.status) {
              case ViewStatus.loading:
                return const Center(child: CircularProgressIndicator());
              case ViewStatus.failure:
                return Padding(
                  padding: EdgeInsets.all(20.r),
                  child: EmptyState(
                    icon: Icons.error_outline_rounded,
                    message:
                        state.error ?? 'No se pudieron cargar tus tarjetas',
                  ),
                );
              case ViewStatus.loaded:
                return ListView(
                  padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 100.h),
                  children: [
                    if (state.plan case final plan?)
                      MonthlyPlanCard(plan: plan),
                    SizedBox(height: 28.h),
                    Text(
                      'Tus tarjetas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    if (state.cards.isEmpty)
                      const EmptyState(
                        icon: Icons.credit_card_rounded,
                        message:
                            'Aún no tienes tarjetas.\n'
                            'Toca + para agregar una.',
                      )
                    else
                      for (final (index, overview) in state.cards.indexed) ...[
                        if (index > 0) SizedBox(height: 12.h),
                        CardTile(
                          overview: overview,
                          onTap: () => context.push(
                            AppRoutes.cardDetailPath(overview.card.id),
                          ),
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
