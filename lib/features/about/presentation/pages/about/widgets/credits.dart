import 'package:dynora_finance/ui/widgets/info_card.dart';
import 'package:flutter/material.dart';

class Credits extends StatelessWidget {
  const Credits({super.key});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: "Créditos",
      child: Text("Ilustraciones diseñadas por Freepik"),
    );
  }
}
