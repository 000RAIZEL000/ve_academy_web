import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/game_data.dart';
import '../../models/libro.dart';
import '../../widgets/celebration_overlay.dart';

class WordSearchScreen extends StatefulWidget {
  final Libro libro;
  final BookGameData gameData;
  final int estudianteId;
  final int estudianteEdad;

  const WordSearchScreen({
    super.key,
    required this.libro,
    required this.gameData,
    required this.estudianteId,
    required this.estudianteEdad,
  });

  @override
  State<WordSearchScreen> createState() => _WordSearchScreenState();
}

class _WordSearchScreenState extends State<WordSearchScreen> {
  static const int _size = 9;

  late List<List<String>> _grid;
  late List<GameWord> _words;
  final Set<String> _foundWords = {};
  final Set<String> _foundCells = {};
  String? _firstCell;
  final Set<String> _selection = {};
  bool _showCelebration = false;
  int _score = 0;

  String _key(int r, int c) => '$r,$c';

  @override
  void initState() {
    super.initState();
    _words = widget.gameData.palabras.take(5).toList();
    _grid = _buildGrid();
  }

  List<List<String>> _buildGrid() {
    final rng = Random();
    final grid = List.generate(_size, (_) => List.filled(_size, ''));

    for (final gw in _words) {
      final word = gw.word;
      if (word.length > _size) continue;
      bool placed = false;
      for (int attempt = 0; attempt < 200 && !placed; attempt++) {
        final horizontal = rng.nextBool();
        final int row = horizontal
            ? rng.nextInt(_size)
            : rng.nextInt(_size - word.length + 1);
        final int col = horizontal
            ? rng.nextInt(_size - word.length + 1)
            : rng.nextInt(_size);

        bool canPlace = true;
        for (int i = 0; i < word.length; i++) {
          final r = horizontal ? row : row + i;
          final c = horizontal ? col + i : col;
          if (grid[r][c] != '' && grid[r][c] != word[i]) {
            canPlace = false;
            break;
          }
        }
        if (canPlace) {
          for (int i = 0; i < word.length; i++) {
            grid[horizontal ? row : row + i][horizontal ? col + i : col] =
                word[i];
          }
          placed = true;
        }
      }
    }

    const fill = 'AEIOUAEIOBCDFGHJLMNPRSTVZ';
    for (int r = 0; r < _size; r++) {
      for (int c = 0; c < _size; c++) {
        if (grid[r][c] == '') {
          grid[r][c] = fill[rng.nextInt(fill.length)];
        }
      }
    }
    return grid;
  }

  void _onCellTap(int row, int col) {
    if (_foundCells.contains(_key(row, col))) return;

    if (_firstCell == null) {
      setState(() {
        _firstCell = _key(row, col);
        _selection
          ..clear()
          ..add(_firstCell!);
      });
      return;
    }

    final parts = _firstCell!.split(',');
    final fr = int.parse(parts[0]);
    final fc = int.parse(parts[1]);

    if (fr == row && fc == col) {
      setState(() {
        _firstCell = null;
        _selection.clear();
      });
      return;
    }

    if (fr != row && fc != col) {
      setState(() {
        _firstCell = _key(row, col);
        _selection
          ..clear()
          ..add(_firstCell!);
      });
      return;
    }

    final cells = <String>[];
    if (fr == row) {
      final lo = min(fc, col);
      final hi = max(fc, col);
      for (int c = lo; c <= hi; c++) { cells.add(_key(row, c)); }
    } else {
      final lo = min(fr, row);
      final hi = max(fr, row);
      for (int r = lo; r <= hi; r++) { cells.add(_key(r, col)); }
    }

    final forward = cells.map((k) {
      final p = k.split(',');
      return _grid[int.parse(p[0])][int.parse(p[1])];
    }).join();
    final backward = forward.split('').reversed.join();

    for (final gw in _words) {
      if (!_foundWords.contains(gw.word) &&
          (forward == gw.word || backward == gw.word)) {
        setState(() {
          _foundWords.add(gw.word);
          _foundCells.addAll(cells);
          _firstCell = null;
          _selection.clear();
          _score += 20;
          if (_foundWords.length == _words.length) _showCelebration = true;
        });
        return;
      }
    }

    setState(() {
      _selection
        ..clear()
        ..addAll(cells);
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted && _firstCell != null) {
        setState(() {
          _firstCell = null;
          _selection.clear();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213e),
        foregroundColor: Colors.white,
        title: Text(
          '🔤 Sopa de Letras',
          style: GoogleFonts.baloo2(fontWeight: FontWeight.w700),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '⭐ $_score pts',
                style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _buildWordChips(),
                const SizedBox(height: 12),
                Expanded(child: _buildGridWidget()),
                const SizedBox(height: 8),
                Text(
                  '${_foundWords.length} de ${_words.length} palabras encontradas',
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          if (_showCelebration)
            CelebrationOverlay(
              message: '¡Encontraste todas las palabras!\n+$_score puntos',
              stars: 3,
              onComplete: () {
                setState(() => _showCelebration = false);
                Navigator.pop(context, _score);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildWordChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: _words.map((gw) {
        final found = _foundWords.contains(gw.word);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: found
                ? Colors.greenAccent.withAlpha(50)
                : Colors.white.withAlpha(20),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: found ? Colors.greenAccent : Colors.white30,
              width: 1.5,
            ),
          ),
          child: Text(
            '${gw.emoji} ${gw.word}',
            style: TextStyle(
              color: found ? Colors.greenAccent : Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              decoration: found ? TextDecoration.lineThrough : null,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGridWidget() {
    return LayoutBuilder(builder: (ctx, constraints) {
      final cellSize = min(
            constraints.maxWidth / _size,
            constraints.maxHeight / _size,
          ) -
          2.0;
      final gridPx = cellSize * _size + 4;
      return Center(
        child: SizedBox(
          width: gridPx,
          height: gridPx,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _size,
            ),
            itemCount: _size * _size,
            itemBuilder: (_, index) {
              final r = index ~/ _size;
              final c = index % _size;
              final k = _key(r, c);
              final isFound = _foundCells.contains(k);
              final isSelected = _selection.contains(k);
              final isFirst = _firstCell == k;
              return GestureDetector(
                onTap: () => _onCellTap(r, c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: isFound
                        ? Colors.greenAccent.withAlpha(60)
                        : isFirst
                            ? Colors.amber.withAlpha(80)
                            : isSelected
                                ? Colors.orangeAccent.withAlpha(60)
                                : Colors.white.withAlpha(12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isFound
                          ? Colors.greenAccent.withAlpha(180)
                          : isFirst
                              ? Colors.amber
                              : isSelected
                                  ? Colors.orangeAccent.withAlpha(180)
                                  : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _grid[r][c],
                      style: TextStyle(
                        color: isFound
                            ? Colors.greenAccent
                            : isSelected || isFirst
                                ? Colors.amber
                                : Colors.white70,
                        fontSize: (cellSize * 0.42).clamp(11.0, 18.0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }
}
