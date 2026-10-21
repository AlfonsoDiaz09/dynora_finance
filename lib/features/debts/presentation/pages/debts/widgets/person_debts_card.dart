import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/features/debts/presentation/cubit/debts_cubit.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// One person: what they owe and each purchase behind it.
class PersonDebtsCard extends StatelessWidget {
  const PersonDebtsCard({
    super.key,
    required this.person,
    required this.onMarkPaid,
    required this.onMarkPending,
    required this.onRename,
    required this.onOpenMovement,
  });

  final PersonDebts person;
  final ValueChanged<List<String>> onMarkPaid;
  final ValueChanged<List<String>> onMarkPending;
  final VoidCallback onRename;
  final ValueChanged<MovementEntity> onOpenMovement;

  @override
  Widget build(BuildContext context) {
    final pending = person.pending;
    final name = person.person.name;

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 8.w, 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary40,
                child: Text(
                  name.characters.first.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      pending > 0
                          ? 'Te debe ${Formatters.currency(pending)}'
                          : 'Al corriente',
                      style: TextStyle(
                        color: pending > 0
                            ? AppColors.warning
                            : AppColors.success,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onRename,
                tooltip: 'Editar nombre',
                icon: Icon(
                  Icons.edit_rounded,
                  color: AppColors.textPrimary70,
                  size: 20.sp,
                ),
              ),
              if (person.pendingIds.length > 1)
                TextButton(
                  onPressed: () => onMarkPaid(person.pendingIds),
                  child: const Text('Saldar todo'),
                ),
            ],
          ),
          SizedBox(height: 4.h),
          for (final item in person.items)
            _DebtRow(
              item: item,
              onMarkPaid: () => onMarkPaid([item.debt.id]),
              onMarkPending: () => onMarkPending([item.debt.id]),
              onOpen: item.movement == null
                  ? null
                  : () => onOpenMovement(item.movement!),
            ),
        ],
      ),
    );
  }
}

class _DebtRow extends StatelessWidget {
  const _DebtRow({
    required this.item,
    required this.onMarkPaid,
    required this.onMarkPending,
    this.onOpen,
  });

  final DebtItem item;
  final VoidCallback onMarkPaid;
  final VoidCallback onMarkPending;

  /// Opens the movement to edit it; `null` if it no longer exists.
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final debt = item.debt;
    final movement = item.movement;
    final paidAt = debt.paidAt;

    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.only(top: 8.h, bottom: 2.h),
        child: Row(
          children: [
            Icon(
              paidAt != null
                  ? Icons.check_circle_rounded
                  : Icons.schedule_rounded,
              color: paidAt != null ? AppColors.success : AppColors.warning,
              size: 20.sp,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movement?.title ?? 'Movimiento eliminado',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Text(
                    [
                      Formatters.currency(debt.amount),
                      if (movement != null)
                        'de ${Formatters.currency(movement.amount)}',
                      if (movement != null) Formatters.shortDate(movement.date),
                      if (paidAt != null)
                        'pagado el ${Formatters.shortDate(paidAt)}',
                    ].join(' · '),
                    style: TextStyle(
                      color: AppColors.textPrimary70,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            if (paidAt == null)
              TextButton(onPressed: onMarkPaid, child: const Text('Cobrado'))
            else
              IconButton(
                onPressed: onMarkPending,
                tooltip: 'Marcar como pendiente',
                icon: Icon(Icons.undo_rounded, color: AppColors.textPrimary70),
              ),
          ],
        ),
      ),
    );
  }
}
