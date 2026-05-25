import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';
import '../../models/game_data.dart';

class WordSearchScreen extends StatefulWidget {
  final String slug;
  final Map<String, dynamic> session;
  const WordSearchScreen({super.key, required this.slug, required this.session});

  @override
  State<WordSearchScreen> createState() => _WordSearchScreenState();
}

class _WordSearchScreenState extends State<WordSearchScreen> {
  static const int gridSize = 8;
  List<List<String>> _grid = [];
  List<String> _wordsToFind = [];
  Set<String> _foundWords = {};
  Set<Offset> _foundCells = {};
  List<Offset> _selectedCells = [];
  bool _loading = true;
  bool _completado = false;

  @override
  void initState() {
    super.initState();
    _cargarYGenerar();
  }

  Future<void> _cargarYGenerar() async {
    try {
      final token = widget.session['token'] as String?;
      final data = await ApiService().getJuegos(widget.slug, token: token);
      final words = data.palabras.map((p) => p.word).take(4).toList();
      setState(() {
        _wordsToFind = words;
        _generateGrid(words);
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _generateGrid(List<String> words) {
    _grid = List.generate(gridSize, (_) => List.generate(gridSize, (_) => ''));
    final random = Random();

    for (var word in words) {
      bool placed = false;
      int attempts = 0;
      while (!placed && attempts < 50) {
        attempts++;
        int row = random.nextInt(gridSize);
        int col = random.nextInt(gridSize);
        int dRow = random.nextInt(2); // 0: horizontal, 1: vertical
        int dCol = dRow == 0 ? 1 : 0;

        if (row + dRow * word.length <= gridSize && 
            col + dCol * word.length <= gridSize) {
          bool canPlace = true;
          for (int i = 0; i < word.length; i++) {
            String cell = _grid[row + i * dRow][col + i * dCol];
            if (cell != '' && cell != word[i]) {
              canPlace = false;
              break;
            }
          }

          if (canPlace) {
            for (int i = 0; i < word.length; i++) {
              _grid[row + i * dRow][col + i * dCol] = word[i];
            }
            placed = true;
          }
        }
      }
    }

    const letters = 'ABCDE FGHIK LMNOP QRSTU VWXYZ';
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (_grid[r][c] == '') {
          _grid[r][c] = letters[random.nextInt(letters.length)].trim();
          if (_grid[r][c] == '') _grid[r][c] = 'A';
        }
      }
    }
  }

  void _handlePan(Offset localPos, double width) {
    if (_completado) return;
    
    // El padding del GridView es 10. El tamaño útil es width - 20 (paddings)
    final cellSize = (width - 20) / gridSize;
    int col = (localPos.dx - 10) ~/ cellSize;
    int row = (localPos.dy - 10) ~/ cellSize;

    if (row >= 0 && row < gridSize && col >= 0 && col < gridSize) {
      final offset = Offset(row.toDouble(), col.toDouble());
      if (!_selectedCells.contains(offset)) {
        setState(() {
          _selectedCells.add(offset);
        });
      }
    }
  }

  void _checkSelection() {
    String selection = _selectedCells.map((o) => _grid[o.dx.toInt()][o.dy.toInt()]).join();
    String reversedSelection = selection.split('').reversed.join();

    bool wordFound = false;
    for (var word in _wordsToFind) {
      if (!_foundWords.contains(word) && (selection == word || reversedSelection == word)) {
        setState(() {
          _foundWords.add(word);
          _foundCells.addAll(_selectedCells);
          _selectedCells = [];
          if (_foundWords.length == _wordsToFind.length) {
            _completado = true;
            _notificarExito();
          }
        });
        wordFound = true;
        break;
      }
    }
    
    if (!wordFound && _selectedCells.isNotEmpty) {
      setState(() {
        _selectedCells = [];
      });
    }
  }

  Future<void> _notificarExito() async {
    try {
      final token = widget.session['token'] as String?;
      await ApiService().completarActividad(widget.slug, 'juego_sopa', token: token);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.texto), 
            onPressed: () => Navigator.pop(context)),
        title: Text('Sopa de Letras 🔍', 
            style: GoogleFonts.baloo2(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.texto)),
        centerTitle: true,
      ),
      body: _loading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.rosaOscuro))
        : Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: _completado ? _buildCompletado() : _buildJuego(),
            ),
          ),
    );
  }

  Widget _buildJuego() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Wrap(
          spacing: 10, runSpacing: 10,
          children: _wordsToFind.map((w) {
            final found = _foundWords.contains(w);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: found ? AppColors.exito.withOpacity(0.3) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: found ? AppColors.exitoTexto : AppColors.lila, width: 2),
                boxShadow: found ? [] : [AppColors.sombraSuave],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (found) ...[
                    const Icon(Icons.check_circle_rounded, color: AppColors.exitoTexto, size: 16),
                    const SizedBox(width: 6),
                  ],
                  Text(w, style: GoogleFonts.baloo2(
                    fontSize: 14, fontWeight: FontWeight.w800, 
                    color: found ? AppColors.exitoTexto : AppColors.texto,
                    decoration: found ? TextDecoration.lineThrough : null,
                  )),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 30),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [AppColors.sombraSuave],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      onPanStart: (details) => _handlePan(details.localPosition, constraints.maxWidth),
                      onPanUpdate: (details) => _handlePan(details.localPosition, constraints.maxWidth),
                      onPanEnd: (_) => _checkSelection(),
                      child: GridView.builder(
                        padding: const EdgeInsets.all(10),
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gridSize, crossAxisSpacing: 4, mainAxisSpacing: 4,
                        ),
                        itemCount: gridSize * gridSize,
                        itemBuilder: (_, i) {
                          int r = i ~/ gridSize;
                          int c = i % gridSize;
                          bool selected = _selectedCells.contains(Offset(r.toDouble(), c.toDouble()));
                          bool found = _foundCells.contains(Offset(r.toDouble(), c.toDouble()));
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: found 
                                  ? AppColors.exito.withOpacity(0.4) 
                                  : selected 
                                      ? AppColors.celeste.withOpacity(0.5) 
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(found ? 12 : 8),
                              border: found ? Border.all(color: AppColors.exitoTexto, width: 2) : null,
                            ),
                            child: Center(child: Text(_grid[r][c], 
                                style: GoogleFonts.baloo2(
                                  fontSize: 18, 
                                  fontWeight: found ? FontWeight.w900 : FontWeight.w800, 
                                  color: found ? AppColors.exitoTexto : AppColors.texto
                                ))),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('Arrastra para conectar las letras y encontrar las palabras', 
            style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textoSuave), textAlign: TextAlign.center),
        TextButton(onPressed: () => setState(() => _selectedCells = []), 
            child: const Text('Limpiar selección')),
      ]),
    );
  }

  Widget _buildCompletado() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('🔍🏆', style: TextStyle(fontSize: 80)),
      const SizedBox(height: 20),
      Text('¡Enhorabuena!', style: GoogleFonts.baloo2(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.texto)),
      Text('Encontraste todas las palabras', style: GoogleFonts.nunito(fontSize: 18, color: AppColors.textoSuave)),
      const SizedBox(height: 32),
      ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.celeste, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
        onPressed: () => Navigator.pop(context), 
        child: Text('Volver', style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.w700)),
      ),
    ]));
  }
}
