import 'package:dynora_finance/ui/pages/about/widgets/body.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Acerca de", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF121212),
        shadowColor: const Color(0xFF121212),
        elevation: 0,
      ),
      body: Body()
    );
  }
}


