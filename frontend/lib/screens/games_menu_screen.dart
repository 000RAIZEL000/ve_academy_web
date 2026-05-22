import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/game_data.dart';
import '../models/libro.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import '../theme/app_colors.dart';
import '../widgets/book_cover.dart';
import 'games/word_search_screen.dart';
import 'games/complete_word_screen.dart';
import 'games/order_sentence_screen.dart';
import 'games/find_image_screen.dart';
import 'games/memory_screen.dart';

class GamesMenuScreen extends StatefulWidget {
  final Libro libro;
  final int estudianteId;
  final int estudianteEdad;

  const GamesMenuScreen({
    super.key,
    required this.libro,
    required this.estudianteId,
    required this.estudianteEdad,
  });

  @override
  State<GamesMenuScreen> createState() => _GamesMenuScreenState();
}

class _GamesMenuScreenState extends State<GamesMenuScreen> {
  BookGameData? _gameData;
  bool _loading = true;
  String? _error;
  int _totalScore = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final token = await SessionService.getToken();
      final data = await ApiService().getJuegos(widget.libro.slug, token: token);
      if (mounted) setState(() { _gameData = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _error = 'No se pudo cargar los juegos'; _loading = false; });
    }
  }

  static const _games = [
    _GameInfo(
      emoji: '🔤',
      title: 'Sopa de Letras',
      desc: 'Encuentra las palabras del cuento',
      colors: [Color(0xFF1a1a2e), Color(0xFF16213e)],
    ),
    _GameInfo(
      emoji: '🅰️',
      title: 'Completa la Palabra',
      desc: '¿Qué letra falta?',
      colors: [Color(0xFF0f3460), Color(0xFF533483)],
    ),
    _GameInfo(
      emoji: '📝',
      title: 'Ordena la Oración',
      desc: 'Pon las palabras en orden',
      colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
    ),
    _GameInfo(
      emoji: '🖼️',
      title: 'Encuentra la Imagen',
      desc: 'Toca la imagen correcta',
      colors: [Color(0xFF2980B9), Color(0xFF6DD5FA)],
    ),
    _GameInfo(
      emoji: '🃏',
      title: 'Memoria de Palabras',
      desc: 'Empareja palabras e imágenes',
      colors: [Color(0xFF4a148c), Color(0xFFE040FB)],
    ),
  ];

  void _openGame(int index) {
    final data = _gameData;
    if (data == null) return;

    Widget screen;
    switch (index) {
      case 0:
        screen = WordSearchScreen(
          libro: widget.libro,
          gameData: data,
          estudianteId: widget.estudianteId,
          estudianteEdad: widget.estudianteEdad,
        );
      case 1:
        screen = CompleteWordScreen(
          libro: widget.libro,
          gameData: data,
          estudianteId: widget.estudianteId,
          estudianteEdad: widget.estudianteEdad,
        );
      case 2:
        screen = OrderSentenceScreen(
          libro: widget.libro,
          gameData: data,
          estudianteId: widget.estudianteId,
          estudianteEdad: widget.estudianteEdad,
        );
      case 3:
        screen = FindImageScreen(
          libro: widget.libro,
          gameData: data,
          estudianteId: widget.estudianteId,
          estudianteEdad: widget.estudianteEdad,
        );
      default:
        screen = MemoryScreen(
          libro: widget.libro,
          gameData: data,
          estudianteId: widget.estudianteId,
          estudianteEdad: widget.estudianteEdad,
        );
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    ).then((score) {
      if (score is int && score > 0) {
        setState(() => _totalScore += score);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: const Color(0xFF16213e),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                '🎮 Mini Juegos',
                style: GoogleFonts.baloo2(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  BookCoverWidget(
                    portadaUrl: widget.libro.portadaUrl,
                    titulo: widget.libro.titulo,
                    index: widget.libro.id % 8,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withAlpha(100), Colors.black.withAlpha(180)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.libro.titulo,
                    style: GoogleFonts.baloo2(
                      fontSize: 16,
                      color: AppColors.gris,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '¡Juega y aprende con este cuento! 🌟',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: AppColors.gris,
                    ),
                  ),
                  if (_totalScore > 0) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber, width: 1.5),
                      ),
                      child: Text(
                        '⭐ Puntos esta sesión: $_totalScore',
                        style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('😕', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: AppColors.gris)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() { _loading = true; _error = null; });
                        _load();
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _GameTile(
                    info: _games[i],
                    index: i,
                    onTap: () => _openGame(i),
                  ),
                  childCount: _games.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GameInfo {
  final String emoji;
  final String title;
  final String desc;
  final List<Color> colors;
  const _GameInfo({
    required this.emoji,
    required this.title,
    required this.desc,
    required this.colors,
  });
}

class _GameTile extends StatefulWidget {
  final _GameInfo info;
  final int index;
  final VoidCallback onTap;

  const _GameTile({
    required this.info,
    required this.index,
    required this.onTap,
  });

  @override
  State<_GameTile> createState() => _GameTileState();
}

class _GameTileState extends State<_GameTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scale = Tween(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            height: 88,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.info.colors,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: widget.info.colors.last.withAlpha(80),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 20),
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      widget.info.emoji,
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.info.title,
                        style: GoogleFonts.baloo2(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        widget.info.desc,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: Colors.white54, size: 28),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
