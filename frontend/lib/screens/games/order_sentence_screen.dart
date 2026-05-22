import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/game_data.dart';
import '../../models/libro.dart';
import '../../widgets/celebration_overlay.dart';

class OrderSentenceScreen extends StatefulWidget {
  final Libro libro;
  final BookGameData gameData;
  final int estudianteId;
  final int estudianteEdad;

  const OrderSentenceScreen({
    super.key,
    required this.libro,
    required this.gameData,
    required this.estudianteId,
    required this.estudianteEdad,
  });

  @override
  State<OrderSentenceScreen> createState() => _OrderSentenceScreenState();
}

class _OrderSentenceScreenState extends State<OrderSentenceScreen> {
  late List<String> _sentences;
  int _round = 0;
  int _score = 0;
  bool _showCelebration = false;
  bool _roundDone = false;
  bool _roundCorrect = false;

  late List<String> _shuffled; // available chips
  final List<String> _built = []; // sentence being built

  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _sentences = List.from(widget.gameData.oraciones);
    if (_sentences.isEmpty) _sentences = ['El sol brilla en el cielo'];
    _setupRound();
  }

  void _setupRound() {
    final words = _sentences[_round].toLowerCase().split(' ');
    _shuffled = List.from(words)..shuffle(_rng);
    // Make sure shuffled ≠ original
    while (_listEquals(_shuffled, words) && words.length > 1) {
      _shuffled.shuffle(_rng);
    }
    _built.clear();
    _roundDone = false;
    _roundCorrect = false;
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _tapChip(int index) {
    if (_roundDone) return;
    setState(() {
      _built.add(_shuffled.removeAt(index));
      _checkAnswer();
    });
  }

  void _removeBuilt(int index) {
    if (_roundDone) return;
    setState(() {
      _shuffled.add(_built.removeAt(index));
    });
  }

  void _checkAnswer() {
    if (_shuffled.isNotEmpty) return; // not all words placed yet
    final target = _sentences[_round].toLowerCase().split(' ');
    final isCorrect = _listEquals(_built, target);
    _roundDone = true;
    _roundCorrect = isCorrect;
    if (isCorrect) _score += 50;

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      if (_round < _sentences.length - 1) {
        setState(() {
          _round++;
          _setupRound();
        });
      } else {
        setState(() => _showCelebration = true);
      }
    });
  }

  void _clearBuilt() {
    if (_roundDone) return;
    setState(() {
      _shuffled.addAll(_built);
      _built.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxScore = _sentences.length * 50;
    final stars = _score >= maxScore ? 3 : _score >= maxScore ~/ 2 ? 2 : 1;

    return Scaffold(
      backgroundColor: const Color(0xFF11998e),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0d7a6e),
        foregroundColor: Colors.white,
        title: Text(
          '📝 Ordena la Oración',
          style: GoogleFonts.baloo2(fontWeight: FontWeight.w700),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '⭐ $_score pts',
                style: const TextStyle(
                    color: Colors.amber, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress
                LinearProgressIndicator(
                  value: (_round + 1) / _sentences.length,
                  backgroundColor: Colors.white24,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.amber),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 6),
                Text(
                  'Oración ${_round + 1} de ${_sentences.length}',
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                Text(
                  '¡Ordena las palabras para formar la frase!',
                  style: GoogleFonts.baloo2(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Answer area
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  constraints: const BoxConstraints(minHeight: 80),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _roundDone
                          ? (_roundCorrect ? Colors.greenAccent : Colors.redAccent)
                          : Colors.white38,
                      width: 2,
                    ),
                  ),
                  child: _built.isEmpty
                      ? Center(
                          child: Text(
                            'Toca las palabras de abajo',
                            style: TextStyle(
                                color: Colors.white38, fontSize: 14),
                          ),
                        )
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _built.asMap().entries.map((e) {
                            return GestureDetector(
                              onTap: () => _removeBuilt(e.key),
                              child: Chip(
                                label: Text(
                                  e.value,
                                  style: GoogleFonts.baloo2(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: const Color(0xFF0d7a6e),
                                  ),
                                ),
                                backgroundColor: Colors.white,
                                side: BorderSide.none,
                              ),
                            );
                          }).toList(),
                        ),
                ),

                // Feedback
                if (_roundDone)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _roundCorrect ? '¡Correcto! 🎉' : '¡Casi! Sigue intentando 💪',
                      style: TextStyle(
                        color: _roundCorrect ? Colors.greenAccent : Colors.orangeAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 24),

                // Shuffled chips
                Text(
                  'Palabras disponibles:',
                  style: GoogleFonts.nunito(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _shuffled.asMap().entries.map((e) {
                    return GestureDetector(
                      onTap: () => _tapChip(e.key),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFf7971e), Color(0xFFffd200)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(40),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            )
                          ],
                        ),
                        child: Text(
                          e.value,
                          style: GoogleFonts.baloo2(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const Spacer(),

                // Clear button
                if (!_roundDone && _built.isNotEmpty)
                  TextButton.icon(
                    onPressed: _clearBuilt,
                    icon: const Icon(Icons.refresh_rounded,
                        color: Colors.white70),
                    label: Text(
                      'Limpiar',
                      style: GoogleFonts.nunito(
                          color: Colors.white70, fontSize: 14),
                    ),
                  ),
              ],
            ),
          ),
          if (_showCelebration)
            CelebrationOverlay(
              message: '$_score de $maxScore puntos',
              stars: stars,
              onComplete: () {
                setState(() => _showCelebration = false);
                Navigator.pop(context, _score);
              },
            ),
        ],
      ),
    );
  }
}
