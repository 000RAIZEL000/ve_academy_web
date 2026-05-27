import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';
import '../../models/game_data.dart';
import '../../data/datos_locales.dart';

class CompleteWordScreen extends StatefulWidget {
  final String slug;
  final Map<String, dynamic> session;
  const CompleteWordScreen({super.key, required this.slug, required this.session});

  @override
  State<CompleteWordScreen> createState() => _CompleteWordScreenState();
}

class _CompleteWordScreenState extends State<CompleteWordScreen> {
  BookGameData? _gameData;
  bool _loading = true;
  List<GameWord> _palabras = [];
  int _actual = 0;
  int _correctas = 0;
  bool _completado = false;
  List<String> _opciones = [];
  String? _seleccionada;
  bool _respondida = false;

  @override
  void initState() {
    super.initState();
    final local = DatosLocales.getJuegos(widget.slug);
    if (local != null) {
      _gameData = local;
      _palabras = List<GameWord>.from(local.palabras)..shuffle(Random());
      _generarOpciones();
      _loading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _cargar());
    } else {
      _cargar();
    }
  }

  Future<void> _cargar() async {
    try {
      final token = widget.session['token'] as String?;
      final data = await ApiService().getJuegos(widget.slug, token: token);
      if (!mounted || !_loading) return;
      setState(() {
        _gameData = data;
        _palabras = List<GameWord>.from(data.palabras)..shuffle(Random());
        _generarOpciones();
        _loading = false;
      });
    } catch (_) {
      if (mounted && _loading) setState(() => _loading = false);
    }
  }

  void _generarOpciones() {
    if (_palabras.isEmpty || _actual >= _palabras.length) return;
    final correcta = _palabras[_actual].word;
    final otras = _palabras.map((p) => p.word).where((w) => w != correcta).toList()..shuffle(Random());
    _opciones = [correcta, ...otras.take(3)];
    _opciones.shuffle(Random());
    _seleccionada = null;
    _respondida = false;
  }

  String _ocultarPalabra(String word) {
    if (word.length <= 2) return '_' * word.length;
    final inicio = word[0];
    final fin = word[word.length - 1];
    final medio = '_' * (word.length - 2);
    return '$inicio$medio$fin';
  }

  void _seleccionar(String opcion) {
    if (_respondida) return;
    setState(() {
      _seleccionada = opcion;
      _respondida = true;
      if (opcion == _palabras[_actual].word) _correctas++;
    });
  }

  void _siguiente() {
    if (_actual < _palabras.length - 1) {
      setState(() { _actual++; _generarOpciones(); });
    } else {
      setState(() => _completado = true);
      _notificarExito();
    }
  }

  Future<void> _notificarExito() async {
    try {
      final token = widget.session['token'] as String?;
      final estudianteId = (widget.session['id'] as num?)?.toInt();
      await ApiService().completarActividad(widget.slug, 'juego_completar', token: token, estudianteId: estudianteId);
    } catch (_) {}
  }

  void _reiniciar() {
    setState(() {
      _palabras.shuffle(Random());
      _actual = 0;
      _correctas = 0;
      _completado = false;
      _generarOpciones();
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
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.texto),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Completar Palabras ✏️', style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.texto)),
        centerTitle: true,
        actions: [
          if (!_completado)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(child: Text('${_actual + 1}/${_palabras.length}',
                  style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textoSuave))),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.rosaOscuro))
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: _palabras.isEmpty
                    ? _buildVacio()
                    : _completado
                        ? _buildCompletado()
                        : _buildJuego(),
              ),
            ),
    );
  }

  Widget _buildJuego() {
    final palabra = _palabras[_actual];
    final ocultada = _ocultarPalabra(palabra.word);

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (_actual + 1) / _palabras.length,
              backgroundColor: AppColors.amarillo.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation(AppColors.amarilloOscuro),
              minHeight: 8,
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Emoji grande
                Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradienteLogros,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [AppColors.sombraLila],
                  ),
                  child: Center(child: Text(palabra.emoji, style: const TextStyle(fontSize: 64))),
                ),
                const SizedBox(height: 20),

                // Instrucción
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.amarillo.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(children: [
                    Text('¿Qué palabra es?', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.amarilloOscuro)),
                    const SizedBox(height: 10),
                    Text(ocultada,
                        style: GoogleFonts.baloo2(fontSize: 36, fontWeight: FontWeight.w800, color: AppColors.texto,
                            letterSpacing: 6)),
                  ]),
                ),
                const SizedBox(height: 24),

                // Opciones
                ...List.generate(_opciones.length, (i) {
                  final op = _opciones[i];
                  Color bg = Colors.white;
                  Color border = AppColors.lila;
                  if (_respondida) {
                    if (op == palabra.word) {
                      bg = AppColors.exito.withOpacity(0.3);
                      border = AppColors.exitoTexto;
                    } else if (op == _seleccionada) {
                      bg = AppColors.error.withOpacity(0.3);
                      border = AppColors.errorTexto;
                    } else {
                      bg = Colors.grey.shade50;
                      border = Colors.grey.shade200;
                    }
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: GestureDetector(
                      onTap: () => _seleccionar(op),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: border, width: 2),
                          boxShadow: [AppColors.sombraSuave],
                        ),
                        child: Center(child: Text(op,
                            style: GoogleFonts.baloo2(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.texto))),
                      ),
                    ),
                  );
                }),

                if (_respondida) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _seleccionada == palabra.word ? AppColors.exito.withOpacity(0.2) : AppColors.error.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      _seleccionada == palabra.word
                          ? '✅ ¡Correcto! La palabra es "${palabra.word}" ${palabra.emoji}'
                          : '❌ La palabra correcta es "${palabra.word}" ${palabra.emoji}',
                      style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700,
                          color: _seleccionada == palabra.word ? AppColors.exitoTexto : AppColors.errorTexto),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton(
                      onPressed: _siguiente,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.amarillo, elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                      child: Text(_actual < _palabras.length - 1 ? 'Siguiente →' : '¡Ver resultado!',
                          style: GoogleFonts.baloo2(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.texto)),
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

  Widget _buildCompletado() => Center(child: Padding(
    padding: const EdgeInsets.all(28),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('✏️', style: TextStyle(fontSize: 80)),
      const SizedBox(height: 16),
      Text('¡Completado!', style: GoogleFonts.baloo2(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.texto)),
      Text('$_correctas/${_palabras.length} palabras correctas',
          style: GoogleFonts.nunito(fontSize: 18, color: AppColors.textoSuave)),
      const SizedBox(height: 24),
      SizedBox(width: double.infinity, height: 50,
          child: ElevatedButton.icon(
            onPressed: _reiniciar,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('Jugar otra vez', style: GoogleFonts.baloo2(fontSize: 17, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.amarillo, elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
          )),
      const SizedBox(height: 12),
      TextButton(onPressed: () => Navigator.pop(context),
          child: Text('Volver', style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textoSuave))),
    ]),
  ));

  Widget _buildVacio() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    const Text('✏️', style: TextStyle(fontSize: 56)),
    Text('Sin palabras disponibles', style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.texto)),
    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Volver')),
  ]));
}
