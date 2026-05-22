import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/libro.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import '../theme/app_colors.dart';
import '../widgets/bubbles_background.dart';
import '../widgets/book_cover.dart';
import 'book_detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  final int estudianteId;
  final int estudianteEdad;

  const LibraryScreen({
    super.key,
    required this.estudianteId,
    required this.estudianteEdad,
  });

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final ApiService _api = ApiService();
  List<dynamic> _libros = [];
  Map<String, dynamic> _progresoMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final token = await SessionService.getToken();
    final results = await Future.wait([
      _api.getLibros(token: token),
      _api.getProgreso(widget.estudianteId, token: token),
    ]);
    final progreso = results[1] as List<dynamic>;
    final Map<String, dynamic> pMap = {};
    for (final p in progreso) {
      pMap[p['libro_slug'] as String] = p;
    }
    setState(() {
      _libros = results[0] as List<dynamic>;
      _progresoMap = pMap;
      _isLoading = false;
    });
  }

  Future<void> _navigateToBook(dynamic libroData) async {
    final token = await SessionService.getToken();
    try {
      final libroJson = await _api.getLibroDetalle(
          libroData['slug'] as String, token: token);
      final libro = Libro.fromJson(libroJson);
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookDetailScreen(
            libro: libro,
            estudianteId: widget.estudianteId,
            estudianteEdad: widget.estudianteEdad,
          ),
        ),
      );
      _load();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo cargar el libro.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BubblesBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: AppColors.headerGradientEnd,
          foregroundColor: Colors.white,
          title: Text(
            '📚 Biblioteca',
            style: GoogleFonts.baloo2(fontWeight: FontWeight.w700),
          ),
          elevation: 0,
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.morado))
            : RefreshIndicator(
                onRefresh: _load,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Text(
                        '¿Qué cuento quieres leer hoy? 🌟',
                        style: GoogleFonts.baloo2(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.texto,
                        ),
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _libros.length,
                        itemBuilder: (ctx, i) {
                          final libro = _libros[i];
                          final slug = libro['slug'] as String;
                          final p = _progresoMap[slug];
                          return _LibraryCard(
                            libro: libro,
                            progreso: p,
                            index: i,
                            onTap: () => _navigateToBook(libro),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _LibraryCard extends StatelessWidget {
  final dynamic libro;
  final dynamic progreso;
  final int index;
  final VoidCallback onTap;

  const _LibraryCard({
    required this.libro,
    required this.progreso,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final titulo = libro['titulo'] as String? ?? '';
    final portadaUrl = libro['portada_url'] as String? ?? '';
    final pct = progreso != null ? (progreso['porcentaje'] as int? ?? 0) : 0;
    final completado =
        progreso != null ? (progreso['completado'] as bool? ?? false) : false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
          ],
          border: completado
              ? Border.all(color: AppColors.verde, width: 2.5)
              : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  BookCoverWidget(
                      portadaUrl: portadaUrl, titulo: titulo, index: index),
                  if (completado)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.verde,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check,
                            color: Colors.white, size: 14),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: GoogleFonts.baloo2(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.texto,
                        height: 1.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: LinearProgressIndicator(
                        value: pct / 100,
                        backgroundColor: const Color(0xFFE0E0E0),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          completado ? AppColors.verde : AppColors.azul,
                        ),
                        minHeight: 7,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pct == 0 ? 'Sin comenzar' : '$pct%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: completado ? AppColors.verde : AppColors.gris,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
