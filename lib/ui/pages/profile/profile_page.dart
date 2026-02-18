import 'package:flutter/material.dart';
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
            ProfileOptionTile(icon: Icons.credit_card, title: "Mis tarjetas"),
            ProfileOptionTile(
              icon: Icons.notifications_outlined,
              title: "Notificaciones",
            ),
            ProfileOptionTile(icon: Icons.language, title: "Idioma"),
            ProfileOptionTile(icon: Icons.lock_outline, title: "Seguridad"),
            ProfileOptionTile(icon: Icons.help_outline, title: "Ayuda"),
            SizedBox(height: 20.h),
            ProfileOptionTile(
              icon: Icons.logout,
              title: "Cerrar sesión",
              isDanger: true,
            ),
            SizedBox(height: 50.h),
          ],
        ),
      ),
    );
  }
}
