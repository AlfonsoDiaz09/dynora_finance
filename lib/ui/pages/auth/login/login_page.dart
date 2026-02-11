import 'package:dynora_finance/ui/pages/auth/login/widgets/form_login.dart';
import 'package:dynora_finance/ui/pages/auth/widgets/body.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, .2), end: Offset.zero).animate(_fade);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(18, 18, 18, 1),
              Color.fromRGBO(30, 30, 30, 1),
              Color.fromRGBO(42, 42, 42, 1),
            ],
          ),
        ),
        child: SafeArea(
          child: Body(
            fade: _fade,
            slide: _slide,
            image: "assets/img/business_vision.svg",
            form: FormLogin(),
          ),
        ),
      ),
    );
  }
}
