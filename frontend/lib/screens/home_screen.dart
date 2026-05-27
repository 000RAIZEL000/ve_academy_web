import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> session;
  final void Function(int index) onNavigate;
  final void Function(Map<String, dynamic> session)? onSessionUpdated;
  const HomeScreen({super.key, required this.session, required this.onNavigate, this.onSessionUpdated});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  String get _nombre => widget.session['nombre'] as String? ?? 'Explorador';
  int get _puntos => (widget.session['puntos'] as num?)?.toInt() ?? 0;
  int get _racha => (widget.session['racha_actual'] as num?)?.toInt() ?? 0;
  String get _avatar => widget.session['avatar'] as String? ?? 'panda';

  static const _avatarEmojis = {
    'conejo': '🐰', 'gato': '🐱', 'lechuza': '🦉', 'leon': '🦁',
    'oso': '🐻', 'panda': '🐼', 'perico': '🦜', 'tigre': '🐯', 'zorro': '🦊',
  };

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn));
    _slide =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
            CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
    _refreshProfile();
  }

  Future<void> _refreshProfile() async {
    try {
      final token = widget.session['token'] as String?;
      if (token == null) return;
      final data = await ApiService().verifyToken(token);
      final saved = await SessionService.getSession();
      final localPuntos = (saved?['puntos'] as num?)?.toInt() ?? 0;
      final serverPuntos = (data['puntos'] as num?)?.toInt() ?? 0;
      final mejorPuntos = localPuntos > serverPuntos ? localPuntos : serverPuntos;
      if (mejorPuntos > serverPuntos) await SessionService.setPuntos(mejorPuntos);
      final updatedData = Map<String, dynamic>.from(data)..['puntos'] = mejorPuntos;
      if (widget.onSessionUpdated != null) {
        widget.onSessionUpdated!(updatedData);
      }
    } catch (_) {}
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.session['puntos'] != widget.session['puntos']) {
      setState(() {}); // Forzar reconstrucción con nuevos datos del getter _puntos
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return '¡Buenos días';
    if (h < 18) return '¡Buenas tardes';
    return '¡Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradienteHome),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                        horizontal: w > 700 ? 40 : 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildIllustration(),
                        const SizedBox(height: 28),
                        _buildWelcomeCard(),
                        const SizedBox(height: 24),
                        _buildStatsRow(),
                        const SizedBox(height: 28),
                        _buildQuickActions(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 52, height: 52,
          decoration: const BoxDecoration(
            gradient: AppColors.gradientePrimario,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: ClipOval(
              child: Image.network(
                ApiService.resolveStaticUrl(widget.session['avatar_url'] as String?),
                width: 52, height: 52,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Text(
                  _avatarEmojis[_avatar] ?? '🐼',
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${_greeting()}, $_nombre!',
                  style: GoogleFonts.baloo2(
                      fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.texto)),
              Text('¿Listo para aprender hoy?',
                  style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textoSuave)),
            ],
          ),
        ),
        if (_racha > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.amarillo, Color(0xFFFFE066)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Text('🔥', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Text('$_racha',
                  style: GoogleFonts.baloo2(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF8B6914))),
            ]),
          ),
      ],
    );
  }

  Widget _buildIllustration() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [AppColors.sombraSuave],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _floatingElement('📖', 'Leo', AppColors.rosa.withOpacity(0.15)),
              _floatingElement('⭐', 'Aprendo', AppColors.amarillo.withOpacity(0.25)),
              _floatingElement('🎮', 'Juego', AppColors.celeste.withOpacity(0.2)),
              _floatingElement('🏆', 'Gano', AppColors.lila.withOpacity(0.2)),
            ],
          ),
          const SizedBox(height: 16),
          Text('✨', style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Text('¡El mundo de los libros\nte espera!',
              style: GoogleFonts.baloo2(
                  fontSize: 22, fontWeight: FontWeight.w800,
                  color: AppColors.texto, height: 1.2),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Lee, juega y gana puntos especiales',
              style: GoogleFonts.nunito(fontSize: 15, color: AppColors.textoSuave),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _floatingElement(String emoji, String label, Color bg) {
    return Column(children: [
      Container(
        width: 56, height: 56,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
      ),
      const SizedBox(height: 6),
      Text(label, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.texto)),
    ]);
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.rosa, AppColors.lila],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [AppColors.sombraRosa],
      ),
      child: Column(
        children: [
          Text('¿Comenzamos la aventura?',
              style: GoogleFonts.baloo2(
                  fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.texto),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Cada libro que leas te hace más inteligente y feliz 🌟',
              style: GoogleFonts.nunito(fontSize: 15, color: AppColors.texto.withOpacity(0.8)),
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: () => widget.onNavigate(1),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.rosaOscuro,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                elevation: 0,
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('📚', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Text('¡Empecemos!',
                    style: GoogleFonts.baloo2(fontSize: 20, fontWeight: FontWeight.w800,
                        color: AppColors.rosaOscuro)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(children: [
      Expanded(child: _statCard('⭐', _puntos.toString(), 'Puntos', AppColors.amarillo.withOpacity(0.3), AppColors.amarilloOscuro)),
      const SizedBox(width: 12),
      Expanded(child: _statCard('🔥', '$_racha', 'Días seguidos', AppColors.rosa.withOpacity(0.25), AppColors.rosaOscuro)),
      const SizedBox(width: 12),
      Expanded(child: _statCard('📖', '${1 + (_puntos / 300).floor()}', 'Nivel', AppColors.lila.withOpacity(0.25), AppColors.lilaOscuro)),
    ]);
  }

  Widget _statCard(String emoji, String value, String label, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.baloo2(fontSize: 20, fontWeight: FontWeight.w800, color: textColor)),
        Text(label, style: GoogleFonts.nunito(fontSize: 11, color: AppColors.textoSuave), textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'emoji': '📚', 'label': 'Mis Lecturas', 'sub': 'Leer un cuento', 'idx': 1, 'color': AppColors.rosa},
      {'emoji': '🎮', 'label': 'Minijuegos', 'sub': 'Jugar y aprender', 'idx': 4, 'color': AppColors.celeste},
      {'emoji': '📊', 'label': 'Mi Progreso', 'sub': 'Ver mis logros', 'idx': 2, 'color': AppColors.lila},
      {'emoji': '🛍️', 'label': 'Tienda', 'sub': 'Canjear puntos', 'idx': 3, 'color': AppColors.amarillo},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Acceso Rápido',
            style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.texto)),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.0,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: actions.map((a) {
            final color = a['color'] as Color;
            return GestureDetector(
              onTap: () => widget.onNavigate(a['idx'] as int),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: color.withOpacity(0.5), width: 1.5),
                ),
                child: Row(children: [
                  Text(a['emoji'] as String, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 10),
                  Expanded(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a['label'] as String,
                          style: GoogleFonts.baloo2(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.texto)),
                      Text(a['sub'] as String,
                          style: GoogleFonts.nunito(fontSize: 11, color: AppColors.textoSuave)),
                    ],
                  )),
                ]),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
