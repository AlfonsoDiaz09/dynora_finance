import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';
import 'package:dynora_finance/features/movements/presentation/cubit/movement_form_cubit.dart';
import 'package:dynora_finance/init_dependencies.dart';
import 'package:dynora_finance/shared/bloc/form_status.dart';
import 'package:dynora_finance/shared/utils/category_icons.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:dynora_finance/shared/widgets/form/app_text_field.dart';
import 'package:dynora_finance/shared/widgets/form/form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MovementFormSheet extends StatefulWidget {
  const MovementFormSheet({super.key, this.movement});

  final MovementEntity? movement;

  /// Opens the form to create a movement, or to edit [movement].
  static Future<void> show(
    BuildContext context, {
    MovementType initialType = MovementType.expense,
    MovementEntity? movement,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BlocProvider(
        create: (_) => MovementFormCubit(
          watchCategories: serviceLocator(),
          addMovement: serviceLocator(),
          updateMovement: serviceLocator(),
          deleteMovement: serviceLocator(),
          initialType: initialType,
          editing: movement,
        )..start(),
        child: MovementFormSheet(movement: movement),
      ),
    );
  }

  @override
  State<MovementFormSheet> createState() => _MovementFormSheetState();
}

class _MovementFormSheetState extends State<MovementFormSheet> {
  late final TextEditingController _title;
  late final TextEditingController _amount;
  late final TextEditingController _note;

  @override
  void initState() {
    super.initState();
    final movement = widget.movement;
    _title = TextEditingController(text: movement?.title);
    _amount = TextEditingController(text: movement?.amount.toStringAsFixed(2));
    _note = TextEditingController(text: movement?.note);
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickDate(MovementFormCubit cubit) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: cubit.state.date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) cubit.changeDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MovementFormCubit>();
    final isEditing = widget.movement != null;

    return BlocConsumer<MovementFormCubit, MovementFormState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == FormStatus.success) Navigator.of(context).pop();
      },
      builder: (context, state) {
        final submitting = state.status == FormStatus.submitting;

        return FormSheet(
          title: isEditing ? 'Editar transacción' : 'Nueva Transacción',
          children: [
            Row(
              children: [
                Expanded(
                  child: _TypeOption(
                    label: 'Gasto',
                    color: AppColors.error,
                    selected: state.type == MovementType.expense,
                    onTap: () => cubit.changeType(MovementType.expense),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _TypeOption(
                    label: 'Ingreso',
                    color: AppColors.success,
                    selected: state.type == MovementType.income,
                    onTap: () => cubit.changeType(MovementType.income),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            AppTextField(
              controller: _title,
              hint: 'Concepto',
              icon: Icons.edit_rounded,
            ),
            SizedBox(height: 12.h),
            AppTextField(
              controller: _amount,
              hint: 'Monto',
              icon: Icons.attach_money_rounded,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: amountInputFormatters,
            ),
            SizedBox(height: 16.h),
            const FormLabel('Categoría'),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                for (final category in state.categoriesOfType)
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
            const FormLabel('Fecha'),
            InkWell(
              borderRadius: BorderRadius.circular(16.r),
              onTap: () => _pickDate(cubit),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      color: AppColors.textPrimary70,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      Formatters.relativeDay(state.date),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),
            AppTextField(
              controller: _note,
              hint: 'Nota (opcional)',
              icon: Icons.notes_rounded,
              textInputAction: TextInputAction.done,
            ),
            FormError(state.error),
            SizedBox(height: 20.h),
            PrimaryActionButton(
              text: 'Guardar',
              loading: submitting,
              onPressed: () => cubit.submit(
                title: _title.text,
                amount: parseAmount(_amount.text),
                note: _note.text,
              ),
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

class _TypeOption extends StatelessWidget {
  const _TypeOption({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14.r),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: selected ? color : Colors.transparent),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : AppColors.textPrimary70,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
