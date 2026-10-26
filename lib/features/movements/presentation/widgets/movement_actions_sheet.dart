import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/features/movements/domain/entities/movement_entity.dart';
import 'package:dynora_finance/features/movements/presentation/widgets/movement_form_sheet.dart';
import 'package:dynora_finance/shared/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Quick options of a movement (long press): edit or duplicate it.
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
              caption:
                  'Usa estos datos para un nuevo movimiento',
              onTap: () => open(duplicate: true),
            ),
          ],
        ),
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    required this.onTap,
    this.caption,
  });

  final IconData icon;
  final String label;
  final String? caption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
      leading: Icon(icon, color: AppColors.secondary),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      subtitle: caption == null
          ? null
          : Text(
              caption!,
              style: TextStyle(color: AppColors.textPrimary70, fontSize: 12.sp),
            ),
    );
  }
}
