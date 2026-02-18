import 'package:flutter/material.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_option_tile.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: const [
            SizedBox(height: 20),

            /// Header
            ProfileHeader(),

            SizedBox(height: 30),

            /// Opciones
            ProfileOptionTile(
              icon: Icons.credit_card,
              title: "Mis tarjetas",
            ),

            ProfileOptionTile(
              icon: Icons.notifications_outlined,
              title: "Notificaciones",
            ),

            ProfileOptionTile(
              icon: Icons.language,
              title: "Idioma",
            ),

            ProfileOptionTile(
              icon: Icons.lock_outline,
              title: "Seguridad",
            ),

            ProfileOptionTile(
              icon: Icons.help_outline,
              title: "Ayuda",
            ),

            SizedBox(height: 20),

            ProfileOptionTile(
              icon: Icons.logout,
              title: "Cerrar sesión",
              isDanger: true,
            ),

            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
