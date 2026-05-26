import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import 'settings_screen.dart';

class RankingScreen extends StatefulWidget {
  final Map<String, dynamic> session;
  const RankingScreen({super.key, required this.session});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _rankingGlobal = [];
  List<dynamic> _rankingEdad = [];
  bool _loading = true;

  int get _miId => (widget.session['id'] as num?)?.toInt() ?? -1;
  int get _miEdad => (widget.session['edad'] as num?)?.toInt() ?? 5;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void didUpdateWidget(covariant RankingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Verificar si los puntos o el ID cambiaron (indicativo de refresco de sesión)
    if (oldWidget.session['puntos'] != widget.session['puntos'] || 
        _rankingGlobal.isEmpty) {
      _load();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final token = await SessionService.getToken();
    final results = await Future.wait([
      ApiService().getRanking(token: token),
      ApiService().getRanking(edad: _miEdad, token: token),
    ]);
    if (mounted) {
      setState(() {
        _rankingGlobal = results[0];
        _rankingEdad = results[1];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, _) => [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.rosaOscuro,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_rounded, color: Colors.white),
                tooltip: 'Configuración',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SettingsScreen(session: widget.session),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.gradientePrimario),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 8),
                      const Text('🏆', style: TextStyle(fontSize: 56)),
                      const SizedBox(height: 8),
                      Text(
                        'Ranking',
                        style: GoogleFonts.baloo2(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Top lectores de V&E Academy',
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          color: Colors.white.withAlpha(210),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle: GoogleFonts.baloo2(fontSize: 14, fontWeight: FontWeight.w700),
              tabs: [
                const Tab(text: 'Global'),
                Tab(text: '$_miEdad años'),
              ],
            ),
          ),
        ],
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.rosaOscuro))
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _RankingList(students: _rankingGlobal, myId: _miId, onRefresh: _load),
                      _RankingList(students: _rankingEdad, myId: _miId, onRefresh: _load),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _RankingList extends StatelessWidget {
  final List<dynamic> students;
  final int myId;
  final Future<void> Function() onRefresh;
  const _RankingList({required this.students, required this.myId, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (students.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🚀', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text('¡Sé el primero!',
                      style: GoogleFonts.baloo2(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.texto)),
                  const SizedBox(height: 8),
                  Text('Completa actividades para aparecer aquí',
                      style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textoSuave),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.rosaOscuro,
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: students.length,
        itemBuilder: (ctx, i) => _StudentTile(
          position: i + 1,
          student: students[i],
          isMe: (students[i]['id'] as int?) == myId,
        ),
      ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  final int position;
  final dynamic student;
  final bool isMe;

  const _StudentTile({
    required this.position,
    required this.student,
    required this.isMe,
  });

  static const _medals = ['🥇', '🥈', '🥉'];

  @override
  Widget build(BuildContext context) {
    final nombre = student['nombre'] as String? ?? '?';
    final puntos = (student['puntos'] as num?)?.toInt() ?? 0;
    final racha = (student['racha_actual'] as num?)?.toInt() ?? 0;
    final avatarEmoji = student['avatar_emoji'] as String? ?? '🐼';
    final isTop3 = position <= 3;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: isMe ? AppColors.gradientePrimario : null,
        color: isMe ? null : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: isTop3 && !isMe
            ? Border.all(color: _borderColor(position), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: isMe
                ? AppColors.rosa.withAlpha(120)
                : AppColors.lila.withAlpha(40),
            blurRadius: isMe ? 14 : 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Posición / Medalla
            SizedBox(
              width: 40,
              child: Text(
                isTop3 ? _medals[position - 1] : '$position',
                style: TextStyle(
                  fontSize: isTop3 ? 26 : 16,
                  fontWeight: FontWeight.w900,
                  color: isMe ? Colors.white : AppColors.texto,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 10),
            // Avatar emoji
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isMe
                    ? Colors.white.withAlpha(60)
                    : AppColors.fondoSecundario,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: ClipOval(
                  child: Image.asset(
                    'assets/avatars/${student['avatar'] as String? ?? 'panda'}.png',
                    width: 44, height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Text(
                      student['avatar_emoji'] as String? ?? '🐼',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Nombre + racha
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isMe ? '$nombre  ✨' : nombre,
                    style: GoogleFonts.baloo2(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isMe ? Colors.white : AppColors.texto,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (racha > 0)
                    Text(
                      '🔥 $racha días de racha',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: isMe ? Colors.white70 : AppColors.textoSuave,
                      ),
                    ),
                ],
              ),
            ),
            // Puntos
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isMe
                    ? Colors.white.withAlpha(60)
                    : AppColors.amarillo.withAlpha(180),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '⭐ $puntos',
                style: GoogleFonts.baloo2(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: isMe ? Colors.white : AppColors.amarilloOscuro,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _borderColor(int pos) {
    switch (pos) {
      case 1: return const Color(0xFFFFD700);
      case 2: return const Color(0xFFC0C0C0);
      case 3: return const Color(0xFFCD7F32);
      default: return Colors.transparent;
    }
  }
}
