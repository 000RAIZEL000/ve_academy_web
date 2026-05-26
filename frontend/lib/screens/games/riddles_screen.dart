import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';
import '../../models/game_data.dart';
import '../../data/datos_locales.dart';

class RiddlesScreen extends StatefulWidget {
  final String slug;
  final Map<String, dynamic> session;
  const RiddlesScreen({super.key, required this.slug, required this.session});

  @override
  State<RiddlesScreen> createState() => _RiddlesScreenState();
}

class _RiddlesScreenState extends State<RiddlesScreen> {
  BookGameData? _gameData;
  bool _loading = true;
  List<Riddle> _riddles = [];
  int _actual = 0;
  int _correctas = 0;
  String? _seleccionada;
  bool _respondida = false;
  bool _completado = false;

  @override
  void initState() {
    super.initState();
    final local = DatosLocales.getJuegos(widget.slug);
    if (local != null) {
      _gameData = local;
      _riddles = List<Riddle>.from(local.adivinanzas)..shuffle(Random());
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
        _riddles = List<Riddle>.from(data.adivinanzas)..shuffle(Random());
        _loading = false;
      });
    } catch (_) {
      if (mounted && _loading) setState(() => _loading = false);
    }
  }

  void _seleccionar(String opcion) {
    if (_respondida) return;
    setState(() {
      _seleccionada = opcion;
      _respondida = true;
      if (opcion == _riddles[_actual].answer) {
        _correctas++;
      }
    });
  }

  void _siguiente() {
    if (_actual < _riddles.length - 1) {
      setState(() {
        _actual++;
        _seleccionada = null;
        _respondida = false;
      });
    } else {
      setState(() => _completado = true);
      _notificarExito();
    }
  }

  Future<void> _notificarExito() async {
    try {
      final token = widget.session['token'] as String?;
      await ApiService().completarActividad(widget.slug, 'juego_adivinanzas', token: token);
    } catch (_) {}
  }

  void _reiniciar() {
    setState(() {
      _riddles.shuffle(Random());
      _actual = 0;
      _correctas = 0;
      _completado = false;
      _seleccionada = null;
      _respondida = false;
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
        title: Text('Adivinanzas 🕵️', 
            style: GoogleFonts.baloo2(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.texto)),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.rosaOscuro))
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: _riddles.isEmpty
                    ? _buildVacio()
                    : _completado
                        ? _buildCompletado()
                        : _buildJuego(),
              ),
            ),
    );
  }

  Widget _buildJuego() {
    final riddle = _riddles[_actual];
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (_actual + 1) / _riddles.length,
              backgroundColor: const Color(0xFFE2FFE2),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF4CAF50)),
              minHeight: 8,
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text('🕵️‍♂️', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [AppColors.sombraSuave],
                    border: Border.all(color: const Color(0xFFE2FFE2), width: 2),
                  ),
                  child: Text(
                    riddle.question,
                    style: GoogleFonts.baloo2(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.texto,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                ...riddle.options.map((opt) {
                  bool isCorrect = opt == riddle.answer;
                  bool isSelected = opt == _seleccionada;
                  
                  Color bg = Colors.white;
                  Color border = AppColors.lila;
                  if (_respondida) {
                    if (isCorrect) {
                      bg = AppColors.exito.withOpacity(0.3);
                      border = AppColors.exitoTexto;
                    } else if (isSelected) {
                      bg = AppColors.error.withOpacity(0.3);
                      border = AppColors.errorTexto;
                    } else {
                      bg = Colors.grey.shade50;
                      border = Colors.grey.shade200;
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () => _seleccionar(opt),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: border, width: 2.5),
                          boxShadow: isSelected ? [] : [AppColors.sombraSuave],
                        ),
                        child: Center(
                          child: Text(
                            opt,
                            style: GoogleFonts.baloo2(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.texto,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
                if (_respondida) ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _siguiente,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      child: Text(
                        _actual < _riddles.length - 1 ? 'Siguiente Adivinanza →' : '¡Ver mi premio!',
                        style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.w700),
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

  Widget _buildCompletado() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🥳', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 20),
          Text('¡Eres un gran detective!', 
              style: GoogleFonts.baloo2(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.texto)),
          Text('Has acertado $_correctas de ${_riddles.length}', 
              style: GoogleFonts.nunito(fontSize: 18, color: AppColors.textoSuave)),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _reiniciar,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('Jugar otra vez', style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE2FFE2),
              foregroundColor: const Color(0xFF2E7D32),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Volver al menú', style: GoogleFonts.nunito(fontSize: 16, color: AppColors.textoSuave)),
          ),
        ],
      ),
    );
  }

  Widget _buildVacio() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text('No hay adivinanzas para este libro.', 
                style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.texto)),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Volver')),
          ],
        ),
      );
}
