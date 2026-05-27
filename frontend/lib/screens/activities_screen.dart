import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import '../services/progress_service.dart';

class ActivitiesScreen extends StatefulWidget {
  final Map<String, dynamic> libroDetalle;
  final Map<String, dynamic> session;
  final void Function(Map<String, dynamic>)? onSessionUpdated;

  const ActivitiesScreen({
    super.key,
    required this.libroDetalle,
    required this.session,
    this.onSessionUpdated,
  });

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _preguntas = [];
  int _actual = 0;
  int _correctas = 0;
  int? _seleccionada;
  bool _respondida = false;
  bool _finalizado = false;
  int _estrellas = 0;
  int _puntosGanados = 0;
  bool _guardando = false;
  late AnimationController _animCtrl;
  late Animation<double> _shake;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _shake = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animCtrl, curve: Curves.elasticIn));
    _cargarPreguntas();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _cargarPreguntas() {
    final edad = (widget.session['edad'] as num?)?.toInt() ?? 5;
    final todasPreguntas =
        (widget.libroDetalle['preguntas'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>();
    _preguntas = todasPreguntas
        .where((p) => (p['edad'] as num?)?.toInt() == edad)
        .toList();
    if (_preguntas.isEmpty) _preguntas = todasPreguntas.take(5).toList();
  }

  void _seleccionar(int idx) {
    if (_respondida) return;
    setState(() {
      _seleccionada = idx;
      _respondida = true;
    });
    final correcta = (_preguntas[_actual]['correcta'] as num).toInt();
    if (idx == correcta) {
      _correctas++;
    } else {
      _animCtrl.forward(from: 0);
    }
  }

  Future<void> _siguiente() async {
    if (_actual < _preguntas.length - 1) {
      setState(() {
        _actual++;
        _seleccionada = null;
        _respondida = false;
      });
    } else {
      await _finalizar();
    }
  }

  Future<void> _finalizar() async {
    setState(() => _guardando = true);
    try {
      final total = _preguntas.length;
      final token = widget.session['token'] as String?;
      final estudianteId = (widget.session['id'] as num).toInt();
      final libroId = (widget.libroDetalle['id'] as num).toInt();

      final result = await ApiService().guardarResultado(
        estudianteId: estudianteId,
        libroId: libroId,
        puntos: _correctas,
        total: total,
        token: token,
      );

      _puntosGanados = (result['puntos_ganados'] as num?)?.toInt() ?? _correctas * 10;
      final totalPuntos = (result['puntos_totales'] as num?)?.toInt() ??
          ((widget.session['puntos'] as num?)?.toInt() ?? 0) + _puntosGanados;
      await SessionService.updatePuntos(totalPuntos);

      final slug = widget.libroDetalle['slug'] as String? ?? '';
      final titulo = widget.libroDetalle['titulo'] as String? ?? '';
      await ProgressService.completarLibro(slug: slug, titulo: titulo, puntosGanados: _puntosGanados);

      if (widget.onSessionUpdated != null) {
        final upd = Map<String, dynamic>.from(widget.session)..['puntos'] = totalPuntos;
        widget.onSessionUpdated!(upd);
      }

      final pct = total > 0 ? _correctas / total : 0.0;
      _estrellas = _correctas == 0 ? 0 : (pct >= 0.9 ? 3 : (pct >= 0.5 ? 2 : 1));
    } catch (_) {
      final pct = _preguntas.isNotEmpty ? _correctas / _preguntas.length : 0.0;
      _estrellas = _correctas == 0 ? 0 : (pct >= 0.9 ? 3 : (pct >= 0.5 ? 2 : 1));
      _puntosGanados = _correctas * 10;
      final existingPuntos = (widget.session['puntos'] as num?)?.toInt() ?? 0;
      final newTotal = existingPuntos + _puntosGanados;
      await SessionService.updatePuntos(newTotal);

      final slug = widget.libroDetalle['slug'] as String? ?? '';
      final titulo = widget.libroDetalle['titulo'] as String? ?? '';
      await ProgressService.completarLibro(slug: slug, titulo: titulo, puntosGanados: _puntosGanados);

      if (widget.onSessionUpdated != null) {
        final upd = Map<String, dynamic>.from(widget.session)..['puntos'] = newTotal;
        widget.onSessionUpdated!(upd);
      }
    }
    setState(() {
      _finalizado = true;
      _guardando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.texto),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Actividades',
            style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.texto)),
        centerTitle: true,
        actions: [
          if (!_finalizado)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text('${_actual + 1}/${_preguntas.length}',
                    style: GoogleFonts.nunito(
                        fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textoSuave)),
              ),
            ),
        ],
      ),
      body: _guardando
          ? const Center(child: CircularProgressIndicator(color: AppColors.rosaOscuro))
          : _finalizado
              ? _buildResultado()
              : _preguntas.isEmpty
                  ? _buildSinPreguntas()
                  : _buildPregunta(),
    );
  }

  Widget _buildPregunta() {
    final pregunta = _preguntas[_actual];
    final enunciado = pregunta['enunciado'] as String? ?? '';
    final opciones = (pregunta['opciones'] as List<dynamic>? ?? []).cast<String>();
    final correcta = (pregunta['correcta'] as num).toInt();
    final tipo = pregunta['tipo'] as String? ?? 'multiple';
    final progreso = (_actual + 1) / _preguntas.length;

    return Column(
      children: [
        // Progreso
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progreso,
              backgroundColor: AppColors.lila.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation(AppColors.lilaOscuro),
              minHeight: 8,
            ),
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Enunciado
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF0E8FF), Color(0xFFE8F4FF)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [AppColors.sombraLila],
                  ),
                  child: Column(children: [
                    Text(tipo == 'completar' ? '✏️ Completa la frase:' : '🤔 Pregunta ${_actual + 1}:',
                        style: GoogleFonts.nunito(fontSize: 13, color: AppColors.lilaOscuro, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Text(enunciado,
                        style: GoogleFonts.baloo2(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.texto, height: 1.3),
                        textAlign: TextAlign.center),
                  ]),
                ),
                const SizedBox(height: 24),

                // Opciones
                ...List.generate(opciones.length, (i) {
                  Color? bg, border;
                  IconData? icon;
                  if (_respondida) {
                    if (i == correcta) {
                      bg = AppColors.exito.withOpacity(0.3);
                      border = AppColors.exitoTexto;
                      icon = Icons.check_circle_rounded;
                    } else if (i == _seleccionada) {
                      bg = AppColors.error.withOpacity(0.3);
                      border = AppColors.errorTexto;
                      icon = Icons.cancel_rounded;
                    } else {
                      bg = Colors.grey.shade50;
                      border = Colors.grey.shade200;
                    }
                  } else {
                    bg = Colors.white;
                    border = AppColors.lila;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () => _seleccionar(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: border!, width: 2),
                          boxShadow: _respondida && i == correcta ? [AppColors.sombraSuave] : [],
                        ),
                        child: Row(children: [
                          Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              color: border.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(['A', 'B', 'C'][i],
                                  style: GoogleFonts.baloo2(fontSize: 16, fontWeight: FontWeight.w800, color: border)),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(opciones[i],
                                style: GoogleFonts.nunito(
                                    fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.texto)),
                          ),
                          if (_respondida && icon != null)
                            Icon(icon, color: border, size: 24),
                        ]),
                      ),
                    ),
                  );
                }),

                if (_respondida) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _seleccionada == (_preguntas[_actual]['correcta'] as num).toInt()
                          ? AppColors.exito.withOpacity(0.2)
                          : AppColors.error.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(children: [
                      Text(
                        _seleccionada == (_preguntas[_actual]['correcta'] as num).toInt()
                            ? '✅ ¡Correcto! ¡Muy bien!'
                            : '❌ La respuesta era: ${opciones[(_preguntas[_actual]['correcta'] as num).toInt()]}',
                        style: GoogleFonts.nunito(
                            fontSize: 15, fontWeight: FontWeight.w700,
                            color: _seleccionada == (_preguntas[_actual]['correcta'] as num).toInt()
                                ? AppColors.exitoTexto
                                : AppColors.errorTexto),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity, height: 52,
                    child: ElevatedButton(
                      onPressed: _siguiente,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.rosa,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        elevation: 0,
                      ),
                      child: Text(
                        _actual < _preguntas.length - 1 ? 'Siguiente pregunta →' : '¡Ver resultados!',
                        style: GoogleFonts.baloo2(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.texto),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultado() {
    final total = _preguntas.length;
    final pct = total > 0 ? _correctas / total : 0.0;
    final stars = List.generate(3, (i) => i < _estrellas);
    final mensajes = [
      '¡Sigue intentándolo! Puedes mejorar 💪',
      '¡Buen intento! ¡Sigue practicando! 💪',
      '¡Muy bien! ¡Casi perfecto! 🌟',
      '¡INCREÍBLE! ¡Eres un campeón! 🏆',
    ];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                gradient: AppColors.gradienteLogros,
                shape: BoxShape.circle,
                boxShadow: [AppColors.sombraLila],
              ),
              child: Center(
                child: Text(
                  _estrellas == 3 ? '🏆' : (_estrellas == 2 ? '🌟' : (_estrellas == 1 ? '📖' : '💪')),
                  style: const TextStyle(fontSize: 56),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('¡Actividad Completada!',
                style: GoogleFonts.baloo2(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.texto),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(mensajes[_estrellas],
                style: GoogleFonts.nunito(fontSize: 17, color: AppColors.textoSuave),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),

            // Estrellas
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              ...stars.map((lit) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(lit ? '⭐' : '☆',
                        style: TextStyle(fontSize: lit ? 42 : 36)),
                  )),
            ]),
            const SizedBox(height: 24),

            // Score
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFF0E8FF), Color(0xFFE8F4FF)]),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _scoreItem('$_correctas/$total', 'Correctas', '✅'),
                _scoreItem('${(pct * 100).round()}%', 'Aciertos', '📊'),
                _scoreItem('+$_puntosGanados', 'Puntos', '⭐'),
              ]),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity, height: 54,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.rosa,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  elevation: 0,
                ),
                child: Text('¡Seguir Leyendo!',
                    style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.texto)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scoreItem(String value, String label, String emoji) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(emoji, style: const TextStyle(fontSize: 28)),
      const SizedBox(height: 4),
      Text(value, style: GoogleFonts.baloo2(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.texto)),
      Text(label, style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textoSuave)),
    ]);
  }

  Widget _buildSinPreguntas() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('📝', style: TextStyle(fontSize: 56)),
        const SizedBox(height: 16),
        Text('Sin preguntas disponibles',
            style: GoogleFonts.baloo2(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.texto)),
        const SizedBox(height: 8),
        Text('No hay preguntas para tu edad en este libro',
            style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textoSuave),
            textAlign: TextAlign.center),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Volver'),
        ),
      ]),
    );
  }
}
