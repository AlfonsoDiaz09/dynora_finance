import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/features/debts/domain/usecases/set_movement_debts.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';
import 'package:dynora_finance/features/movements/domain/usecases/delete_movement.dart';
import 'package:dynora_finance/features/movements/presentation/widgets/movement_form_sheet.dart';
import 'package:dynora_finance/init_dependencies.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Quick options of a movement (long press): edit, duplicate or delete it.
class MovementActionsSheet extends StatelessWidget {
  const MovementActionsSheet({super.key, required this.movement});

  final MovementEntity movement;

  static Future<void> show(BuildContext context, MovementEntity movement) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => MovementActionsSheet(movement: movement),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Opened from the page below, once this sheet is closed.
    final page = Navigator.of(context);

    void open({required bool duplicate}) {
      final pageContext = page.context;
      page.pop();
      duplicate
          ? MovementFormSheet.show(pageContext, template: movement)
          : MovementFormSheet.show(pageContext, movement: movement);
    }

    Future<void> delete() async {
      final pageContext = page.context;
      page.pop();
      if (await _confirmDelete(pageContext) && pageContext.mounted) {
        await _delete(pageContext);
      }
    }

    return SafeArea(
      child: Container(
        margin: EdgeInsets.all(12.r),
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movement.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${Formatters.currency(movement.amount)} · '
                    '${Formatters.shortDate(movement.date)}',
                    style: TextStyle(
                      color: AppColors.textPrimary70,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            _Action(
              icon: Icons.edit_rounded,
              label: 'Editar',
              onTap: () => open(duplicate: false),
            ),
            _Action(
              icon: Icons.copy_rounded,
              label: 'Duplicar',
              caption: 'Usa estos datos para un nuevo movimiento',
              onTap: () => open(duplicate: true),
            ),
            _Action(
              icon: Icons.delete_outline_rounded,
              label: 'Eliminar',
              color: AppColors.error,
              onTap: delete,
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          '¿Eliminar movimiento?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '"${movement.title}" se eliminará junto con sus deudas asociadas.',
          style: TextStyle(color: AppColors.textPrimary70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  /// Same as deleting from the form: the movement and the debts it created.
  Future<void> _delete(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final deleted = await serviceLocator<DeleteMovement>()(movement.id);
    final result = deleted.isRight()
        ? await serviceLocator<SetMovementDebts>()(
            SetMovementDebtsParams.clear(movement.id),
          )
        : deleted;
    result.match(
      (failure) =>
          messenger.showSnackBar(SnackBar(content: Text(failure.message))),
      (_) {},
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    required this.onTap,
    this.caption,
    this.color,
  });

  final IconData icon;
  final String label;
  final String? caption;
  final Color? color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
      leading: Icon(icon, color: color ?? AppColors.secondary),
      title: Text(label, style: TextStyle(color: color ?? Colors.white)),
      subtitle: caption == null
          ? null
          : Text(
              caption!,
              style: TextStyle(color: AppColors.textPrimary70, fontSize: 12.sp),
            ),
    );
  }
}
