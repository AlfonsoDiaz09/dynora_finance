import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/features/budget/domain/entities/budget_entity.dart';
import 'package:dynora_finance/features/budget/presentation/cubit/budget_form_cubit.dart';
import 'package:dynora_finance/init_dependencies.dart';
import 'package:dynora_finance/shared/bloc/form_status.dart';
import 'package:dynora_finance/shared/utils/category_icons.dart';
import 'package:dynora_finance/shared/widgets/form/app_text_field.dart';
import 'package:dynora_finance/shared/widgets/form/form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BudgetFormSheet extends StatefulWidget {
  const BudgetFormSheet({super.key, this.budget});

  final BudgetEntity? budget;

  /// Opens the form to create a budget, or to edit [budget].
  static Future<void> show(BuildContext context, {BudgetEntity? budget}) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BlocProvider(
        create: (_) => BudgetFormCubit(
          watchCategories: serviceLocator(),
          setBudget: serviceLocator(),
          deleteBudget: serviceLocator(),
          editing: budget,
        )..start(),
        child: BudgetFormSheet(budget: budget),
      ),
    );
  }

  @override
  State<BudgetFormSheet> createState() => _BudgetFormSheetState();
}

class _BudgetFormSheetState extends State<BudgetFormSheet> {
  late final TextEditingController _amount = TextEditingController(
    text: widget.budget?.amount.toStringAsFixed(2),
  );

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BudgetFormCubit>();
    final isEditing = widget.budget != null;

    return BlocConsumer<BudgetFormCubit, BudgetFormState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == FormStatus.success) Navigator.of(context).pop();
      },
      builder: (context, state) {
        final submitting = state.status == FormStatus.submitting;

        return FormSheet(
          title: isEditing ? 'Editar presupuesto' : 'Nuevo presupuesto',
          children: [
            const FormLabel('Categoría'),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                for (final category in state.categories)
                  if (!isEditing || category.id == state.categoryId)
                    ChoiceChip(
                      avatar: Icon(
                        CategoryIcons.of(category.iconKey),
                        size: 18.sp,
                        color: Color(category.colorValue),
                      ),
                      label: Text(category.name),
                      selected: state.categoryId == category.id,
                      onSelected: (_) => cubit.selectCategory(category.id),
                      showCheckmark: false,
                      labelStyle: const TextStyle(color: Colors.white),
                      backgroundColor: Colors.white.withValues(alpha: 0.05),
                      selectedColor: AppColors.primary40,
                      side: BorderSide.none,
                    ),
              ],
            ),
            SizedBox(height: 16.h),
            AppTextField(
              controller: _amount,
              hint: 'Límite mensual',
              icon: Icons.attach_money_rounded,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: amountInputFormatters,
              textInputAction: TextInputAction.done,
            ),
            FormError(state.error),
            SizedBox(height: 20.h),
            PrimaryActionButton(
              text: 'Guardar',
              loading: submitting,
              onPressed: () => cubit.submit(parseAmount(_amount.text)),
            ),
            if (isEditing) ...[
              SizedBox(height: 8.h),
              DeleteActionButton(onPressed: submitting ? null : cubit.delete),
            ],
          ],
        );
      },
    );
  }
}
