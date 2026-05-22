import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import '../theme/app_colors.dart';

class RankingScreen extends StatefulWidget {
  final int estudianteId;
  final int estudianteEdad;

  const RankingScreen({
    super.key,
    required this.estudianteId,
    required this.estudianteEdad,
  });

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _api = ApiService();
  List<dynamic> _rankingGlobal = [];
  List<dynamic> _rankingEdad = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRanking();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRanking() async {
    final token = await SessionService.getToken();
    final results = await Future.wait([
      _api.getRanking(token: token),
      _api.getRanking(edad: widget.estudianteEdad, token: token),
    ]);
    setState(() {
      _rankingGlobal = results[0];
      _rankingEdad = results[1];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: NestedScrollView(
        headerSliverBuilder: (ctx, inner) => [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppColors.headerGradientEnd,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2980B9), Color(0xFF6DD5FA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 48),
                      Text('🏆', style: TextStyle(fontSize: 56)),
                      Text(
                        'Ranking',
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              tabs: [
                const Tab(text: 'Global'),
                Tab(text: 'Mis ${widget.estudianteEdad} años'),
              ],
            ),
          ),
        ],
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.azul))
            : TabBarView(
                controller: _tabController,
                children: [
                  _RankingList(
                    students: _rankingGlobal,
                    myId: widget.estudianteId,
                  ),
                  _RankingList(
                    students: _rankingEdad,
                    myId: widget.estudianteId,
                  ),
                ],
              ),
      ),
    );
  }
}

class _RankingList extends StatelessWidget {
  final List<dynamic> students;
  final int myId;

  const _RankingList({required this.students, required this.myId});

  @override
  Widget build(BuildContext context) {
    if (students.isEmpty) {
      return const Center(child: Text('¡Sé el primero en el ranking! 🚀'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: students.length,
      itemBuilder: (ctx, i) {
        final s = students[i];
        final isMe = s['id'] == myId;
        final pos = i + 1;

        return _StudentTile(
          position: pos,
          student: s,
          isMe: isMe,
        );
      },
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

  static const _medalEmoji = ['🥇', '🥈', '🥉'];

  String get _posLabel =>
      position <= 3 ? _medalEmoji[position - 1] : '$position';

  @override
  Widget build(BuildContext context) {
    final nombre = student['nombre'] as String? ?? '?';
    final puntos = student['puntos'] as int? ?? 0;
    final racha = student['racha_actual'] as int? ?? 0;
    final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: isMe
            ? const LinearGradient(
                colors: [Color(0xFF2980B9), Color(0xFF6DD5FA)],
              )
            : null,
        color: isMe ? null : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isMe
                ? const Color(0x552980B9)
                : Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 36,
              child: Text(
                _posLabel,
                style: TextStyle(
                  fontSize: position <= 3 ? 24 : 18,
                  fontWeight: FontWeight.bold,
                  color: isMe ? Colors.white : AppColors.texto,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 22,
              backgroundColor: isMe
                  ? Colors.white.withAlpha(77)
                  : AppColors.azul.withAlpha(30),
              child: Text(
                inicial,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isMe ? Colors.white : AppColors.azulOscuro,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        title: Text(
          nombre,
          style: GoogleFonts.baloo2(
            fontWeight: FontWeight.bold,
            color: isMe ? Colors.white : AppColors.texto,
            fontSize: 16,
          ),
        ),
        subtitle: racha > 0
            ? Text(
                '🔥 Racha: $racha días',
                style: TextStyle(
                  color: isMe ? Colors.white70 : AppColors.gris,
                  fontSize: 12,
                ),
              )
            : null,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isMe ? Colors.white.withAlpha(51) : AppColors.amarillo.withAlpha(51),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '⭐ $puntos',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: isMe ? Colors.white : AppColors.naranjaOscuro,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
