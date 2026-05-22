import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/game_data.dart';
import '../../models/libro.dart';
import '../../widgets/celebration_overlay.dart';

class MemoryScreen extends StatefulWidget {
  final Libro libro;
  final BookGameData gameData;
  final int estudianteId;
  final int estudianteEdad;

  const MemoryScreen({
    super.key,
    required this.libro,
    required this.gameData,
    required this.estudianteId,
    required this.estudianteEdad,
  });

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen>
    with TickerProviderStateMixin {
  late List<_MemCard> _cards;
  int? _firstFlipped;
  int? _secondFlipped;
  bool _checking = false;
  int _matches = 0;
  int _score = 0;
  bool _showCelebration = false;

  // Per-card flip controllers
  late List<AnimationController> _flipCtrl;
  late List<Animation<double>> _flipAnim;

  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _buildCards();
  }

  void _buildCards() {
    final words = widget.gameData.palabras.isNotEmpty
        ? widget.gameData.palabras
        : [
            const GameWord(word: 'SOL', emoji: '☀️'),
            const GameWord(word: 'LUNA', emoji: '🌙'),
            const GameWord(word: 'PATO', emoji: '🦆'),
          ];

    _cards = [];
    for (int i = 0; i < words.length; i++) {
      final gw = words[i];
      _cards.add(_MemCard(
          pairId: i, isWord: true, word: gw.word, emoji: gw.emoji));
      _cards.add(_MemCard(
          pairId: i, isWord: false, word: gw.word, emoji: gw.emoji));
    }
    _cards.shuffle(_rng);

    _flipCtrl = List.generate(
      _cards.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 350),
      ),
    );
    _flipAnim = _flipCtrl
        .map((c) =>
            Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
              parent: c,
              curve: Curves.easeInOut,
            )))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _flipCtrl) {
      c.dispose();
    }
    super.dispose();
  }

  void _onCardTap(int index) {
    if (_checking) return;
    if (_cards[index].isMatched) return;
    if (_cards[index].isFlipped) return;
    if (_firstFlipped == index) return;

    _flipCtrl[index].forward();
    setState(() => _cards[index].isFlipped = true);

    if (_firstFlipped == null) {
      _firstFlipped = index;
      return;
    }

    _secondFlipped = index;
    _checking = true;

    final first = _cards[_firstFlipped!];
    final second = _cards[_secondFlipped!];

    if (first.pairId == second.pairId) {
      // Match!
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!mounted) return;
        setState(() {
          _cards[_firstFlipped!].isMatched = true;
          _cards[_secondFlipped!].isMatched = true;
          _firstFlipped = null;
          _secondFlipped = null;
          _checking = false;
          _matches++;
          _score += 20;
          if (_matches == _cards.length ~/ 2) {
            _showCelebration = true;
          }
        });
      });
    } else {
      // No match: flip back after delay
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (!mounted) return;
        _flipCtrl[_firstFlipped!].reverse();
        _flipCtrl[_secondFlipped!].reverse();
        setState(() {
          _cards[_firstFlipped!].isFlipped = false;
          _cards[_secondFlipped!].isFlipped = false;
          _firstFlipped = null;
          _secondFlipped = null;
          _checking = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPairs = _cards.length ~/ 2;
    final stars = _score >= totalPairs * 20
        ? 3
        : _score >= totalPairs * 12
            ? 2
            : 1;

    return Scaffold(
      backgroundColor: const Color(0xFF4a148c),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2d0c6c),
        foregroundColor: Colors.white,
        title: Text(
          '🃏 Memoria de Palabras',
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
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Empareja cada palabra con su imagen',
                  style: GoogleFonts.baloo2(
                    fontSize: 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '$_matches de $totalPairs pares encontrados',
                  style: const TextStyle(color: Colors.white38, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.4,
                    ),
                    itemCount: _cards.length,
                    itemBuilder: (ctx, i) => _buildCard(i),
                  ),
                ),
              ],
            ),
          ),
          if (_showCelebration)
            CelebrationOverlay(
              message: '¡Encontraste todos los pares!\n+$_score puntos',
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

  Widget _buildCard(int index) {
    final card = _cards[index];
    return GestureDetector(
      onTap: () => _onCardTap(index),
      child: AnimatedBuilder(
        animation: _flipAnim[index],
        builder: (ctx, _) {
          final angle = _flipAnim[index].value * pi;
          final isFront = _flipAnim[index].value >= 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isFront
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(pi),
                    child: _buildFront(card),
                  )
                : _buildBack(card),
          );
        },
      ),
    );
  }

  Widget _buildBack(_MemCard card) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: card.isMatched
              ? [Colors.greenAccent.shade700, Colors.green.shade300]
              : [const Color(0xFF9C27B0), const Color(0xFFE040FB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: card.isMatched ? Colors.greenAccent : Colors.purple.shade200,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: card.isMatched
            ? const Text('✅', style: TextStyle(fontSize: 36))
            : const Text('❓', style: TextStyle(fontSize: 36)),
      ),
    );
  }

  Widget _buildFront(_MemCard card) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: card.isWord
            ? Text(
                card.word,
                style: GoogleFonts.baloo2(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF4a148c),
                ),
                textAlign: TextAlign.center,
              )
            : Text(
                card.emoji,
                style: const TextStyle(fontSize: 48),
              ),
      ),
    );
  }
}

class _MemCard {
  final int pairId;
  final bool isWord;
  final String word;
  final String emoji;
  bool isFlipped;
  bool isMatched;

  _MemCard({
    required this.pairId,
    required this.isWord,
    required this.word,
    required this.emoji,
    this.isFlipped = false,
    this.isMatched = false,
  });
}
