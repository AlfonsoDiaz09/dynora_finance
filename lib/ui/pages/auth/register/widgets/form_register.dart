import 'package:dynora_finance/ui/bloc/navigation/navigation_bloc.dart';
import 'package:dynora_finance/ui/pages/auth/widgets/button.dart';
import 'package:dynora_finance/ui/pages/auth/widgets/input_field.dart';
import 'package:dynora_finance/ui/router/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FormRegister extends StatelessWidget {
  const FormRegister({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Crear cuenta",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          "Empieza a organizar tus finanzas",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white60),
        ),
        SizedBox(height: 20.h),
        InputField(hint: "Nombre", icon: Icons.person_outline),
        SizedBox(height: 12.h),
        InputField(hint: "Correo electrónico", icon: Icons.email_outlined),
        SizedBox(height: 12.h),
        InputField(
          hint: "Contraseña",
          icon: Icons.lock_outline,
          isPassword: true,
        ),
        SizedBox(height: 24.h),
        Button(text: "Crear cuenta", loading: false),
        SizedBox(height: 16.h),
        TextButton(
          onPressed: () {
            context.read<NavigationBloc>().add(NavigateTo(AppRoutes.login));
          },
          child: Text(
            "Ya tengo cuenta",
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }
}
