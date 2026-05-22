import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/libro.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import '../theme/app_colors.dart';
import 'games_menu_screen.dart';

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
  bool _savingResult = false;
  int? _puntosGanados;
  int? _puntosTotal;
  bool? _answered; // null = sin responder, true = correcta, false = incorrecta
  int? _selectedIndex;

  List<Pregunta> get _questions =>
      widget.libro.preguntas.where((q) => q.edad == widget.estudianteEdad).toList();

  void _selectAnswer(int index) {
    if (_answered != null) return; // ya respondió esta pregunta
    final correct = _questions[_currentIndex].correcta;
    final isCorrect = index == correct;
    setState(() {
      _selectedIndex = index;
      _answered = isCorrect;
      if (isCorrect) _score++;
    });

    // Avanzar tras breve pausa para mostrar feedback visual
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        if (_currentIndex < _questions.length - 1) {
          _currentIndex++;
          _answered = null;
          _selectedIndex = null;
        } else {
          _showResults = true;
          _saveResult();
        }
      });
    });
  }

  Future<void> _saveResult() async {
    setState(() => _savingResult = true);
    try {
      final token = await SessionService.getToken();
      final result = await ApiService().guardarResultado(
        estudianteId: widget.estudianteId,
        libroId: widget.libro.id,
        puntos: _score,
        total: _questions.length,
        token: token,
      );
      setState(() {
        _puntosGanados = result['puntos_ganados'] as int?;
        _puntosTotal = result['puntos_totales'] as int?;
      });
    } catch (_) {
      // No bloquear al usuario si falla el guardado
    } finally {
      if (mounted) setState(() => _savingResult = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(
        title: Text(
          'Desafío: ${widget.libro.titulo}',
          style: GoogleFonts.baloo2(fontWeight: FontWeight.w700),
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: AppColors.headerGradientEnd,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: _questions.isEmpty
            ? _buildNoQuestions()
            : _showResults
                ? _buildResults()
                : _buildQuizBody(),
      ),
    );
  }

  Widget _buildNoQuestions() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, size: 60, color: Colors.orange),
          const SizedBox(height: 16),
          Text(
            'No hay preguntas para ${widget.estudianteEdad} años\nen este libro todavía.',
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Volver'),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final total = _questions.length;
    final pct = total > 0 ? (_score / total * 100).round() : 0;
    final passed = _score >= total / 2;

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              passed ? Icons.stars_rounded : Icons.sentiment_neutral_rounded,
              size: 100,
              color: passed ? Colors.amber : Colors.grey,
            ),
            const SizedBox(height: 20),
            Text(
              passed ? '¡Excelente trabajo!' : '¡Buen intento!',
              style: GoogleFonts.baloo2(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.texto,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$_score de $total respuestas correctas ($pct%)',
              style: const TextStyle(fontSize: 20, color: AppColors.gris),
            ),
            if (_savingResult)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(color: AppColors.verde),
              )
            else if (_puntosGanados != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.verde.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.verde),
                ),
                child: Column(
                  children: [
                    Text(
                      '+$_puntosGanados puntos ganados',
                      style: const TextStyle(
                        fontSize: 20,
                        color: AppColors.verde,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_puntosTotal != null)
                      Text(
                        'Total: ⭐ $_puntosTotal puntos',
                        style: const TextStyle(fontSize: 15, color: AppColors.gris),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GamesMenuScreen(
                      libro: widget.libro,
                      estudianteId: widget.estudianteId,
                      estudianteEdad: widget.estudianteEdad,
                    ),
                  ),
                ),
                icon: const Icon(Icons.videogame_asset_rounded, size: 24),
                label: Text(
                  '¡Más Juegos! 🎮',
                  style: GoogleFonts.baloo2(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C3DE0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver al libro'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.azul,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizBody() {
    final question = _questions[_currentIndex];
    final total = _questions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Barra de progreso
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  value: (_currentIndex + 1) / total,
                  minHeight: 10,
                  backgroundColor: const Color(0xFFE0E0E0),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.verde),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${_currentIndex + 1}/$total',
              style: const TextStyle(color: AppColors.gris, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 28),

        // Pregunta
        Text(
          question.enunciado,
          style: GoogleFonts.baloo2(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.texto,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 32),

        // Opciones
        ...List.generate(question.opciones.length, (index) {
          final isSelected = _selectedIndex == index;
          final correct = question.correcta;
          Color borderColor = AppColors.azul.withOpacity(0.3);
          Color bgColor = Colors.white;
          IconData? trailingIcon;

          if (_answered != null && isSelected) {
            if (_answered!) {
              borderColor = AppColors.verde;
              bgColor = AppColors.verde.withOpacity(0.08);
              trailingIcon = Icons.check_circle_outline;
            } else {
              borderColor = Colors.red;
              bgColor = Colors.red.withOpacity(0.06);
              trailingIcon = Icons.cancel_outlined;
            }
          } else if (_answered != null && index == correct) {
            borderColor = AppColors.verde;
            bgColor = AppColors.verde.withOpacity(0.08);
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 14.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor, width: 2),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _answered == null ? () => _selectAnswer(index) : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            question.opciones[index],
                            style: GoogleFonts.nunito(
                              fontSize: 17,
                              color: AppColors.texto,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (trailingIcon != null)
                          Icon(
                            trailingIcon,
                            color: _answered! ? AppColors.verde : Colors.red,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
