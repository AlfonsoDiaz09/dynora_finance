import 'package:flutter/material.dart';
import 'widgets/budget_summary_card.dart';
import 'widgets/category_budget_card.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: const [
            SizedBox(height: 20),

            /// Título
            Text(
              "Presupuesto",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 20),

            /// Resumen general
            BudgetSummaryCard(),

            SizedBox(height: 30),

            /// Categorías
            Text(
              "Por categoría",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),

            SizedBox(height: 15),

            CategoryBudgetCard(
              category: "Comida",
              spent: 320,
              total: 500,
            ),

            SizedBox(height: 15),

            CategoryBudgetCard(
              category: "Transporte",
              spent: 150,
              total: 300,
            ),

            SizedBox(height: 15),

            CategoryBudgetCard(
              category: "Entretenimiento",
              spent: 220,
              total: 250,
            ),

            SizedBox(height: 80),
          ],
        ),
      ),

      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 120),
        child: FloatingActionButton(
          backgroundColor: Colors.purpleAccent,
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
