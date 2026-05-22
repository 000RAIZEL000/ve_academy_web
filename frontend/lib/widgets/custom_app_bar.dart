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
        gradient: AppColors.gradienteNavbar,
        boxShadow: [
          BoxShadow(color: Color(0x33DCC6FF), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Text('📚', style: TextStyle(fontSize: 22))),
              ),
              const SizedBox(width: 12),
              Text(
                'V&E Academy',
                style: GoogleFonts.baloo2(
                  fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.rosaOscuro,
                ),
              ),
              const Spacer(),
              if (estudiante != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(children: [
                    Text(estudiante!['nombre']?.toString().substring(0, 1).toUpperCase() ?? '?',
                        style: GoogleFonts.baloo2(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.rosaOscuro)),
                    const SizedBox(width: 6),
                    Text(estudiante!['nombre'] ?? '',
                        style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.texto)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.amarillo, borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('⭐ ${estudiante!['puntos']}',
                          style: const TextStyle(color: Color(0xFF8B6914), fontWeight: FontWeight.w900, fontSize: 12)),
                    ),
                  ]),
                ),
              if (onLogout != null)
                IconButton(
                  icon: const Icon(Icons.exit_to_app, color: AppColors.rosaOscuro),
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
