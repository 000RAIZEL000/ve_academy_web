import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Map<String, dynamic>? estudiante;
  final VoidCallback? onLogout;

  const CustomAppBar({super.key, this.estudiante, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.headerGradientStart,
            AppColors.headerGradientMid,
            AppColors.headerGradientEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          bottom: BorderSide(color: AppColors.verde, width: 4.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              // Placeholder for Logo
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.school, color: AppColors.azul),
              ),
              const SizedBox(width: 12),
              // Brand Name
              Text(
                'V&E Academy',
                style: GoogleFonts.baloo2(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              // User Chip
              if (estudiante != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: Colors.white.withOpacity(0.25), width: 2),
                  ),
                  child: Row(
                    children: [
                      // Avatar placeholder
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.naranja,
                        child: Text(
                          estudiante!['nombre']?.substring(0, 1).toUpperCase() ?? '?',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        estudiante!['nombre'] ?? '',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.amarillo,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '⭐ ${estudiante!['puntos']}',
                          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w900, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              if (onLogout != null)
                IconButton(
                  icon: const Icon(Icons.exit_to_app, color: Colors.white70),
                  onPressed: onLogout,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 16);
}
