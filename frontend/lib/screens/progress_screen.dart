import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../services/progress_service.dart';

class ProgressScreen extends StatefulWidget {
  final Map<String, dynamic> session;
  const ProgressScreen({super.key, required this.session});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  List<dynamic> _progreso = [];
  List<dynamic> _logros = [];
  List<dynamic> _historial = [];
  bool _loading = true;
  int _lecturasLocal = 0;
  int _juegosLocal = 0;
  List<Map<String, dynamic>> _historialLocal = [];

  int get _puntos => (widget.session['puntos'] as num?)?.toInt() ?? 0;
  int get _racha => (widget.session['racha_actual'] as num?)?.toInt() ?? 0;
  int get _nivel => (_puntos / 300).floor() + 1;
  int get _puntosParaSiguiente => (_nivel * 300) - _puntos;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  void didUpdateWidget(covariant ProgressScreen old) {
    super.didUpdateWidget(old);
    if (old.session['puntos'] != widget.session['puntos']) _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    // Load local progress first (immediate, offline-safe)
    _lecturasLocal = await ProgressService.getLibrosLeidosCount();
    _juegosLocal = await ProgressService.getJuegosCompletados();
    _historialLocal = await ProgressService.getHistorial();
    // Always rebuild so local stats are reflected immediately (not just on first load)
    if (mounted) setState(() => _loading = false);

    // Then try to enrich from server
    final id = (widget.session['id'] as num).toInt();
    final token = widget.session['token'] as String?;
    try {
      final results = await Future.wait([
        ApiService().getProgreso(id, token: token),
        ApiService().getLogros(token: token),
        ApiService().getHistorial(id, token: token),
      ]);
      if (mounted) {
        setState(() {
          _progreso = results[0];
          _logros = results[1];
          _historial = results[2];
        });
      }
    } catch (_) {}
  }

  int get _lecturasCompletadas => _progreso.isNotEmpty
      ? _progreso.where((p) => p['completado'] == true).length
      : _lecturasLocal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.rosaOscuro))
            : RefreshIndicator(
                onRefresh: _cargarDatos,
                color: AppColors.rosaOscuro,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 20),
                      _buildNivelCard(),
                      const SizedBox(height: 20),
                      _buildEstadisticas(),
                      const SizedBox(height: 24),
                      _buildLibrosProgreso(),
                      const SizedBox(height: 24),
                      _buildLogros(),
                      const SizedBox(height: 24),
                      _buildHistorial(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Mi Progreso', style: GoogleFonts.baloo2(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.texto)),
        Text('¡Mira cuánto has avanzado!', style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textoSuave)),
      ]),
      const Spacer(),
      const Text('📊', style: TextStyle(fontSize: 32)),
    ]);
  }

  Widget _buildNivelCard() {
    final puntosEnNivelBase = (_nivel - 1) * 300;
    final puntosEnNivelActual = _puntos - puntosEnNivelBase;
    final pctNivel = (puntosEnNivelActual / 300.0).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.rosa, AppColors.lila]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [AppColors.sombraRosa],
      ),
      child: Column(children: [
        Row(children: [
          Container(
            width: 60, height: 60,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Center(
              child: Text('$_nivel', style: GoogleFonts.baloo2(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.rosaOscuro)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Nivel $_nivel', style: GoogleFonts.baloo2(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.texto)),
            Text('$_puntosParaSiguiente pts para el siguiente nivel',
                style: GoogleFonts.nunito(fontSize: 13, color: AppColors.texto.withOpacity(0.7))),
          ])),
          const Text('🏅', style: TextStyle(fontSize: 36)),
        ]),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: pctNivel,
            backgroundColor: Colors.white.withOpacity(0.4),
            valueColor: const AlwaysStoppedAnimation(Colors.white),
            minHeight: 10,
          ),
        ),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('$puntosEnNivelActual pts', style: GoogleFonts.nunito(fontSize: 12, color: AppColors.texto.withOpacity(0.8))),
          Text('300 pts', style: GoogleFonts.nunito(fontSize: 12, color: AppColors.texto.withOpacity(0.8))),
        ]),
      ]),
    );
  }

  Widget _buildEstadisticas() {
    return Column(children: [
      Row(children: [
        Expanded(child: _statCard('📚', '$_lecturasCompletadas', 'Lecturas\ncompletadas', AppColors.celeste.withOpacity(0.3))),
        const SizedBox(width: 12),
        Expanded(child: _statCard('🎮', '$_juegosLocal', 'Juegos\ncompletados', AppColors.lila.withOpacity(0.3))),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _statCard('⭐', '$_puntos', 'Puntos\nacumulados', AppColors.amarillo.withOpacity(0.3))),
        const SizedBox(width: 12),
        Expanded(child: _statCard('🔥', '$_racha', 'Días\nseguidos', AppColors.rosa.withOpacity(0.3))),
      ]),
    ]);
  }

  Widget _statCard(String emoji, String valor, String etiqueta, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(18)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(emoji, style: const TextStyle(fontSize: 26)),
        const SizedBox(height: 6),
        Text(valor, style: GoogleFonts.baloo2(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.texto)),
        Text(etiqueta, style: GoogleFonts.nunito(fontSize: 11, color: AppColors.textoSuave), textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _buildLibrosProgreso() {
    if (_progreso.isNotEmpty) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Lecturas', style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.texto)),
        const SizedBox(height: 12),
        ..._progreso.take(5).map((p) => _LibroProgresoItem(progreso: p)),
        if (_progreso.length > 5)
          Center(child: Text('+${_progreso.length - 5} más',
              style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textoSuave))),
      ]);
    }
    // Fallback: build list from local history when server is unavailable
    final librosLeidos = <Map<String, dynamic>>[];
    final seenSlugs = <String>{};
    for (final h in _historialLocal) {
      if (h['tipo'] != 'libro') continue;
      final slug = h['libro_slug'] as String? ?? '';
      if (slug.isNotEmpty && seenSlugs.add(slug)) {
        librosLeidos.add({
          'libro_titulo': h['libro_titulo'] as String? ?? slug,
          'porcentaje': 100,
          'completado': true,
          'intentos': 1,
        });
      }
    }
    if (librosLeidos.isEmpty) return const SizedBox();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Lecturas', style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.texto)),
      const SizedBox(height: 12),
      ...librosLeidos.take(5).map((p) => _LibroProgresoItem(progreso: p)),
    ]);
  }

  Widget _buildLogros() {
    if (_logros.isEmpty) return const SizedBox();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Logros', style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.texto)),
      const SizedBox(height: 12),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, childAspectRatio: 0.9, crossAxisSpacing: 10, mainAxisSpacing: 10,
        ),
        itemCount: _logros.length.clamp(0, 6),
        itemBuilder: (_, i) {
          final logro = _logros[i] as Map<String, dynamic>;
          final desbloqueado = _puntos >= ((logro['puntos_requeridos'] as num?)?.toInt() ?? 0);
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: desbloqueado ? AppColors.amarillo.withOpacity(0.3) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              border: desbloqueado ? Border.all(color: AppColors.amarilloOscuro, width: 1.5) : null,
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(logro['icono'] as String? ?? '🏆',
                  style: TextStyle(fontSize: 30, color: desbloqueado ? null : Colors.grey)),
              const SizedBox(height: 6),
              Text(logro['nombre'] as String? ?? '',
                  style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700,
                      color: desbloqueado ? AppColors.amarilloOscuro : Colors.grey),
                  textAlign: TextAlign.center, maxLines: 2),
            ]),
          );
        },
      ),
    ]);
  }

  Widget _buildHistorial() {
    final items = _historial.isNotEmpty ? _historial : _historialLocal;
    if (items.isEmpty) return const SizedBox();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Historial de actividades',
          style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.texto)),
      const SizedBox(height: 12),
      ...items.take(8).map((h) => _HistorialItem(item: h as Map<String, dynamic>)),
    ]);
  }
}

