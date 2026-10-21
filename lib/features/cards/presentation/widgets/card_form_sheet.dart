import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_entity.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_type.dart';
import 'package:dynora_finance/features/cards/presentation/cubit/card_form_cubit.dart';
import 'package:dynora_finance/features/cards/presentation/utils/card_labels.dart';
import 'package:dynora_finance/init_dependencies.dart';
import 'package:dynora_finance/shared/bloc/form_status.dart';
import 'package:dynora_finance/shared/widgets/form/app_text_field.dart';
import 'package:dynora_finance/shared/widgets/form/form_sheet.dart';
import 'package:dynora_finance/shared/widgets/form/segment_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const List<int> _cardColors = [
  0xFF7F00FF,
  0xFF448AFF,
  0xFF00BFA5,
  0xFFFF6D00,
  0xFFFF4081,
  0xFF9E9E9E,
];

class CardFormSheet extends StatefulWidget {
  const CardFormSheet({super.key, this.card});

  final CardEntity? card;

  /// Opens the form to create a card, or to edit [card].
  static Future<void> show(BuildContext context, {CardEntity? card}) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BlocProvider(
        create: (_) => CardFormCubit(
          addCard: serviceLocator(),
          updateCard: serviceLocator(),
          deleteCard: serviceLocator(),
          defaultColorValue: _cardColors.first,
          editing: card,
        ),
        child: CardFormSheet(card: card),
      ),
    );
  }

  @override
  State<CardFormSheet> createState() => _CardFormSheetState();
}

class _CardFormSheetState extends State<CardFormSheet> {
  late final TextEditingController _name = TextEditingController(
    text: widget.card?.name,
  );
  late final TextEditingController _digits = TextEditingController(
    text: widget.card?.lastFourDigits,
  );
  late final TextEditingController _cutoffDay = TextEditingController(
    text: widget.card?.cutoffDay?.toString(),
  );
  late final TextEditingController _dueDay = TextEditingController(
    text: widget.card?.paymentDueDay?.toString(),
  );
  late final TextEditingController _creditLimit = TextEditingController(
    text: widget.card?.creditLimit?.toStringAsFixed(2),
  );

  static final _dayFormatters = [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(2),
  ];

  @override
  void dispose() {
    _name.dispose();
    _digits.dispose();
    _cutoffDay.dispose();
    _dueDay.dispose();
    _creditLimit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CardFormCubit>();
    final isEditing = widget.card != null;

    return BlocConsumer<CardFormCubit, CardFormState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == FormStatus.success) Navigator.of(context).pop();
      },
      builder: (context, state) {
        final submitting = state.status == FormStatus.submitting;
        final billed = state.type.hasBillingCycle;

        return FormSheet(
          title: isEditing ? 'Editar tarjeta' : 'Nueva tarjeta',
          children: [
            Row(
              children: [
                for (final (index, type) in CardType.values.indexed) ...[
                  if (index > 0) SizedBox(width: 8.w),
                  Expanded(
                    child: SegmentOption(
                      label: type.label,
                      color: AppColors.secondary,
                      selected: state.type == type,
                      onTap: () => cubit.selectType(type),
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: 16.h),
            AppTextField(
              controller: _name,
              hint: 'Nombre (ej. BBVA Azul)',
              icon: Icons.credit_card_rounded,
            ),
            SizedBox(height: 12.h),
            AppTextField(
              controller: _digits,
              hint: 'Últimos 4 dígitos',
              icon: Icons.pin_rounded,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
            ),
            if (billed) ...[
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _cutoffDay,
                      hint: 'Día de corte',
                      icon: Icons.content_cut_rounded,
                      keyboardType: TextInputType.number,
                      inputFormatters: _dayFormatters,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: AppTextField(
                      controller: _dueDay,
                      hint: 'Día de pago',
                      icon: Icons.event_rounded,
                      keyboardType: TextInputType.number,
                      inputFormatters: _dayFormatters,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              AppTextField(
                controller: _creditLimit,
                hint: 'Límite de crédito',
                icon: Icons.account_balance_wallet_rounded,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: amountInputFormatters,
                textInputAction: TextInputAction.done,
              ),
            ],
            SizedBox(height: 16.h),
            const FormLabel('Color'),
            Wrap(
              spacing: 12.w,
              children: [
                for (final color in _cardColors)
                  GestureDetector(
                    onTap: () => cubit.selectColor(color),
                    child: Container(
                      width: 34.r,
                      height: 34.r,
                      decoration: BoxDecoration(
                        color: Color(color),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: state.colorValue == color
                              ? Colors.white
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            FormError(state.error),
            SizedBox(height: 20.h),
            PrimaryActionButton(
              text: 'Guardar',
              loading: submitting,
              onPressed: () => cubit.submit(
                name: _name.text,
                lastFourDigits: _digits.text,
                cutoffDay: billed ? int.tryParse(_cutoffDay.text) : null,
                paymentDueDay: billed ? int.tryParse(_dueDay.text) : null,
                creditLimit: billed && _creditLimit.text.trim().isNotEmpty
                    ? parseAmount(_creditLimit.text)
                    : null,
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
