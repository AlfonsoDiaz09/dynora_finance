import 'package:flutter/material.dart';
import 'widgets/transactions_summary_card.dart';
import 'widgets/transaction_filter_bar.dart';
import 'widgets/transaction_group.dart';

class MovementsPage extends StatelessWidget {
  const MovementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0F0F1A),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 20, right: 20, top: 20),
              child: Text(
                "Movimientos",
                style: TextStyle(color: Colors.white, fontSize: 21),
              ),
            ),
        
            /// Resumen mensual
            Padding(padding: EdgeInsets.all(20), child: TransactionsSummaryCard()),
        
            /// Filtros
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: TransactionFilterBar(),
            ),
        
            SizedBox(height: 20),
        
            /// Lista
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                children: [
                  TransactionGroup(date: "Hoy"),
                  SizedBox(height: 20),
                  TransactionGroup(date: "Ayer"),
                  SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
