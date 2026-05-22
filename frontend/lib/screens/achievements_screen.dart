import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/bubbles_background.dart';
import '../theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AchievementsScreen extends StatefulWidget {
  final int estudianteId;
  const AchievementsScreen({super.key, required this.estudianteId});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> logros = [];
  List<dynamic> misInsignias = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final fetchedLogros = await _apiService.getLogros();
      final fetchedEstudiante = await _apiService.getEstudiante(widget.estudianteId);
      setState(() {
        logros = fetchedLogros;
        misInsignias = fetchedEstudiante['insignias'];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  bool _tieneInsignia(int logroId) {
    return misInsignias.any((insignia) => insignia['logro']['id'] == logroId);
  }

  @override
  Widget build(BuildContext context) {
    return BubblesBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.texto),
          title: Text(
            'Mis Medallas',
            style: GoogleFonts.baloo2(color: AppColors.texto, fontWeight: FontWeight.bold),
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : GridView.builder(
                padding: const EdgeInsets.all(24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                ),
                itemCount: logros.length,
                itemBuilder: (context, index) {
                  final logro = logros[index];
                  final obtenido = _tieneInsignia(logro['id']);
                  
                  return _LogroBadge(logro: logro, obtenido: obtenido);
                },
              ),
      ),
    );
  }
}

class _LogroBadge extends StatelessWidget {
  final dynamic logro;
  final bool obtenido;

  const _LogroBadge({required this.logro, required this.obtenido});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: obtenido ? 1.0 : 0.4,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: obtenido ? AppColors.amarillo : Colors.transparent,
            width: 3,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              logro['icono'],
              style: const TextStyle(fontSize: 50),
            ),
            const SizedBox(height: 12),
            Text(
              logro['nombre'],
              textAlign: TextAlign.center,
              style: GoogleFonts.baloo2(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.texto, height: 1.1),
            ),
            if (!obtenido)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                child: Text(
                  '${logro['puntos_requeridos']} pts',
                  style: const TextStyle(fontSize: 12, color: AppColors.gris, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