class _LibroProgresoItem extends StatelessWidget {
  final Map<String, dynamic> progreso;
  const _LibroProgresoItem({required this.progreso});

  @override
  Widget build(BuildContext context) {
    final titulo = progreso['libro_titulo'] as String? ?? '';
    final pct = (progreso['porcentaje'] as num?)?.toInt() ?? 0;
    final completado = progreso['completado'] as bool? ?? false;
    final intentos = (progreso['intentos'] as num?)?.toInt() ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.sombraSuave],
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: completado ? AppColors.exito.withOpacity(0.3) : AppColors.celeste.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Center(child: Text(completado ? '✅' : '📖', style: const TextStyle(fontSize: 22))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(titulo, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.texto),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Row(children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct / 100.0,
                  backgroundColor: AppColors.lila.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation(completado ? AppColors.exitoTexto : AppColors.lilaOscuro),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text('$pct%', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700,
                color: completado ? AppColors.exitoTexto : AppColors.lilaOscuro)),
          ]),
        ])),
        const SizedBox(width: 8),
        Text('$intentos\nveces', style: GoogleFonts.nunito(fontSize: 11, color: AppColors.textoSuave), textAlign: TextAlign.center),
      ]),
    );
  }
}

class _HistorialItem extends StatelessWidget {
  final Map<String, dynamic> item;
  const _HistorialItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final titulo = item['libro_titulo'] as String? ?? '';
    final puntos = (item['puntos_obtenidos'] as num?)?.toInt() ?? 0;
    final completado = item['completado'] as bool? ?? false;
    final fecha = item['fecha'] as String? ?? '';
    final fechaStr = fecha.isNotEmpty ? fecha.substring(0, 10) : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [AppColors.sombraSuave],
      ),
      child: Row(children: [
        Text(completado ? '✅' : '📖', style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(titulo, style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.texto),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(fechaStr, style: GoogleFonts.nunito(fontSize: 11, color: AppColors.textoSuave)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.amarillo.withOpacity(0.4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('+$puntos pts',
              style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.amarilloOscuro)),
        ),
      ]),
    );
  }
}
