import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/features/loans/domain/entities/loan_entity.dart';
import 'package:dynora_finance/features/loans/presentation/cubit/loan_form_cubit.dart';
import 'package:dynora_finance/features/loans/presentation/utils/loan_labels.dart';
import 'package:dynora_finance/init_dependencies.dart';
import 'package:dynora_finance/shared/bloc/form_status.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:dynora_finance/shared/widgets/form/app_text_field.dart';
import 'package:dynora_finance/shared/widgets/form/date_field.dart';
import 'package:dynora_finance/shared/widgets/form/form_sheet.dart';
import 'package:dynora_finance/shared/widgets/form/segment_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoanFormSheet extends StatefulWidget {
  const LoanFormSheet({super.key, this.loan});

  final LoanEntity? loan;

  /// Opens the form to register a loan, or to edit [loan].
  static Future<void> show(
    BuildContext context, {
    LoanEntity? loan,
    LoanDirection direction = LoanDirection.borrowed,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BlocProvider(
        create: (_) => LoanFormCubit(
          saveLoan: serviceLocator(),
          deleteLoan: serviceLocator(),
          direction: direction,
          editing: loan,
        ),
        child: LoanFormSheet(loan: loan),
      ),
    );
  }

  @override
  State<LoanFormSheet> createState() => _LoanFormSheetState();
}

class _LoanFormSheetState extends State<LoanFormSheet> {
  String? _fixed(double? value) => value?.toStringAsFixed(2);

  late final _name = TextEditingController(text: widget.loan?.name);
  late final _principal = TextEditingController(
    text: _fixed(widget.loan?.principal),
  );
  late final _rate = TextEditingController(
    text: _fixed(widget.loan?.interestRate),
  );
  late final _installment = TextEditingController(
    text: _fixed(widget.loan?.installmentAmount),
  );
  late final _count = TextEditingController(
    text: widget.loan?.installmentCount?.toString(),
  );
  late final _note = TextEditingController(text: widget.loan?.note);

  @override
  void dispose() {
    for (final c in [_name, _principal, _rate, _installment, _count, _note]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LoanFormCubit>();
    final isEditing = widget.loan != null;

    return BlocConsumer<LoanFormCubit, LoanFormState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == FormStatus.success) Navigator.of(context).pop();
      },
      builder: (context, state) {
        final submitting = state.status == FormStatus.submitting;
        final institution = state.kind == LoanKind.institution;
        final lent = state.direction == LoanDirection.lent;

        return FormSheet(
          title: isEditing ? 'Editar préstamo' : state.direction.newTitle,
          children: [
            if (!lent)
              Row(
                children: [
                  Expanded(
                    child: SegmentOption(
                      label: 'Institución',
                      color: AppColors.secondary,
                      selected: institution,
                      onTap: () => cubit.selectKind(LoanKind.institution),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: SegmentOption(
                      label: 'Persona',
                      color: AppColors.secondary,
                      selected: !institution,
                      onTap: () => cubit.selectKind(LoanKind.personal),
                    ),
                  ),
                ],
              ),
            if (!lent) SizedBox(height: 16.h),
            AppTextField(
              controller: _name,
              hint: institution
                  ? 'Banco o financiera'
                  : state.direction.personHint,
              icon: institution
                  ? Icons.account_balance_rounded
                  : Icons.person_rounded,
            ),
            SizedBox(height: 12.h),
            AppTextField(
              controller: _principal,
              hint: 'Monto prestado',
              icon: Icons.attach_money_rounded,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: amountInputFormatters,
            ),
            SizedBox(height: 16.h),
            FormLabel(lent ? '¿Cuándo lo prestaste?' : '¿Cuándo lo recibiste?'),
            DateField(
              date: state.startDate,
              lastDate: DateTime.now(),
              onChanged: cubit.changeStartDate,
            ),
            _SwitchRow(
              label: state.direction.cashSwitch,
              value: state.countsAsIncome,
              onChanged: cubit.setCountsAsIncome,
            ),
            if (!institution) ...[
              AppTextField(
                controller: _rate,
                hint: 'Interés fijo % (opcional)',
                icon: Icons.percent_rounded,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: amountInputFormatters,
              ),
              _SwitchRow(
                label: 'Tiene pagos fijos mensuales',
                value: state.fixedPayments,
                onChanged: cubit.setFixedPayments,
              ),
            ],
            if (state.hasFixedPayments) ...[
              if (institution) SizedBox(height: 4.h),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _installment,
                      hint: 'Pago mensual',
                      icon: Icons.payments_rounded,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: amountInputFormatters,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  SizedBox(
                    width: 130.w,
                    child: AppTextField(
                      controller: _count,
                      hint: institution ? 'Pagos' : 'Pagos (opc.)',
                      icon: Icons.tag_rounded,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              const FormLabel('Fecha del primer pago'),
              DateField(
                date: state.firstPaymentDate,
                placeholder: 'Elegir fecha (define el día de pago)',
                onChanged: cubit.changeFirstPaymentDate,
              ),
            ],
            SizedBox(height: 12.h),
            ListenableBuilder(
              listenable: Listenable.merge([
                _principal,
                _rate,
                _installment,
                _count,
              ]),
              builder: (context, _) => Text(
                _preview(cubit),
                style: TextStyle(
                  color: AppColors.textPrimary70,
                  fontSize: 12.sp,
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
                name: _name.text,
                principal: parseAmount(_principal.text),
                interestRate: parseAmount(_rate.text),
                installmentAmount: parseAmount(_installment.text),
                installmentCount: int.tryParse(_count.text),
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

  /// `Total a pagar $13,800.00 · Intereses $1,800.00 · 12 pagos`
  String _preview(LoanFormCubit cubit) {
    final principal = parseAmount(_principal.text);
    if (principal == null || principal <= 0) {
      return 'Ingresa el monto para ver el total a pagar';
    }
    final loan = cubit.draft(
      name: '',
      principal: principal,
      interestRate: parseAmount(_rate.text),
      installmentAmount: parseAmount(_installment.text),
      installmentCount: int.tryParse(_count.text),
    );
    final payments = loan.hasSchedule ? ' · ${loan.schedule.length} pagos' : '';
    return 'Total a pagar ${Formatters.currency(loan.totalToPay)} · '
        'Intereses ${Formatters.currency(loan.interest)}$payments';
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: AppColors.textPrimary85, fontSize: 13.sp),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.secondary,
        ),
      ],
    );
  }
}
