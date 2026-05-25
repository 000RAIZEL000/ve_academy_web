import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../widgets/book_cover.dart';
import 'activities_screen.dart';

class BookDetailScreen extends StatefulWidget {
  final Map<String, dynamic> libro;
  final Map<String, dynamic> session;
  final void Function(Map<String, dynamic>)? onSessionUpdated;

  const BookDetailScreen({
    super.key,
    required this.libro,
    required this.session,
    this.onSessionUpdated,
  });

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  Map<String, dynamic>? _detalle;
  bool _loading = true;
  List<String> _paginas = [];
  int _paginaActual = 0;
  bool _completado = false;

  @override
  void initState() {
    super.initState();
    _cargarDetalle();
  }

  Future<void> _cargarDetalle() async {
    try {
      final slug = widget.libro['slug'] as String;
      final token = widget.session['token'] as String?;
      final data = await ApiService().getLibroDetalle(slug, token: token);
      setState(() {
        _detalle = data;
        _paginas = _dividirEnPaginas(data['texto'] as String? ?? '');
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  List<String> _dividirEnPaginas(String texto) {
    if (texto.isEmpty) return ['No hay texto disponible.'];
    final parrafos = texto.split('\n\n').where((p) => p.trim().isNotEmpty).toList();
    if (parrafos.isEmpty) return [texto];
    final paginas = <String>[];
    for (var i = 0; i < parrafos.length; i += 2) {
      final pag = parrafos.sublist(i, (i + 2).clamp(0, parrafos.length)).join('\n\n');
      paginas.add(pag.trim());
    }
    return paginas;
  }

  void _avanzar() {
    if (_paginaActual < _paginas.length - 1) {
      setState(() => _paginaActual++);
    } else {
      setState(() => _completado = true);
    }
  }

  void _retroceder() {
    if (_paginaActual > 0) setState(() => _paginaActual--);
  }

  void _irActividades() {
    if (_detalle == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ActivitiesScreen(
          libroDetalle: _detalle!,
          session: widget.session,
          onSessionUpdated: widget.onSessionUpdated,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.texto),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.libro['titulo'] as String? ?? 'Lectura',
          style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.texto),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text('${_paginaActual + 1}/${_paginas.length}',
                style: GoogleFonts.nunito(
                    fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textoSuave)),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.rosaOscuro))
          : _completado
              ? _buildCompletado()
              : _buildLectura(),
    );
  }

  Widget _buildLectura() {
    final portadaUrl = ApiService.resolveStaticUrl(widget.libro['portada_url'] as String? ?? '');
    final progreso = (_paginaActual + 1) / _paginas.length;

    return Column(
      children: [
        // Barra de progreso
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(children: [
            Row(children: [
              Text('Progreso de lectura',
                  style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textoSuave)),
              const Spacer(),
              Text('${(progreso * 100).round()}%',
                  style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.rosaOscuro)),
            ]),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progreso,
                backgroundColor: AppColors.rosa.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation(AppColors.rosaOscuro),
                minHeight: 8,
              ),
            ),
          ]),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Portada solo en primera página
                if (_paginaActual == 0) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      width: double.infinity,
                      height: 200,
                      child: BookCoverWidget(
                        portadaUrl: portadaUrl,
                        titulo: widget.libro['titulo'] as String? ?? '',
                        index: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Texto del cuento
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [AppColors.sombraSuave],
                  ),
                  child: Text(
                    _paginas[_paginaActual],
                    style: GoogleFonts.nunito(
                      fontSize: 18, height: 1.8, color: AppColors.texto,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),

        // Botones de navegación
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Row(children: [
            if (_paginaActual > 0)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _retroceder,
                  icon: const Icon(Icons.arrow_back_ios_rounded, size: 16),
                  label: Text('Anterior', style: GoogleFonts.baloo2(fontSize: 16, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.lila, width: 2),
                    foregroundColor: AppColors.lilaOscuro,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            if (_paginaActual > 0) const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _avanzar,
                icon: _paginaActual < _paginas.length - 1
                    ? const Icon(Icons.arrow_forward_ios_rounded, size: 16)
                    : const Text('🎉', style: TextStyle(fontSize: 18)),
                label: Text(
                  _paginaActual < _paginas.length - 1 ? 'Siguiente' : '¡Terminé!',
                  style: GoogleFonts.baloo2(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.texto),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _paginaActual < _paginas.length - 1 ? AppColors.celeste : AppColors.rosa,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
              ),
            ),
          ]),
        ),
      ],
    );
  }

  Widget _buildCompletado() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.amarillo, Color(0xFFFFE066)]),
                shape: BoxShape.circle,
                boxShadow: [AppColors.sombraLila],
              ),
              child: const Center(child: Text('🏆', style: TextStyle(fontSize: 60))),
            ),
            const SizedBox(height: 24),
            Text('¡Lectura completada!',
                style: GoogleFonts.baloo2(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.texto),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text('¡Excelente trabajo! Ahora pon a prueba tu comprensión',
                style: GoogleFonts.nunito(fontSize: 16, color: AppColors.textoSuave),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: AppColors.gradienteLogros,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('¡Gana puntos respondiendo correctamente! ⭐',
                  style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF8B6914)),
                  textAlign: TextAlign.center),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: _irActividades,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.rosa,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  elevation: 0,
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('✏️', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Text('¡Responder Preguntas!',
                      style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.texto)),
                ]),
              ),
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Volver a la biblioteca',
                  style: GoogleFonts.nunito(fontSize: 15, color: AppColors.textoSuave)),
            ),
          ],
        ),
      ),
    );
  }
}
