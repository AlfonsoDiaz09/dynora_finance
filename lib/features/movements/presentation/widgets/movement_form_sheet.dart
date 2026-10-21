import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/core/enums/movement_type.dart';
import 'package:dynora_finance/core/enums/payment_method.dart';
import 'package:dynora_finance/features/cards/domain/entities/card_entity.dart';
import 'package:dynora_finance/features/debts/domain/entities/debt_split.dart';
import 'package:dynora_finance/features/cards/domain/entities/billing_period.dart';
import 'package:dynora_finance/features/cards/presentation/utils/card_labels.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';
import 'package:dynora_finance/features/movements/presentation/cubit/movement_form_cubit.dart';
import 'package:dynora_finance/features/movements/presentation/cubit/share_draft.dart';
import 'package:dynora_finance/init_dependencies.dart';
import 'package:dynora_finance/shared/bloc/form_status.dart';
import 'package:dynora_finance/shared/utils/category_icons.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:dynora_finance/shared/widgets/form/app_text_field.dart';
import 'package:dynora_finance/shared/widgets/form/form_sheet.dart';
import 'package:dynora_finance/shared/widgets/form/segment_option.dart';
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
    String? initialCardId,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BlocProvider(
        create: (_) => MovementFormCubit(
          watchCategories: serviceLocator(),
          watchCards: serviceLocator(),
          addMovement: serviceLocator(),
          updateMovement: serviceLocator(),
          deleteMovement: serviceLocator(),
          watchPeople: serviceLocator(),
          addPerson: serviceLocator(),
          watchDebts: serviceLocator(),
          setMovementDebts: serviceLocator(),
          initialType: initialType,
          initialCardId: initialCardId,
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
  late final TextEditingController _rate;
  final TextEditingController _newPerson = TextEditingController();
  final Map<String, TextEditingController> _shareAmounts = {};

  TextEditingController _shareAmount(String personId, ShareDraft share) {
    return _shareAmounts.putIfAbsent(
      personId,
      () => TextEditingController(
        text: share.initialAmounts[personId]?.toStringAsFixed(2),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final movement = widget.movement;
    _title = TextEditingController(text: movement?.title);
    _amount = TextEditingController(text: movement?.amount.toStringAsFixed(2));
    _note = TextEditingController(text: movement?.note);
    _rate = TextEditingController(
      text: movement?.installmentRate?.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _note.dispose();
    _rate.dispose();
    _newPerson.dispose();
    for (final controller in _shareAmounts.values) {
      controller.dispose();
    }
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
                  child: SegmentOption(
                    label: 'Gasto',
                    color: AppColors.error,
                    selected:
                        state.type == MovementType.expense &&
                        !state.isWithdrawal,
                    onTap: () => cubit.changeType(MovementType.expense),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: SegmentOption(
                    label: 'Ingreso',
                    color: AppColors.success,
                    selected: state.type == MovementType.income,
                    onTap: () => cubit.changeType(MovementType.income),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: SegmentOption(
                    label: 'Disposición',
                    color: AppColors.info,
                    selected: state.isWithdrawal,
                    onTap: () {
                      cubit.selectWithdrawal();
                      if (_title.text.trim().isEmpty) {
                        _title.text = 'Disposición de efectivo';
                      }
                    },
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
            if (!state.isWithdrawal) ...[
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
            ],
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
            SizedBox(height: 16.h),
            FormLabel(state.isWithdrawal ? 'Tarjeta de crédito' : 'Pagado con'),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                if (!state.isWithdrawal) ...[
                  _PaymentChip(
                    label: 'Efectivo',
                    icon: Icons.payments_rounded,
                    selected: state.paymentMethod == PaymentMethod.cash,
                    onSelected: () => cubit.selectMethod(PaymentMethod.cash),
                  ),
                  _PaymentChip(
                    label: 'Transferencia',
                    icon: Icons.swap_horiz_rounded,
                    selected: state.paymentMethod == PaymentMethod.transfer,
                    onSelected: () =>
                        cubit.selectMethod(PaymentMethod.transfer),
                  ),
                ],
                for (final card in state.availableCards)
                  _PaymentChip(
                    label: card.shortLabel,
                    icon: Icons.credit_card_rounded,
                    iconColor: Color(card.colorValue),
                    selected: state.cardId == card.id,
                    onSelected: () => cubit.selectCard(card.id),
                  ),
              ],
            ),
            if (state.isWithdrawal && state.selectedCard != null)
              _WithdrawalSection(
                state: state,
                amount: _amount,
                rate: _rate,
                onCountChanged: cubit.selectInstallmentCount,
              )
            else if (state.canUseInstallments)
              _InstallmentSection(
                state: state,
                amount: _amount,
                rate: _rate,
                onModeChanged: cubit.selectInstallmentMode,
                onCountChanged: cubit.selectInstallmentCount,
              )
            else if (state.selectedCard case final card?
                when card.hasBillingCycle)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Text(
                  _periodHint(card.billingPeriodFor(state.date)),
                  style: TextStyle(
                    color: AppColors.textPrimary70,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            if (state.type == MovementType.expense && !state.isWithdrawal)
              _ShareSection(
                state: state,
                amount: _amount,
                newPerson: _newPerson,
                shareAmount: (id) => _shareAmount(id, state.share),
                onToggle: cubit.toggleSharing,
                onTogglePerson: cubit.togglePerson,
                onAddPerson: () {
                  cubit.addPerson(_newPerson.text);
                  _newPerson.clear();
                },
                onModeChanged: cubit.selectSplitMode,
                onIncludeMeChanged: cubit.setIncludeMe,
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
                interestRate: parseAmount(_rate.text),
                customShares: {
                  for (final id in state.share.personIds)
                    id: parseAmount(_shareAmount(id, state.share).text),
                },
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

String _periodHint(BillingPeriod period) =>
    'Periodo ${Formatters.shortDate(period.start)} – '
    '${Formatters.shortDate(period.end)} · '
    'se paga el ${Formatters.shortDate(period.paymentDate)}';

class _PaymentChip extends StatelessWidget {
  const _PaymentChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onSelected,
    this.iconColor,
  });

  final String label;
  final IconData icon;
  final Color? iconColor;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      avatar: Icon(icon, size: 18.sp, color: iconColor ?? Colors.white),
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      labelStyle: const TextStyle(color: Colors.white),
      backgroundColor: Colors.white.withValues(alpha: 0.05),
      selectedColor: AppColors.primary40,
      side: BorderSide.none,
    );
  }
}

/// Single charge, interest-free installments or installments with a fixed
/// rate, with a live summary of the resulting charges.
class _InstallmentSection extends StatelessWidget {
  const _InstallmentSection({
    required this.state,
    required this.amount,
    required this.rate,
    required this.onModeChanged,
    required this.onCountChanged,
  });

  static const List<int> _counts = [3, 6, 9, 12, 18, 24];

  final MovementFormState state;
  final TextEditingController amount;
  final TextEditingController rate;
  final ValueChanged<InstallmentMode> onModeChanged;
  final ValueChanged<int> onCountChanged;

  @override
  Widget build(BuildContext context) {
    final mode = state.installmentMode;
    final counts = {..._counts, state.installmentCount}.toList()..sort();

    return Padding(
      padding: EdgeInsets.only(top: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const FormLabel('Forma de pago'),
          Row(
            children: [
              for (final (index, option) in const [
                (InstallmentMode.single, 'Una exhibición'),
                (InstallmentMode.interestFree, 'MSI'),
                (InstallmentMode.withInterest, 'Con intereses'),
              ].indexed) ...[
                if (index > 0) SizedBox(width: 8.w),
                Expanded(
                  child: SegmentOption(
                    label: option.$2,
                    color: AppColors.secondary,
                    selected: mode == option.$1,
                    onTap: () => onModeChanged(option.$1),
                  ),
                ),
              ],
            ],
          ),
          if (mode != InstallmentMode.single) ...[
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                for (final count in counts)
                  ChoiceChip(
                    label: Text('$count meses'),
                    selected: state.installmentCount == count,
                    onSelected: (_) => onCountChanged(count),
                    showCheckmark: false,
                    labelStyle: const TextStyle(color: Colors.white),
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    selectedColor: AppColors.primary40,
                    side: BorderSide.none,
                  ),
              ],
            ),
            if (mode == InstallmentMode.withInterest) ...[
              SizedBox(height: 12.h),
              AppTextField(
                controller: rate,
                hint: 'Tasa de interés fija (%)',
                icon: Icons.percent_rounded,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: amountInputFormatters,
              ),
            ],
            SizedBox(height: 10.h),
            ListenableBuilder(
              listenable: Listenable.merge([amount, rate]),
              builder: (context, _) => Text(
                _summary(),
                style: TextStyle(
                  color: AppColors.textPrimary70,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ] else if (state.selectedCard case final card?)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text(
                _periodHint(card.billingPeriodFor(state.date)),
                style: TextStyle(
                  color: AppColors.textPrimary70,
                  fontSize: 12.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// `12 pagos de $1,083.33 · Total $13,000.00` plus first and last payment.
  String _summary() {
    final price = parseAmount(amount.text);
    final card = state.selectedCard!;
    final count = state.installmentCount;
    final schedule = _scheduleHint(card, count);
    if (price == null || price <= 0) return schedule;

    final preview = MovementEntity(
      id: '',
      title: '',
      amount: price,
      type: MovementType.expense,
      categoryId: '',
      date: state.date,
      cardId: card.id,
      installmentCount: count,
      installmentRate: state.installmentMode == InstallmentMode.withInterest
          ? parseAmount(rate.text)
          : null,
      createdAt: state.date,
      updatedAt: state.date,
    );
    final amounts = preview.installmentAmounts;
    return '$count pagos de ${Formatters.currency(amounts.first)} · '
        'Total ${Formatters.currency(preview.totalWithInterest)}\n$schedule';
  }

  String _scheduleHint(CardEntity card, int count) =>
      _paymentSchedule(card, state.date, count);
}

/// Who owes you part of this expense: people, split mode and summary.
class _ShareSection extends StatelessWidget {
  const _ShareSection({
    required this.state,
    required this.amount,
    required this.newPerson,
    required this.shareAmount,
    required this.onToggle,
    required this.onTogglePerson,
    required this.onAddPerson,
    required this.onModeChanged,
    required this.onIncludeMeChanged,
  });

  final MovementFormState state;
  final TextEditingController amount;
  final TextEditingController newPerson;
  final TextEditingController Function(String personId) shareAmount;
  final ValueChanged<bool> onToggle;
  final ValueChanged<String> onTogglePerson;
  final VoidCallback onAddPerson;
  final ValueChanged<SplitMode> onModeChanged;
  final ValueChanged<bool> onIncludeMeChanged;

  @override
  Widget build(BuildContext context) {
    final share = state.share;
    final names = {for (final p in state.people) p.id: p.name};

    return Padding(
      padding: EdgeInsets.only(top: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '¿Te deben de esta compra?',
                  style: TextStyle(
                    color: AppColors.textPrimary70,
                    fontSize: 13.sp,
                  ),
                ),
              ),
              Switch(
                value: share.enabled,
                onChanged: onToggle,
                activeColor: AppColors.secondary,
              ),
            ],
          ),
          if (share.enabled) ...[
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                for (final person in state.people)
                  FilterChip(
                    label: Text(person.name),
                    selected: share.personIds.contains(person.id),
                    onSelected: (_) => onTogglePerson(person.id),
                    showCheckmark: false,
                    avatar: Icon(
                      share.personIds.contains(person.id)
                          ? Icons.check_circle_rounded
                          : Icons.person_rounded,
                      size: 18.sp,
                      color: Colors.white,
                    ),
                    labelStyle: const TextStyle(color: Colors.white),
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    selectedColor: AppColors.primary40,
                    side: BorderSide.none,
                  ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: newPerson,
                    hint: 'Agregar persona',
                    icon: Icons.person_add_alt_1_rounded,
                    textInputAction: TextInputAction.done,
                  ),
                ),
                IconButton(
                  onPressed: onAddPerson,
                  tooltip: 'Agregar',
                  icon: const Icon(Icons.add_circle_rounded),
                  color: AppColors.secondary,
                  iconSize: 32.sp,
                ),
              ],
            ),
            if (share.personIds.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: SegmentOption(
                      label: 'Partes iguales',
                      color: AppColors.secondary,
                      selected: share.mode == SplitMode.equal,
                      onTap: () => onModeChanged(SplitMode.equal),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: SegmentOption(
                      label: 'Montos personalizados',
                      color: AppColors.secondary,
                      selected: share.mode == SplitMode.custom,
                      onTap: () => onModeChanged(SplitMode.custom),
                    ),
                  ),
                ],
              ),
              if (share.mode == SplitMode.equal)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Incluirme en la división',
                        style: TextStyle(
                          color: AppColors.textPrimary85,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                    Switch(
                      value: share.includeMe,
                      onChanged: onIncludeMeChanged,
                      activeColor: AppColors.secondary,
                    ),
                  ],
                )
              else
                for (final id in share.personIds)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            names[id] ?? 'Persona',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(
                          width: 150.w,
                          child: AppTextField(
                            controller: shareAmount(id),
                            hint: 'Monto',
                            icon: Icons.attach_money_rounded,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: amountInputFormatters,
                          ),
                        ),
                      ],
                    ),
                  ),
              SizedBox(height: 8.h),
              ListenableBuilder(
                listenable: Listenable.merge([
                  amount,
                  for (final id in share.personIds) shareAmount(id),
                ]),
                builder: (context, _) {
                  final (text, ok) = _summary();
                  return Text(
                    text,
                    style: TextStyle(
                      color: ok ? AppColors.textPrimary70 : AppColors.warning,
                      fontSize: 12.sp,
                    ),
                  );
                },
              ),
            ],
          ],
        ],
      ),
    );
  }

  /// `Te deben $600.00 · Tu parte $300.00`, or what is missing.
  (String, bool) _summary() {
    final total = parseAmount(amount.text);
    if (total == null || total <= 0) {
      return ('Ingresa el monto para ver cuánto te deben', false);
    }
    final share = state.share;
    final result = share.shares(total, {
      for (final id in share.personIds) id: parseAmount(shareAmount(id).text),
    });
    return result.match((message) => (message, false), (shares) {
      final owed = shares.values.fold<double>(0, (sum, a) => sum + a);
      final mine = DebtSplit.myShare(total, shares.values);
      return (
        'Te deben ${Formatters.currency(owed)} · '
            'Tu parte ${Formatters.currency(mine)}',
        true,
      );
    });
  }
}

