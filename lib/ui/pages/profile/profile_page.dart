import 'package:dynora_finance/ui/bloc/navigation/navigation_bloc.dart';
import 'package:dynora_finance/ui/router/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_option_tile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          children: [
            SizedBox(height: 20.h),
            ProfileHeader(),
            SizedBox(height: 30.h),
            ProfileOptionTile(
              icon: Icons.credit_card,
              title: "Mis tarjetas",
              onTap: () {},
            ),
            ProfileOptionTile(
              icon: Icons.notifications_outlined,
              title: "Notificaciones",
              onTap: () {},
            ),
            ProfileOptionTile(
              icon: Icons.language,
              title: "Idioma",
              onTap: () {},
            ),
            ProfileOptionTile(
              icon: Icons.lock_outline,
              title: "Seguridad",
              onTap: () {},
            ),
            ProfileOptionTile(
              icon: Icons.help_outline,
              title: "Ayuda",
              onTap: () {},
            ),
            SizedBox(height: 20.h),
            ProfileOptionTile(
              icon: Icons.logout,
              title: "Cerrar sesión",
              isDanger: true,
              onTap: () {},
            ),
            SizedBox(height: 50.h),
          ],
        ),
      ),
    );
  }
}
