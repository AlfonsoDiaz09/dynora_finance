import 'package:dynora_finance/ui/pages/stats/widgets/category_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryChart extends StatelessWidget {
  const CategoryChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Gastos por categoría",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 20.h),
        CategoryBar(
          category: "Comida",
          percentage: 0.6,
          color: Colors.orangeAccent,
        ),
        SizedBox(height: 14.h),
        CategoryBar(
          category: "Transporte",
          percentage: 0.3,
          color: Colors.blueAccent,
        ),
        SizedBox(height: 14.h),
        CategoryBar(
          category: "Suscripciones",
          percentage: 0.2,
          color: Colors.purpleAccent,
        ),
      ],
    );
  }
}
