import 'package:flutter/material.dart';
import '../services/api_service.dart';

class BookCoverWidget extends StatelessWidget {
  final String portadaUrl;
  final String titulo;
  final int index;

  const BookCoverWidget({
    super.key,
    required this.portadaUrl,
    required this.titulo,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    if (portadaUrl.isEmpty) {
      return _GeneratedCover(titulo: titulo, index: index);
    }
    if (portadaUrl.startsWith('assets/')) {
      return Image.asset(
        portadaUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (ctx, err, st) => _GeneratedCover(titulo: titulo, index: index),
      );
    }
    return Image.network(
      portadaUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (ctx, child, progress) {
        if (progress == null) return child;
        return _GeneratedCover(titulo: titulo, index: index);
      },
      errorBuilder: (ctx, err, st) => _GeneratedCover(titulo: titulo, index: index),
    );
  }
}

class _GeneratedCover extends StatelessWidget {
  final String titulo;
  final int index;

  const _GeneratedCover({required this.titulo, required this.index});

  static const _gradients = [
    [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
    [Color(0xFFf7971e), Color(0xFFffd200)],
    [Color(0xFF11998e), Color(0xFF38ef7d)],
    [Color(0xFFf6d365), Color(0xFFfda085)],
    [Color(0xFF2980B9), Color(0xFF6DD5FA)],
    [Color(0xFFE91E8C), Color(0xFFfc466b)],
    [Color(0xFF43C6AC), Color(0xFF191654)],
    [Color(0xFFfc4a1a), Color(0xFFf7b733)],
  ];

  static const _emojiMap = {
    'hormiga': '🐜',
    'pajaro': '🐦',
    'pájaro': '🐦',
    'arbol': '🌳',
    'árbol': '🌳',
    'sol': '☀️',
    'luna': '🌙',
    'ballena': '🐋',
    'leon': '🦁',
    'león': '🦁',
    'raton': '🐭',
    'ratón': '🐭',
    'liebre': '🐰',
    'tortuga': '🐢',
    'zorro': '🦊',
  };

  String get _emoji {
    final lower = titulo.toLowerCase();
    for (final entry in _emojiMap.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return '📖';
  }

  List<Color> get _gradient => _gradients[index % _gradients.length];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -24,
            right: -24,
            child: Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: Color(0x22FFFFFF),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -18,
            left: -18,
            child: Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: Color(0x22FFFFFF),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_emoji, style: const TextStyle(fontSize: 60)),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  titulo,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    shadows: [Shadow(blurRadius: 6, color: Colors.black45)],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
