import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_payment_entity.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_summary.dart';
import 'package:dynora_finance/features/loans/presentation/cubit/loan_form_cubit.dart';
import 'package:dynora_finance/init_dependencies.dart';
import 'package:dynora_finance/shared/bloc/form_status.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:dynora_finance/shared/widgets/form/app_text_field.dart';
import 'package:dynora_finance/shared/widgets/form/date_field.dart';
import 'package:dynora_finance/shared/widgets/form/form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Registers (or edits) a payment of a loan.
class LoanPaymentSheet extends StatefulWidget {
  const LoanPaymentSheet({super.key, required this.summary, this.payment});

  final LoanSummary summary;
  final LoanPaymentEntity? payment;

  static Future<void> show(
    BuildContext context, {
    required LoanSummary summary,
    LoanPaymentEntity? payment,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BlocProvider(
        create: (_) => LoanPaymentFormCubit(
          loanId: summary.loan.id,
          savePayment: serviceLocator(),
          deletePayment: serviceLocator(),
          editing: payment,
        ),
        child: LoanPaymentSheet(summary: summary, payment: payment),
      ),
    );
  }

  @override
  State<LoanPaymentSheet> createState() => _LoanPaymentSheetState();
}

class _LoanPaymentSheetState extends State<LoanPaymentSheet> {
  /// The edited amount, or what is due next (installment or balance).
  late final TextEditingController _amount = TextEditingController(
    text:
        (widget.payment?.amount ??
                widget.summary.nextInstallment?.missing ??
                widget.summary.remaining)
            .toStringAsFixed(2),
  );
  late final TextEditingController _note = TextEditingController(
    text: widget.payment?.note,
  );

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LoanPaymentFormCubit>();
    final summary = widget.summary;
    final isEditing = widget.payment != null;

    return BlocConsumer<LoanPaymentFormCubit, LoanPaymentFormState>(
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
              summary.loan.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Restan ${Formatters.currency(summary.remaining)} '
              'de ${Formatters.currency(summary.total)}',
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
            ),
            SizedBox(height: 16.h),
            const FormLabel('Fecha en que pagaste'),
            DateField(
              date: state.paidAt,
              lastDate: DateTime.now(),
              onChanged: cubit.changePaidAt,
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
              text: 'Guardar pago',
              loading: submitting,
              onPressed: () =>
                  cubit.submit(parseAmount(_amount.text), _note.text),
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
