import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        /// Avatar
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xff7F00FF), Color(0xffE100FF)],
            ),
          ),
          child: const Center(
            child: Text(
              "A",
              style: TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        const SizedBox(width: 20),

        /// Nombre y correo
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Alfonso",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "alfonso@email.com",
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
