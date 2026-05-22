import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/libro.dart';
import '../theme/app_colors.dart';
import '../widgets/book_cover.dart';
import 'quiz_screen.dart';
import 'games_menu_screen.dart';

class BookDetailScreen extends StatelessWidget {
  final Libro libro;
  final int estudianteId;
  final int estudianteEdad;

  const BookDetailScreen({
    super.key,
    required this.libro,
    required this.estudianteId,
    required this.estudianteEdad,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.headerGradientEnd,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                libro.titulo,
                style: GoogleFonts.baloo2(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  shadows: const [Shadow(blurRadius: 6, color: Colors.black54)],
                ),
              ),
              background: BookCoverWidget(
                portadaUrl: libro.portadaUrl,
                titulo: libro.titulo,
                index: libro.id % 8,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta chips
                  Row(
                    children: [
                      _MetaChip(
                        '🎂 Para $estudianteEdad años',
                        AppColors.azul,
                      ),
                      const SizedBox(width: 8),
                      _MetaChip(
                        '📝 ${libro.preguntas.where((q) => q.edad == estudianteEdad).length} preguntas',
                        AppColors.morado,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Story text
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 3)),
                      ],
                    ),
                    child: Text(
                      libro.texto,
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        height: 1.8,
                        color: AppColors.texto,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Quiz section
                  _QuizCallToAction(
                    libro: libro,
                    estudianteId: estudianteId,
                    estudianteEdad: estudianteEdad,
                  ),
                  const SizedBox(height: 16),
                  // Games section
                  _GamesCallToAction(
                    libro: libro,
                    estudianteId: estudianteId,
                    estudianteEdad: estudianteEdad,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String text;
  final Color color;

  const _MetaChip(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(100), width: 1.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _QuizCallToAction extends StatelessWidget {
  final Libro libro;
  final int estudianteId;
  final int estudianteEdad;

  const _QuizCallToAction({
    required this.libro,
    required this.estudianteId,
    required this.estudianteEdad,
  });

  @override
  Widget build(BuildContext context) {
    final count = libro.preguntas.where((q) => q.edad == estudianteEdad).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFf7971e), Color(0xFFffd200)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFf7971e).withAlpha(80),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('🧩', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          Text(
            '¡Es hora del Quiz!',
            style: GoogleFonts.baloo2(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count > 0
                ? '$count preguntas te esperan · ¡Gana puntos!'
                : 'Aún no hay preguntas para tu edad.',
            style: const TextStyle(color: Colors.white, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (count > 0)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuizScreen(
                      libro: libro,
                      estudianteId: estudianteId,
                      estudianteEdad: estudianteEdad,
                    ),
                  ),
                ),
                icon: const Icon(Icons.play_arrow_rounded, size: 28),
                label: Text(
                  'Comenzar',
                  style: GoogleFonts.baloo2(
                      fontSize: 20, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFf7971e),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ──────────────── Games Call-to-Action ────────────────

class _GamesCallToAction extends StatelessWidget {
  final Libro libro;
  final int estudianteId;
  final int estudianteEdad;

  const _GamesCallToAction({
    required this.libro,
    required this.estudianteId,
    required this.estudianteEdad,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C3DE0), Color(0xFFE040A0)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C3DE0).withAlpha(80),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('🎮', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 8),
          Text(
            '¡Mini Juegos!',
            style: GoogleFonts.baloo2(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '5 juegos divertidos basados en este cuento',
            style: TextStyle(color: Colors.white70, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GamesMenuScreen(
                    libro: libro,
                    estudianteId: estudianteId,
                    estudianteEdad: estudianteEdad,
                  ),
                ),
              ),
              icon: const Icon(Icons.videogame_asset_rounded, size: 22),
              label: Text(
                '¡A Jugar!',
                style: GoogleFonts.baloo2(
                    fontSize: 18, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF6C3DE0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
