import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import '../theme/app_colors.dart';
import '../widgets/book_cover.dart';

class ProgressScreen extends StatefulWidget {
  final int estudianteId;
  final int estudianteEdad;

  const ProgressScreen({
    super.key,
    required this.estudianteId,
    required this.estudianteEdad,
  });

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _progreso = [];
  List<dynamic> _libros = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final token = await SessionService.getToken();
    final results = await Future.wait([
      _api.getProgreso(widget.estudianteId, token: token),
      _api.getLibros(token: token),
    ]);
    setState(() {
      _progreso = results[0];
      _libros = results[1];
      _isLoading = false;
    });
  }

  Map<String, dynamic>? _getLibro(String slug) {
    try {
      return _libros.firstWhere((l) => l['slug'] == slug) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  int get _completados => _progreso.where((p) => p['completado'] == true).length;
  int get _enProceso => _progreso.where((p) {
    final pct = p['porcentaje'] as int? ?? 0;
    final done = p['completado'] as bool? ?? false;
    return pct > 0 && !done;
  }).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppColors.headerGradientEnd,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 48),
                      Text('📊', style: TextStyle(fontSize: 52)),
                      Text(
                        'Mi Progreso',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (!_isLoading)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    _SummaryChip('✅', '$_completados', 'Completados', AppColors.verde),
                    const SizedBox(width: 12),
                    _SummaryChip(
                        '📖', '$_enProceso', 'En proceso', AppColors.azul),
                    const SizedBox(width: 12),
                    _SummaryChip(
                        '🔒',
                        '${_progreso.length - _completados - _enProceso}',
                        'Sin comenzar',
                        AppColors.gris),
                  ],
                ),
              ),
            ),
          _isLoading
              ? const SliverFillRemaining(
                  child: Center(
                      child: CircularProgressIndicator(color: AppColors.verde)),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final p = _progreso[i];
                      final slug = p['libro_slug'] as String;
                      final libro = _getLibro(slug);
                      return _ProgressCard(
                        progreso: p,
                        titulo: libro?['titulo'] as String? ?? slug,
                        portadaUrl: libro?['portada_url'] as String? ?? '',
                        colorIndex: i,
                      );
                    },
                    childCount: _progreso.length,
                  ),
                ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String emoji;
  final String count;
  final String label;
  final Color color;

  const _SummaryChip(this.emoji, this.count, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(80)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            Text(
              count,
              style: GoogleFonts.baloo2(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final dynamic progreso;
  final String titulo;
  final String portadaUrl;
  final int colorIndex;

  const _ProgressCard({
    required this.progreso,
    required this.titulo,
    required this.portadaUrl,
    required this.colorIndex,
  });

  @override
  Widget build(BuildContext context) {
    final pct = progreso['porcentaje'] as int? ?? 0;
    final completado = progreso['completado'] as bool? ?? false;
    final intentos = progreso['intentos'] as int? ?? 0;
    final mejor = progreso['mejor_puntaje'] as int? ?? 0;
    final total = progreso['total_preguntas'] as int? ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
        border: completado ? Border.all(color: AppColors.verde, width: 2) : null,
      ),
      child: Row(
        children: [
          // Cover thumbnail
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              bottomLeft: Radius.circular(18),
            ),
            child: SizedBox(
              width: 90,
              height: 100,
              child: BookCoverWidget(
                portadaUrl: portadaUrl,
                titulo: titulo,
                index: colorIndex,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          titulo,
                          style: GoogleFonts.baloo2(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.texto,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (completado)
                        const Padding(
                          padding: EdgeInsets.only(left: 4),
                          child: Text('✅', style: TextStyle(fontSize: 18)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: pct / 100,
                      minHeight: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        completado ? AppColors.verde : AppColors.azul,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$pct%',
                        style: TextStyle(
                          fontSize: 12,
                          color: completado ? AppColors.verde : AppColors.azul,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (intentos > 0)
                        Text(
                          '$mejor/$total · $intentos ${intentos == 1 ? 'intento' : 'intentos'}',
                          style: const TextStyle(fontSize: 11, color: AppColors.gris),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
