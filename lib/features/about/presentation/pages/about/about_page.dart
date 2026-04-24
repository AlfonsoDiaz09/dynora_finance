import 'package:dynora_finance/app/theme/app_colors.dart';
import 'package:dynora_finance/features/about/presentation/pages/about/widgets/body.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Acerca de", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.background,
        shadowColor: AppColors.background,
        elevation: 0,
      ),
      body: Body(),
    );
  }
}
