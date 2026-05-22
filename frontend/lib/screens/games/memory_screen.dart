import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../services/api_service.dart';
import '../../models/game_data.dart';

class MemoryScreen extends StatefulWidget {
  final String slug;
  final Map<String, dynamic> session;
  const MemoryScreen({super.key, required this.slug, required this.session});

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  BookGameData? _gameData;
  bool _loading = true;
  List<_MemCard> _cards = [];
  int? _firstFlipped;
  bool _blocking = false;
  int _moves = 0;
  int _pares = 0;
  bool _completado = false;

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
        _iniciarJuego(data);
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _iniciarJuego(BookGameData data) {
    final palabras = data.palabras.take(6).toList();
    final pairs = <_MemCard>[];
    for (var i = 0; i < palabras.length; i++) {
      pairs.add(_MemCard(id: i * 2, text: palabras[i].word, emoji: palabras[i].emoji, pairId: i));
      pairs.add(_MemCard(id: i * 2 + 1, text: palabras[i].word, emoji: palabras[i].emoji, pairId: i, isEmoji: true));
    }
    pairs.shuffle(Random());
    _cards = pairs;
    _pares = 0;
    _moves = 0;
    _completado = false;
  }

  void _voltear(int idx) {
    if (_blocking) return;
    final card = _cards[idx];
    if (card.revealed || card.matched) return;

    setState(() => _cards[idx] = card.copyWith(revealed: true));

    if (_firstFlipped == null) {
      _firstFlipped = idx;
    } else {
      final first = _cards[_firstFlipped!];
      _moves++;
      if (first.pairId == card.pairId) {
        setState(() {
          _cards[_firstFlipped!] = first.copyWith(matched: true);
          _cards[idx] = card.copyWith(matched: true);
          _pares++;
          _completado = _pares == _cards.length ~/ 2;
        });
        _firstFlipped = null;
      } else {
        _blocking = true;
        _firstFlipped = null;
        Future.delayed(const Duration(milliseconds: 900), () {
          if (!mounted) return;
          setState(() {
            _cards[_firstFlipped ?? idx] = first.copyWith(revealed: false);
            _cards[idx] = card.copyWith(revealed: false);
            _blocking = false;
          });
        });
      }
    }
  }

  void _reiniciar() {
    if (_gameData != null) setState(() => _iniciarJuego(_gameData!));
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
        title: Text('Memoria 🧠', style: GoogleFonts.baloo2(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.texto)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(icon: const Icon(Icons.refresh_rounded, color: AppColors.rosaOscuro), onPressed: _reiniciar),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.rosaOscuro))
          : Column(
              children: [
                _buildStats(),
                Expanded(
                  child: _completado ? _buildCompletado() : _buildGrid(),
                ),
              ],
            ),
    );
  }

  Widget _buildStats() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _statChip('🎯', '$_pares/${_cards.length ~/ 2}', 'Pares'),
        _statChip('👆', '$_moves', 'Movimientos'),
      ]),
    );
  }

  Widget _statChip(String emoji, String value, String label) => Column(mainAxisSize: MainAxisSize.min, children: [
    Text(emoji, style: const TextStyle(fontSize: 20)),
    Text(value, style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.texto)),
    Text(label, style: GoogleFonts.nunito(fontSize: 11, color: AppColors.textoSuave)),
  ]);

  Widget _buildGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.9,
        ),
        itemCount: _cards.length,
        itemBuilder: (_, i) {
          final card = _cards[i];
          return GestureDetector(
            onTap: () => _voltear(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: card.matched
                    ? AppColors.exito.withOpacity(0.3)
                    : card.revealed
                        ? Colors.white
                        : AppColors.rosa.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: card.matched ? AppColors.exitoTexto : (card.revealed ? AppColors.lilaOscuro : AppColors.rosa),
                  width: 2,
                ),
                boxShadow: [AppColors.sombraSuave],
              ),
              child: Center(
                child: card.revealed || card.matched
                    ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(card.isEmoji ? card.emoji : '📝', style: const TextStyle(fontSize: 30)),
                        const SizedBox(height: 4),
                        if (!card.isEmoji)
                          Text(card.text, style: GoogleFonts.baloo2(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.texto),
                              textAlign: TextAlign.center, maxLines: 2),
                      ])
                    : const Text('❓', style: TextStyle(fontSize: 36)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompletado() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Text('🏆', style: TextStyle(fontSize: 80)),
        const SizedBox(height: 16),
        Text('¡Lo lograste!', style: GoogleFonts.baloo2(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.texto)),
        Text('Completaste en $_moves movimientos', style: GoogleFonts.nunito(fontSize: 16, color: AppColors.textoSuave)),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _reiniciar,
          icon: const Icon(Icons.refresh_rounded),
          label: Text('Jugar otra vez', style: GoogleFonts.baloo2(fontSize: 17, fontWeight: FontWeight.w700)),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.rosa, elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Volver a juegos', style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textoSuave)),
        ),
      ]),
    );
  }
}

class _MemCard {
  final int id;
  final String text;
  final String emoji;
  final int pairId;
  final bool isEmoji;
  final bool revealed;
  final bool matched;
  const _MemCard({required this.id, required this.text, required this.emoji, required this.pairId,
      this.isEmoji = false, this.revealed = false, this.matched = false});
  _MemCard copyWith({bool? revealed, bool? matched}) => _MemCard(
      id: id, text: text, emoji: emoji, pairId: pairId, isEmoji: isEmoji,
      revealed: revealed ?? this.revealed, matched: matched ?? this.matched);
}
