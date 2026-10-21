import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_entity.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_statement.dart';
import 'package:dynora_finance/features/cards/presentation/cubit/card_payment_form_cubit.dart';
import 'package:dynora_finance/features/cards/presentation/utils/card_labels.dart';
import 'package:dynora_finance/init_dependencies.dart';
import 'package:dynora_finance/shared/bloc/form_status.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:dynora_finance/shared/widgets/form/app_text_field.dart';
import 'package:dynora_finance/shared/widgets/form/form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Registers (or edits) the payment of one card statement.
class CardPaymentSheet extends StatefulWidget {
  const CardPaymentSheet({
    super.key,
    required this.card,
    required this.statement,
  });

  final CardEntity card;
  final CardStatement statement;

  static Future<void> show(
    BuildContext context, {
    required CardEntity card,
    required CardStatement statement,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BlocProvider(
        create: (_) => CardPaymentFormCubit(
          cardId: card.id,
          statement: statement,
          registerPayment: serviceLocator(),
          deletePayment: serviceLocator(),
        ),
        child: CardPaymentSheet(card: card, statement: statement),
      ),
    );
  }

  @override
  State<CardPaymentSheet> createState() => _CardPaymentSheetState();
}

class _CardPaymentSheetState extends State<CardPaymentSheet> {
  late final TextEditingController _amount = TextEditingController(
    text: (widget.statement.payment?.amount ?? widget.statement.total)
        .toStringAsFixed(2),
  );

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _pickDate(CardPaymentFormCubit cubit) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: cubit.state.paidAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) cubit.changePaidAt(picked);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CardPaymentFormCubit>();
    final statement = widget.statement;
    final period = statement.period;
    final isEditing = statement.payment != null;

    return BlocConsumer<CardPaymentFormCubit, CardPaymentFormState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == FormStatus.success) Navigator.of(context).pop();
      },
      builder: (context, state) {
        final submitting = state.status == FormStatus.submitting;

        return FormSheet(
          title: isEditing ? 'Editar pago' : 'Registrar pago',
          children: [
            Text(
              widget.card.shortLabel,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Periodo ${Formatters.shortDate(period.start)} – '
              '${Formatters.shortDate(period.end)} · '
              'vence ${Formatters.shortDate(period.paymentDate)}\n'
              'Total del periodo ${Formatters.currency(statement.total)}',
              style: TextStyle(color: AppColors.textPrimary70, fontSize: 13.sp),
            ),
            SizedBox(height: 16.h),
            AppTextField(
              controller: _amount,
              hint: 'Monto pagado',
              icon: Icons.attach_money_rounded,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: amountInputFormatters,
              textInputAction: TextInputAction.done,
            ),
            SizedBox(height: 16.h),
            const FormLabel('Fecha en que pagaste'),
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
                      Formatters.relativeDay(state.paidAt),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            FormError(state.error),
            SizedBox(height: 20.h),
            PrimaryActionButton(
              text: 'Guardar pago',
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