/// `Primer pago el 20 Nov · último el 20 Abr 2027` (or the single date).
String _paymentSchedule(CardEntity card, DateTime date, int count) {
  final first = card.billingPeriodFor(date);
  if (count <= 1) {
    return 'Se paga el ${Formatters.shortDate(first.paymentDate)}';
  }
  var last = first;
  for (var i = 1; i < count; i++) {
    last = card.billingPeriodFor(
      DateTime(last.end.year, last.end.month, last.end.day + 1),
    );
  }
  return 'Primer pago el ${Formatters.shortDate(first.paymentDate)} · '
      'último el ${Formatters.shortDate(last.paymentDate)}';
}

/// Payments and interest of a cash withdrawal, with what you receive and
/// what you will pay.
class _WithdrawalSection extends StatelessWidget {
  const _WithdrawalSection({
    required this.state,
    required this.amount,
    required this.rate,
    required this.onCountChanged,
  });

  static const List<int> _counts = [1, 3, 6, 9, 12, 18, 24];

  final MovementFormState state;
  final TextEditingController amount;
  final TextEditingController rate;
  final ValueChanged<int> onCountChanged;

  @override
  Widget build(BuildContext context) {
    final counts = {..._counts, state.installmentCount}.toList()..sort();

    return Padding(
      padding: EdgeInsets.only(top: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const FormLabel('¿En cuántos pagos?'),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              for (final count in counts)
                ChoiceChip(
                  label: Text(count == 1 ? '1 pago' : '$count pagos'),
                  selected: state.installmentCount == count,
                  onSelected: (_) => onCountChanged(count),
                  showCheckmark: false,
                  labelStyle: const TextStyle(color: Colors.white),
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  selectedColor: AppColors.primary40,
                  side: BorderSide.none,
                ),
            ],
          ),
          SizedBox(height: 12.h),
          AppTextField(
            controller: rate,
            hint: 'Interés o comisión fija % (opcional)',
            icon: Icons.percent_rounded,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: amountInputFormatters,
          ),
          SizedBox(height: 10.h),
          ListenableBuilder(
            listenable: Listenable.merge([amount, rate]),
            builder: (context, _) => Text(
              _summary(),
              style: TextStyle(color: AppColors.textPrimary70, fontSize: 12.sp),
            ),
          ),
        ],
      ),
    );
  }

  /// `Recibes $5,000.00 · Pagarás $5,750.00 en 6 pagos de $958.33`
  String _summary() {
    final card = state.selectedCard!;
    final count = state.installmentCount;
    final schedule = _paymentSchedule(card, state.date, count);
    final received = parseAmount(amount.text);
    if (received == null || received <= 0) return schedule;

    final preview = MovementEntity(
      id: '',
      title: '',
      amount: received,
      type: MovementType.expense,
      categoryId: MovementEntity.cashWithdrawalCategoryId,
      date: state.date,
      cardId: card.id,
      installmentCount: count > 1 ? count : null,
      installmentRate: parseAmount(rate.text),
      isCashWithdrawal: true,
      createdAt: state.date,
      updatedAt: state.date,
    );
    final payments = preview.installmentAmounts;
    final plan = count > 1
        ? 'en $count pagos de ${Formatters.currency(payments.first)}'
        : 'en 1 pago';
    return 'Recibes ${Formatters.currency(received)} · '
        'Pagarás ${Formatters.currency(preview.totalWithInterest)} $plan\n'
        '$schedule';
  }
}
