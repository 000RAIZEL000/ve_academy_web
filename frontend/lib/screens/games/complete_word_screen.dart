import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/game_data.dart';
import '../../models/libro.dart';
import '../../widgets/celebration_overlay.dart';

class CompleteWordScreen extends StatefulWidget {
  final Libro libro;
  final BookGameData gameData;
  final int estudianteId;
  final int estudianteEdad;

  const CompleteWordScreen({
    super.key,
    required this.libro,
    required this.gameData,
    required this.estudianteId,
    required this.estudianteEdad,
  });

  @override
  State<CompleteWordScreen> createState() => _CompleteWordScreenState();
}

class _CompleteWordScreenState extends State<CompleteWordScreen>
    with TickerProviderStateMixin {
  late List<GameWord> _rounds;
  int _currentRound = 0;
  int _score = 0;
  bool _showCelebration = false;
  bool _answered = false;
  bool? _correct;
  late int _blankIndex;
  late List<String> _options;
  late AnimationController _shakeCtrl;
  late Animation<double> _shake;

  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _rounds = List.from(widget.gameData.palabras)..shuffle(_rng);
    if (_rounds.isEmpty) _rounds = [const GameWord(word: 'HOLA', emoji: '👋')];
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shake = Tween(begin: 0.0, end: 8.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeCtrl);
    _setupRound();
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }

  void _setupRound() {
    final word = _rounds[_currentRound].word;
    // Blank a letter in the middle (avoid first and last if possible)
    _blankIndex = word.length > 2
        ? 1 + _rng.nextInt(word.length - 2)
        : _rng.nextInt(word.length);

    final correct = word[_blankIndex];
    const alphabet = 'ABCDEFGHIJKLMNOPRSTUVYZ';
    final distractors = <String>{};
    while (distractors.length < 5) {
      final l = alphabet[_rng.nextInt(alphabet.length)];
      if (l != correct) distractors.add(l);
    }
    _options = [correct, ...distractors]..shuffle(_rng);
    _answered = false;
    _correct = null;
  }

  void _selectLetter(String letter) {
    if (_answered) return;
    final correct = _rounds[_currentRound].word[_blankIndex];
    final isCorrect = letter == correct;
    setState(() {
      _answered = true;
      _correct = isCorrect;
      if (isCorrect) _score += 20;
    });

    if (!isCorrect) {
      _shakeCtrl.forward(from: 0);
    }

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      if (_currentRound < _rounds.length - 1) {
        setState(() {
          _currentRound++;
          _setupRound();
        });
      } else {
        setState(() => _showCelebration = true);
      }
    });
  }

  String _maskedWord() {
    final word = _rounds[_currentRound].word;
    return word
        .split('')
        .asMap()
        .entries
        .map((e) => e.key == _blankIndex ? '_' : e.value)
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final current = _rounds[_currentRound];
    final stars = _score >= _rounds.length * 16
        ? 3
        : _score >= _rounds.length * 10
            ? 2
            : 1;

    return Scaffold(
      backgroundColor: const Color(0xFF0f3460),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213e),
        foregroundColor: Colors.white,
        title: Text(
          '🅰️ Completa la Palabra',
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
                  value: (_currentRound + 1) / _rounds.length,
                  backgroundColor: Colors.white24,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFFf7971e)),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_currentRound + 1} de ${_rounds.length}',
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
                const Spacer(),

                // Emoji (big)
                AnimatedBuilder(
                  animation: _shakeCtrl,
                  builder: (ctx, child) => Transform.translate(
                    offset: Offset(_correct == false ? sin(_shake.value) * 4 : 0, 0),
                    child: child,
                  ),
                  child: Text(
                    current.emoji,
                    style: const TextStyle(fontSize: 90),
                  ),
                ),
                const SizedBox(height: 24),

                // Masked word
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _answered == false
                          ? Colors.white30
                          : _correct == true
                              ? Colors.greenAccent
                              : Colors.redAccent,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    _maskedWord(),
                    style: GoogleFonts.baloo2(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 6,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '¿Cuál letra falta?',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),

                // Letter options
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: _options.map((letter) {
                    final correctLetter =
                        _rounds[_currentRound].word[_blankIndex];
                    Color bg = const Color(0xFF8E2DE2);
                    Color border = const Color(0xFFb060ff);

                    if (_answered) {
                      if (letter == correctLetter) {
                        bg = Colors.greenAccent.withAlpha(100);
                        border = Colors.greenAccent;
                      } else {
                        bg = Colors.white.withAlpha(10);
                        border = Colors.white24;
                      }
                    }

                    return GestureDetector(
                      onTap: _answered ? null : () => _selectLetter(letter),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: border, width: 2),
                          boxShadow: _answered
                              ? null
                              : [
                                  BoxShadow(
                                    color: const Color(0xFF6C3DE0).withAlpha(80),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  )
                                ],
                        ),
                        child: Center(
                          child: Text(
                            letter,
                            style: GoogleFonts.baloo2(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
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
              message: '$_score de ${_rounds.length * 20} puntos',
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
