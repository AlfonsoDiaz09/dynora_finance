import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/features/movements/presentation/cubit/movements_cubit.dart';
import 'package:dynora_finance/shared/widgets/form/segment_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Type selector (Todos / Gastos / Ingresos) and an expandable search field.
class MovementFilters extends StatefulWidget {
  const MovementFilters({
    super.key,
    required this.typeFilter,
    required this.query,
    required this.onTypeChanged,
    required this.onSearch,
  });

  final MovementTypeFilter typeFilter;
  final String query;
  final ValueChanged<MovementTypeFilter> onTypeChanged;
  final ValueChanged<String> onSearch;

  @override
  State<MovementFilters> createState() => _MovementFiltersState();
}

class _MovementFiltersState extends State<MovementFilters> {
  late final TextEditingController _search = TextEditingController(
    text: widget.query,
  );
  late bool _searching = widget.query.isNotEmpty;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _closeSearch() {
    _search.clear();
    widget.onSearch('');
    setState(() => _searching = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_searching) {
      return TextField(
        controller: _search,
        autofocus: true,
        onChanged: widget.onSearch,
        textInputAction: TextInputAction.search,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Buscar por concepto, categoría o tarjeta',
          hintStyle: TextStyle(color: AppColors.textPrimary38, fontSize: 13.sp),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.textPrimary70,
          ),
          suffixIcon: IconButton(
            tooltip: 'Cerrar búsqueda',
            onPressed: _closeSearch,
            icon: Icon(Icons.close_rounded, color: AppColors.textPrimary70),
          ),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide.none,
          ),
        ),
      );
    }

    return Row(
      children: [
        for (final (filter, label) in const [
          (MovementTypeFilter.all, 'Todos'),
          (MovementTypeFilter.expenses, 'Gastos'),
          (MovementTypeFilter.incomes, 'Ingresos'),
        ]) ...[
          Expanded(
            child: SegmentOption(
              label: label,
              color: AppColors.secondary,
              selected: widget.typeFilter == filter,
              onTap: () => widget.onTypeChanged(filter),
            ),
          ),
          SizedBox(width: 8.w),
        ],
        IconButton(
          tooltip: 'Buscar',
          onPressed: () => setState(() => _searching = true),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.05),
          ),
          icon: const Icon(Icons.search_rounded, color: Colors.white),
        ),
      ],
    );
  }
}
