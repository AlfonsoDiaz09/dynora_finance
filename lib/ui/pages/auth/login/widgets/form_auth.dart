import 'package:dynora_finance/ui/pages/auth/login/widgets/button.dart';
import 'package:dynora_finance/ui/pages/auth/login/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FormAuth extends StatelessWidget {
  const FormAuth({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Bienvenido a Dynora",
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20.h),
        InputField(hint: "Correo electrónico", icon: Icons.email_outlined),
        SizedBox(height: 14.h),
        InputField(
          hint: "Contraseña",
          icon: Icons.lock_outline,
          isPassword: true,
        ),
        SizedBox(height: 24.h),
        Button(loading: false),
        SizedBox(height: 16.h),
        TextButton(
          onPressed: () {},
          child: Text("Crear cuenta", style: TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }
}
