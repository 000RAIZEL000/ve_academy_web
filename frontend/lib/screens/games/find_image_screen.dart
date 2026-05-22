import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';
import '../../models/game_data.dart';

class FindImageScreen extends StatefulWidget {
  final String slug;
  final Map<String, dynamic> session;
  const FindImageScreen({super.key, required this.slug, required this.session});

  @override
  State<FindImageScreen> createState() => _FindImageScreenState();
}

class _FindImageScreenState extends State<FindImageScreen> {
  BookGameData? _gameData;
  bool _loading = true;
  List<GameWord> _palabras = [];
  int _actual = 0;
  int _correctas = 0;
  int? _seleccionada;
  bool _respondida = false;
  bool _completado = false;
  List<int> _opciones = [];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final token = widget.session['token'] as String?;
      final data = await ApiService().getJuegos(widget.slug, token: token);
      setState(() {
        _gameData = data;
        _palabras = data.palabras..shuffle(Random());
        _generarOpciones();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _generarOpciones() {
    if (_palabras.isEmpty) return;
    final todos = List.generate(_palabras.length, (i) => i);
    todos.remove(_actual);
    todos.shuffle(Random());
    _opciones = [_actual, ...todos.take(3)];
    _opciones.shuffle(Random());
    _seleccionada = null;
    _respondida = false;
  }

  void _seleccionar(int idx) {
    if (_respondida) return;
    setState(() {
      _seleccionada = idx;
      _respondida = true;
      if (idx == _actual) _correctas++;
    });
  }

  void _siguiente() {
    if (_actual < _palabras.length - 1) {
      setState(() { _actual++; _generarOpciones(); });
    } else {
      setState(() => _completado = true);
    }
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
        title: Text('Palabra e Imagen 🖼️', style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.texto)),
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
          : _palabras.isEmpty
              ? _buildVacio()
              : _completado
                  ? _buildCompletado()
                  : _buildJuego(),
    );
  }

  Widget _buildJuego() {
    final palabra = _palabras[_actual];
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (_actual + 1) / _palabras.length,
              backgroundColor: AppColors.celeste.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation(AppColors.celesteOscuro),
              minHeight: 8,
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFDBF0FF), Color(0xFFEDE4FF)]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(children: [
                    Text('¿Cuál imagen corresponde a?',
                        style: GoogleFonts.nunito(fontSize: 14, color: AppColors.celesteOscuro, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Text(palabra.word,
                        style: GoogleFonts.baloo2(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.texto)),
                  ]),
                ),
                const SizedBox(height: 24),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  children: _opciones.map((idx) {
                    final opt = _palabras[idx];
                    Color bg = Colors.white;
                    Color border = AppColors.lila;
                    if (_respondida) {
                      if (idx == _actual) {
                        bg = AppColors.exito.withOpacity(0.3);
                        border = AppColors.exitoTexto;
                      } else if (idx == _seleccionada) {
                        bg = AppColors.error.withOpacity(0.3);
                        border = AppColors.errorTexto;
                      } else {
                        bg = Colors.grey.shade50;
                        border = Colors.grey.shade200;
                      }
                    }
                    return GestureDetector(
                      onTap: () => _seleccionar(idx),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: border, width: 2.5),
                          boxShadow: [AppColors.sombraSuave],
                        ),
                        child: Center(
                          child: Text(opt.emoji, style: const TextStyle(fontSize: 60)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (_respondida) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _seleccionada == _actual ? AppColors.exito.withOpacity(0.2) : AppColors.error.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      _seleccionada == _actual ? '✅ ¡Correcto! ${palabra.emoji}  = "${palabra.word}"' : '❌ Era: ${palabra.emoji} "${palabra.word}"',
                      style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700,
                          color: _seleccionada == _actual ? AppColors.exitoTexto : AppColors.errorTexto),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton(
                      onPressed: _siguiente,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.celeste, elevation: 0,
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

  Widget _buildCompletado() {
    final pct = _palabras.isNotEmpty ? _correctas / _palabras.length : 0.0;
    return Center(child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(pct >= 0.8 ? '🏆' : '🌟', style: const TextStyle(fontSize: 80)),
        const SizedBox(height: 16),
        Text('¡Juego completado!', style: GoogleFonts.baloo2(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.texto)),
        const SizedBox(height: 8),
        Text('$_correctas de ${_palabras.length} correctas',
            style: GoogleFonts.nunito(fontSize: 18, color: AppColors.textoSuave)),
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, height: 50,
            child: ElevatedButton.icon(
              onPressed: _reiniciar,
              icon: const Icon(Icons.refresh_rounded),
              label: Text('Jugar otra vez', style: GoogleFonts.baloo2(fontSize: 17, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.celeste, elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
            )),
        const SizedBox(height: 12),
        TextButton(onPressed: () => Navigator.pop(context),
            child: Text('Volver', style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textoSuave))),
      ]),
    ));
  }

  Widget _buildVacio() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    const Text('🖼️', style: TextStyle(fontSize: 56)),
    const SizedBox(height: 16),
    Text('Sin datos para este juego', style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.texto)),
    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Volver')),
  ]));
}
