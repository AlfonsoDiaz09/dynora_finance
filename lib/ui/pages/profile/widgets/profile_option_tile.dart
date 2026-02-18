import 'package:flutter/material.dart';

class ProfileOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDanger;

  const ProfileOptionTile({
    super.key,
    required this.icon,
    required this.title,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDanger ? Colors.red : Colors.white,
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isDanger ? Colors.red : Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.white54,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
