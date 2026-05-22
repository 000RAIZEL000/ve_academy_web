import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import '../theme/app_colors.dart';
import '../widgets/bubbles_background.dart';
import 'login_screen.dart';
import 'library_screen.dart';
import 'shop_screen.dart';
import 'achievements_screen.dart';
import 'ranking_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';
import 'history_screen.dart';
import 'coming_soon_screen.dart';

class HomeScreen extends StatefulWidget {
  final int estudianteId;
  final int estudianteEdad;

  const HomeScreen({
    super.key,
    required this.estudianteId,
    required this.estudianteEdad,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _api = ApiService();
  Map<String, dynamic>? _estudiante;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final token = await SessionService.getToken();
      final data = await _api.getEstudiante(widget.estudianteId, token: token);
      setState(() {
        _estudiante = data;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    await SessionService.clearSession();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _navigate(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen))
        .then((_) => _loadData());
  }

  List<_FeatureTile> get _features => [
        _FeatureTile(
          emoji: '📚',
          label: 'Biblioteca',
          colors: AppColors.featureGradients[0],
          available: true,
          onTap: () => _navigate(LibraryScreen(
              estudianteId: widget.estudianteId,
              estudianteEdad: widget.estudianteEdad)),
        ),
        _FeatureTile(
          emoji: '🧩',
          label: 'Quiz',
          colors: AppColors.featureGradients[1],
          available: true,
          onTap: () => _navigate(LibraryScreen(
              estudianteId: widget.estudianteId,
              estudianteEdad: widget.estudianteEdad)),
        ),
        _FeatureTile(
          emoji: '📊',
          label: 'Mi Progreso',
          colors: AppColors.featureGradients[2],
          available: true,
          onTap: () => _navigate(ProgressScreen(
              estudianteId: widget.estudianteId,
              estudianteEdad: widget.estudianteEdad)),
        ),
        _FeatureTile(
          emoji: '🏆',
          label: 'Logros',
          colors: AppColors.featureGradients[3],
          available: true,
          onTap: () => _navigate(
              AchievementsScreen(estudianteId: widget.estudianteId)),
        ),
        _FeatureTile(
          emoji: '🥇',
          label: 'Ranking',
          colors: AppColors.featureGradients[4],
          available: true,
          onTap: () => _navigate(RankingScreen(
              estudianteId: widget.estudianteId,
              estudianteEdad: widget.estudianteEdad)),
        ),
        _FeatureTile(
          emoji: '🎁',
          label: 'Tienda',
          colors: AppColors.featureGradients[5],
          available: true,
          onTap: () =>
              _navigate(ShopScreen(estudianteId: widget.estudianteId)),
        ),
        _FeatureTile(
          emoji: '🔥',
          label: 'Rachas',
          colors: AppColors.featureGradients[6],
          available: true,
          onTap: () =>
              _navigate(ProfileScreen(estudianteId: widget.estudianteId)),
        ),
        _FeatureTile(
          emoji: '👤',
          label: 'Mi Perfil',
          colors: AppColors.featureGradients[7],
          available: true,
          onTap: () =>
              _navigate(ProfileScreen(estudianteId: widget.estudianteId)),
        ),
        _FeatureTile(
          emoji: '👩‍🏫',
          label: 'Panel Docente',
          colors: AppColors.featureGradients[8],
          available: false,
          onTap: () => _navigate(ComingSoonScreen(
              featureName: 'Panel Docente',
              emoji: '👩‍🏫',
              colors: AppColors.featureGradients[8])),
        ),
        _FeatureTile(
          emoji: '📈',
          label: 'Reportes',
          colors: AppColors.featureGradients[9],
          available: false,
          onTap: () => _navigate(ComingSoonScreen(
              featureName: 'Reportes',
              emoji: '📈',
              colors: AppColors.featureGradients[9])),
        ),
        _FeatureTile(
          emoji: '⭐',
          label: 'Niveles',
          colors: AppColors.featureGradients[10],
          available: false,
          onTap: () => _navigate(ComingSoonScreen(
              featureName: 'Niveles',
              emoji: '⭐',
              colors: AppColors.featureGradients[10])),
        ),
        _FeatureTile(
          emoji: '🎧',
          label: 'Modo Escucha',
          colors: AppColors.featureGradients[11],
          available: false,
          onTap: () => _navigate(ComingSoonScreen(
              featureName: 'Modo Escucha',
              emoji: '🎧',
              colors: AppColors.featureGradients[11])),
        ),
        _FeatureTile(
          emoji: '📖',
          label: 'Historial',
          colors: AppColors.featureGradients[12],
          available: true,
          onTap: () =>
              _navigate(HistoryScreen(estudianteId: widget.estudianteId)),
        ),
        _FeatureTile(
          emoji: '🗂️',
          label: 'Gestión',
          colors: AppColors.featureGradients[13],
          available: false,
          onTap: () => _navigate(ComingSoonScreen(
              featureName: 'Gestión de Contenido',
              emoji: '🗂️',
              colors: AppColors.featureGradients[13])),
        ),
        _FeatureTile(
          emoji: '🔐',
          label: 'Admin',
          colors: AppColors.featureGradients[14],
          available: false,
          onTap: () => _navigate(ComingSoonScreen(
              featureName: 'Administración',
              emoji: '🔐',
              colors: AppColors.featureGradients[14])),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final nombre = _estudiante?['nombre'] as String? ?? '...';
    final puntos = _estudiante?['puntos'] as int? ?? 0;
    final racha = _estudiante?['racha_actual'] as int? ?? 0;

    return BubblesBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 140,
              backgroundColor: AppColors.headerGradientEnd,
              foregroundColor: Colors.white,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.exit_to_app, color: Colors.white70),
                  onPressed: _handleLogout,
                  tooltip: 'Salir',
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.headerGradientStart,
                        AppColors.headerGradientEnd
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border(
                      bottom: BorderSide(color: AppColors.verde, width: 3),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Text(
                                '🎓',
                                style: const TextStyle(fontSize: 28),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '¡Hola, $nombre! 👋',
                                      style: GoogleFonts.baloo2(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '¿Qué quieres aprender hoy?',
                                      style: const TextStyle(
                                        color: Colors.white60,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _isLoading
                                  ? const SizedBox.shrink()
                                  : Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        _HeaderBadge('⭐ $puntos'),
                                        const SizedBox(height: 4),
                                        if (racha > 0)
                                          _HeaderBadge('🔥 $racha días'),
                                      ],
                                    ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.82,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _FeatureTileWidget(tile: _features[i]),
                  childCount: _features.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  final String text;
  const _HeaderBadge(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(60)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _FeatureTile {
  final String emoji;
  final String label;
  final List<Color> colors;
  final bool available;
  final VoidCallback onTap;

  const _FeatureTile({
    required this.emoji,
    required this.label,
    required this.colors,
    required this.available,
    required this.onTap,
  });
}

class _FeatureTileWidget extends StatefulWidget {
  final _FeatureTile tile;

  const _FeatureTileWidget({required this.tile});

  @override
  State<_FeatureTileWidget> createState() => _FeatureTileWidgetState();
}

class _FeatureTileWidgetState extends State<_FeatureTileWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.93,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _scaleController;
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _onTapDown(TapDownDetails _) async {
    await _scaleController.reverse();
  }

  Future<void> _onTapUp(TapUpDetails _) async {
    await _scaleController.forward();
    widget.tile.onTap();
  }

  void _onTapCancel() => _scaleController.forward();

  @override
  Widget build(BuildContext context) {
    final tile = widget.tile;
    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (ctx, child) => Transform.scale(
        scale: _scaleAnim.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: tile.available
                  ? tile.colors
                  : [
                      tile.colors[0].withAlpha(180),
                      tile.colors[1].withAlpha(180),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: tile.colors[0].withAlpha(tile.available ? 100 : 50),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative circle
              Positioned(
                top: -12,
                right: -12,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0x22FFFFFF),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      tile.emoji,
                      style: const TextStyle(fontSize: 36),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      tile.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.baloo2(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.1,
                        shadows: const [
                          Shadow(blurRadius: 4, color: Colors.black38),
                        ],
                      ),
                    ),
                    if (!tile.available) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(51),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Pronto',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
