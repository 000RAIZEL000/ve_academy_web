// Pantalla de quiz legada — reemplazada por ActivitiesScreen
// Se mantiene para compatibilidad de compilación
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/libro.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import '../theme/app_colors.dart';

class QuizScreen extends StatefulWidget {
  final Libro libro;
  final int estudianteId;
  final int estudianteEdad;

  const QuizScreen({
    super.key,
    required this.libro,
    required this.estudianteId,
    required this.estudianteEdad,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int _score = 0;
  bool _showResults = false;
  int? _puntosGanados;

  List<Pregunta> get _questions =>
      widget.libro.preguntas.where((q) => q.edad == widget.estudianteEdad).toList();

  void _selectAnswer(int index) {
    if (_questions.isEmpty) return;
    final correct = _questions[_currentIndex].correcta;
    if (index == correct) _score++;
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        if (_currentIndex < _questions.length - 1) {
          _currentIndex++;
        } else {
          _showResults = true;
          _saveResult();
        }
      });
    });
  }

  Future<void> _saveResult() async {
    try {
      final token = await SessionService.getToken();
      final result = await ApiService().guardarResultado(
        estudianteId: widget.estudianteId,
        libroId: widget.libro.id,
        puntos: _score,
        total: _questions.length,
        token: token,
      );
      setState(() => _puntosGanados = result['puntos_ganados'] as int?);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(
        title: Text(widget.libro.titulo,
            style: GoogleFonts.baloo2(fontWeight: FontWeight.w700, color: AppColors.texto)),
        backgroundColor: AppColors.rosa,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _questions.isEmpty
            ? Center(child: Text('Sin preguntas disponibles',
                style: GoogleFonts.baloo2(fontSize: 18, color: AppColors.texto)))
            : _showResults
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Text('🏆', style: TextStyle(fontSize: 72)),
                    const SizedBox(height: 16),
                    Text('$_score/${_questions.length} correctas',
                        style: GoogleFonts.baloo2(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.texto)),
                    if (_puntosGanados != null)
                      Text('+$_puntosGanados puntos',
                          style: GoogleFonts.nunito(fontSize: 18, color: AppColors.verdeOscuro)),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Volver'),
                    ),
                  ]))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LinearProgressIndicator(
                        value: (_currentIndex + 1) / _questions.length,
                        backgroundColor: AppColors.lila.withOpacity(0.2),
                        valueColor: const AlwaysStoppedAnimation(AppColors.lilaOscuro),
                        minHeight: 8,
                      ),
                      const SizedBox(height: 24),
                      Text(_questions[_currentIndex].enunciado,
                          style: GoogleFonts.baloo2(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.texto)),
                      const SizedBox(height: 24),
                      ...List.generate(_questions[_currentIndex].opciones.length, (i) =>
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ElevatedButton(
                              onPressed: () => _selectAnswer(i),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.lila.withOpacity(0.2),
                                foregroundColor: AppColors.texto,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: Text(_questions[_currentIndex].opciones[i],
                                  style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600)),
                            ),
                          )),
                    ],
                  ),
      ),
    );
  }
}
