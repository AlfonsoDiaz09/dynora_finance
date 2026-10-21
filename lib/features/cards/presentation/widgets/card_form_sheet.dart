import 'package:dynora_finance/features/cards/domain/entities/card_entity.dart';
import 'package:dynora_finance/features/cards/presentation/cubit/card_form_cubit.dart';
import 'package:dynora_finance/init_dependencies.dart';
import 'package:dynora_finance/shared/bloc/form_status.dart';
import 'package:dynora_finance/shared/widgets/form/app_text_field.dart';
import 'package:dynora_finance/shared/widgets/form/form_sheet.dart';
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
  late final TextEditingController _dueDay = TextEditingController(
    text: widget.card?.paymentDueDay.toString(),
  );

  @override
  void dispose() {
    _name.dispose();
    _dueDay.dispose();
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

        return FormSheet(
          title: isEditing ? 'Editar tarjeta' : 'Nueva tarjeta',
          children: [
            AppTextField(
              controller: _name,
              hint: 'Nombre (ej. BBVA Azul)',
              icon: Icons.credit_card_rounded,
            ),
            SizedBox(height: 12.h),
            AppTextField(
              controller: _dueDay,
              hint: 'Día de pago (1-31)',
              icon: Icons.event_rounded,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
              textInputAction: TextInputAction.done,
            ),
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
                dueDay: int.tryParse(_dueDay.text),
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
