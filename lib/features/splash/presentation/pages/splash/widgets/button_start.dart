import 'package:dynora_finance/features/splash/presentation/pages/splash/widgets/fade_slide.dart';
import 'package:dynora_finance/features/splash/presentation/pages/splash/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class ButtonStart extends StatelessWidget {
  const ButtonStart({super.key});

  @override
  Widget build(BuildContext context) {
    return FadeSlide(
      delay: 300,
      child: PrimaryButton(
        text: "Comenzar",
        onTap: () {
          // TODO: Navigate to login
        },
      ),
    );
  }
}
