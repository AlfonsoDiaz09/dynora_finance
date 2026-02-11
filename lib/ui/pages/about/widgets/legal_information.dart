import 'package:dynora_finance/ui/widgets/info_card.dart';
import 'package:flutter/material.dart';

class LegalInformation extends StatelessWidget {
  const LegalInformation({super.key});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: "Aviso legal",
      child: Text(
        "Dynora no proporciona asesoría financiera. La información mostrada es únicamente de carácter informativo.",
      ),
    );
  }
}
