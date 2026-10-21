import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Whether a period already ended, is running now or hasn't started.
enum PeriodTense { past, current, future }

/// Horizontal strip of chips to pick one period (or month) of a card, from
/// oldest to newest, marking past, current and future ones.
class PeriodFilter<T> extends StatefulWidget {
  const PeriodFilter({
    super.key,
    required this.items,
    required this.selected,
    required this.label,
    required this.tense,
    required this.onSelected,
  });

  /// Oldest first; shown left to right.
  final List<T> items;
  final T? selected;
  final String Function(T item) label;
  final PeriodTense Function(T item) tense;
  final ValueChanged<T> onSelected;

  @override
  State<PeriodFilter<T>> createState() => _PeriodFilterState<T>();
}

class _PeriodFilterState<T> extends State<PeriodFilter<T>> {
  final Map<int, GlobalKey> _keys = {};

  @override
  void initState() {
    super.initState();
    // Bring the default selection into view (usually not the first chip).
    WidgetsBinding.instance.addPostFrameCallback((_) => _revealSelected());
  }

  void _revealSelected() {
    final index = widget.items.indexOf(widget.selected as T);
    final context = _keys[index]?.currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      alignment: 0.5,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: widget.items.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final item = widget.items[index];
          final tense = widget.tense(item);
          final selected = item == widget.selected;
          final (icon, iconColor) = switch (tense) {
            PeriodTense.past => (
              Icons.history_rounded,
              AppColors.textPrimary38,
            ),
            PeriodTense.current => (Icons.circle, AppColors.success),
            PeriodTense.future => (Icons.schedule_rounded, AppColors.info),
          };

          return ChoiceChip(
            key: _keys.putIfAbsent(index, GlobalKey.new),
            avatar: Icon(
              icon,
              color: selected ? Colors.white : iconColor,
              size: tense == PeriodTense.current ? 10.sp : 16.sp,
            ),
            label: Text(widget.label(item)),
            tooltip: switch (tense) {
              PeriodTense.past => 'Periodo pasado',
              PeriodTense.current => 'Periodo actual',
              PeriodTense.future => 'Periodo futuro',
            },
            selected: selected,
            onSelected: (_) => widget.onSelected(item),
            showCheckmark: false,
            labelStyle: TextStyle(
              color: selected || tense != PeriodTense.past
                  ? Colors.white
                  : AppColors.textPrimary70,
              fontWeight: tense == PeriodTense.current
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
            backgroundColor: Colors.white.withValues(alpha: 0.05),
            selectedColor: AppColors.primary40,
            side: tense == PeriodTense.current
                ? const BorderSide(color: AppColors.success, width: 1.5)
                : BorderSide.none,
          );
        },
      ),
    );
  }
}
