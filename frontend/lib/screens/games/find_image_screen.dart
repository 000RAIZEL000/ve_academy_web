import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/game_data.dart';
import '../../models/libro.dart';
import '../../widgets/celebration_overlay.dart';

class FindImageScreen extends StatefulWidget {
  final Libro libro;
  final BookGameData gameData;
  final int estudianteId;
  final int estudianteEdad;

  const FindImageScreen({
    super.key,
    required this.libro,
    required this.gameData,
    required this.estudianteId,
    required this.estudianteEdad,
  });

  @override
  State<FindImageScreen> createState() => _FindImageScreenState();
}

class _FindImageScreenState extends State<FindImageScreen> {
  late List<_Round> _rounds;
  int _current = 0;
  int _score = 0;
  bool _showCelebration = false;
  int? _selectedIndex;
  bool _answered = false;

  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _rounds = _buildRounds();
  }

  List<_Round> _buildRounds() {
    final words = widget.gameData.palabras;
    if (words.isEmpty) return [];
    return words.map((gw) {
      final distractors = words.where((w) => w.word != gw.word).toList()
        ..shuffle(_rng);
      final options = [gw, ...distractors.take(3)].toList()..shuffle(_rng);
      final correctIdx = options.indexOf(gw);
      return _Round(word: gw, options: options, correctIndex: correctIdx);
    }).toList();
  }

  void _select(int index) {
    if (_answered) return;
    final isCorrect = index == _rounds[_current].correctIndex;
    setState(() {
      _selectedIndex = index;
      _answered = true;
      if (isCorrect) _score += 20;
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      if (_current < _rounds.length - 1) {
        setState(() {
          _current++;
          _selectedIndex = null;
          _answered = false;
        });
      } else {
        setState(() => _showCelebration = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_rounds.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF2980B9),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1a5276),
          foregroundColor: Colors.white,
          title: Text('🖼️ Encuentra la Imagen',
              style: GoogleFonts.baloo2(fontWeight: FontWeight.w700)),
        ),
        body: const Center(
          child: Text('No hay juego disponible',
              style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final round = _rounds[_current];
    final maxScore = _rounds.length * 20;
    final stars = _score >= maxScore ? 3 : _score >= maxScore ~/ 2 ? 2 : 1;

    return Scaffold(
      backgroundColor: const Color(0xFF2980B9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a5276),
        foregroundColor: Colors.white,
        title: Text(
          '🖼️ Encuentra la Imagen',
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
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Progress
                LinearProgressIndicator(
                  value: (_current + 1) / _rounds.length,
                  backgroundColor: Colors.white24,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.amber),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_current + 1} de ${_rounds.length}',
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                ),
                const Spacer(),

                // Word display
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(40),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    round.word.word,
                    style: GoogleFonts.baloo2(
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1a5276),
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '¿Cuál imagen corresponde?',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),

                // Emoji options 2x2 grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.3,
                  children: round.options.asMap().entries.map((e) {
                    final i = e.key;
                    final gw = e.value;
                    final isCorrect = i == round.correctIndex;
                    Color bg = const Color(0xFF6DD5FA);
                    Color border = Colors.white30;

                    if (_answered) {
                      if (isCorrect) {
                        bg = Colors.greenAccent.withAlpha(80);
                        border = Colors.greenAccent;
                      } else if (_selectedIndex == i) {
                        bg = Colors.redAccent.withAlpha(80);
                        border = Colors.redAccent;
                      } else {
                        bg = Colors.white.withAlpha(20);
                      }
                    }

                    return GestureDetector(
                      onTap: _answered ? null : () => _select(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: border, width: 2.5),
                          boxShadow: _answered
                              ? null
                              : [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(40),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              gw.emoji,
                              style: const TextStyle(fontSize: 52),
                            ),
                            if (_answered && isCorrect)
                              const Text('✅',
                                  style: TextStyle(fontSize: 20)),
                            if (_answered &&
                                !isCorrect &&
                                _selectedIndex == i)
                              const Text('❌',
                                  style: TextStyle(fontSize: 20)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const Spacer(),
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

class _Round {
  final GameWord word;
  final List<GameWord> options;
  final int correctIndex;
  _Round({required this.word, required this.options, required this.correctIndex});
}
