import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Horizontal strip of chips to pick one period (or month) of a card.
class PeriodFilter<T> extends StatefulWidget {
  const PeriodFilter({
    super.key,
    required this.items,
    required this.selected,
    required this.label,
    required this.onSelected,
  });

  /// Newest first; shown left to right.
  final List<T> items;
  final T? selected;
  final String Function(T item) label;
  final ValueChanged<T> onSelected;

  @override
  State<PeriodFilter<T>> createState() => _PeriodFilterState<T>();
}

class _PeriodFilterState<T> extends State<PeriodFilter<T>> {
  final Map<int, GlobalKey> _keys = {};

  @override
  void initState() {
    super.initState();
    // Bring the default selection into view (it may not be the first chip).
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
          return ChoiceChip(
            key: _keys.putIfAbsent(index, GlobalKey.new),
            label: Text(widget.label(item)),
            selected: item == widget.selected,
            onSelected: (_) => widget.onSelected(item),
            showCheckmark: false,
            labelStyle: const TextStyle(color: Colors.white),
            backgroundColor: Colors.white.withValues(alpha: 0.05),
            selectedColor: AppColors.primary40,
            side: BorderSide.none,
          );
        },
      ),
    );
  }
}
