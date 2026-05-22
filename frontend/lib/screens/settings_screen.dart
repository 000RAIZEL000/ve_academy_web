import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../services/session_service.dart';

class SettingsScreen extends StatefulWidget {
  final Map<String, dynamic> session;
  const SettingsScreen({super.key, required this.session});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _sonidoActivado = true;
  bool _musicaActivada = true;
  bool _notificaciones = true;
  double _tamanoTexto = 1.0;
  bool _modoAltoContraste = false;

  @override
  void initState() {
    super.initState();
    _cargarPreferencias();
  }

  Future<void> _cargarPreferencias() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _sonidoActivado = p.getBool('sonido') ?? true;
      _musicaActivada = p.getBool('musica') ?? true;
      _notificaciones = p.getBool('notificaciones') ?? true;
      _tamanoTexto = p.getDouble('tamano_texto') ?? 1.0;
      _modoAltoContraste = p.getBool('alto_contraste') ?? false;
    });
  }

  Future<void> _guardar(String key, dynamic value) async {
    final p = await SharedPreferences.getInstance();
    if (value is bool) await p.setBool(key, value);
    if (value is double) await p.setDouble(key, value);
  }

  Future<void> _cerrarSesion() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('¿Cerrar sesión?',
            style: GoogleFonts.baloo2(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.texto)),
        content: Text('¿Estás seguro que quieres salir de tu cuenta?',
            style: GoogleFonts.nunito(fontSize: 15, color: AppColors.textoSuave)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.errorTexto,
              elevation: 0,
            ),
            child: Text('Cerrar sesión', style: GoogleFonts.baloo2(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await SessionService.clearSession();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text('Configuración', style: GoogleFonts.baloo2(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.texto)),
                const Spacer(),
                const Text('⚙️', style: TextStyle(fontSize: 30)),
              ]),
              const SizedBox(height: 24),

              _buildSection('🔊 Sonido', [
                _switchTile('Efectos de sonido', 'Sonidos al responder y completar', _sonidoActivado,
                    (v) { setState(() => _sonidoActivado = v); _guardar('sonido', v); }),
                _switchTile('Música de fondo', 'Música suave mientras aprendes', _musicaActivada,
                    (v) { setState(() => _musicaActivada = v); _guardar('musica', v); }),
              ]),
              const SizedBox(height: 16),

              _buildSection('📱 Notificaciones', [
                _switchTile('Recordatorios', 'Te avisamos cuando tienes actividades nuevas', _notificaciones,
                    (v) { setState(() => _notificaciones = v); _guardar('notificaciones', v); }),
              ]),
              const SizedBox(height: 16),

              _buildSection('👁️ Visual', [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Text('📝', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Tamaño del texto',
                            style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.texto)),
                        Text(_tamanoTexto <= 0.9 ? 'Pequeño' : (_tamanoTexto >= 1.2 ? 'Grande' : 'Normal'),
                            style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textoSuave)),
                      ])),
                    ]),
                    Slider(
                      value: _tamanoTexto,
                      min: 0.8, max: 1.4, divisions: 3,
                      activeColor: AppColors.rosaOscuro,
                      inactiveColor: AppColors.rosa.withOpacity(0.3),
                      onChanged: (v) { setState(() => _tamanoTexto = v); _guardar('tamano_texto', v); },
                    ),
                  ]),
                ),
                _switchTile('Alto contraste', 'Colores más marcados para mejor visibilidad', _modoAltoContraste,
                    (v) { setState(() => _modoAltoContraste = v); _guardar('alto_contraste', v); }),
              ]),
              const SizedBox(height: 16),

              // Cuenta
              _buildSection('👤 Cuenta', [
                _infoTile('Nombre', widget.session['nombre'] as String? ?? '', Icons.person_rounded),
                _infoTile('Edad', '${widget.session['edad']} años', Icons.cake_rounded),
              ]),
              const SizedBox(height: 16),

              _buildSection('ℹ️ Información', [
                _infoTile('Versión', '1.0.0', Icons.info_outline_rounded),
                _infoTile('Desarrollado por', 'V&E Academy', Icons.favorite_rounded),
              ]),
              const SizedBox(height: 32),

              // Botón cerrar sesión
              SizedBox(
                width: double.infinity, height: 54,
                child: ElevatedButton.icon(
                  onPressed: _cerrarSesion,
                  icon: const Icon(Icons.logout_rounded, color: AppColors.errorTexto),
                  label: Text('Cerrar Sesión',
                      style: GoogleFonts.baloo2(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.errorTexto)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error.withOpacity(0.2),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: BorderSide(color: AppColors.errorTexto.withOpacity(0.4), width: 1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: GoogleFonts.baloo2(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.texto)),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [AppColors.sombraSuave],
        ),
        child: Column(children: children),
      ),
    ]);
  }

  Widget _switchTile(String titulo, String subtitulo, bool valor, void Function(bool) onChange) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(titulo, style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.texto)),
          Text(subtitulo, style: GoogleFonts.nunito(fontSize: 12, color: AppColors.textoSuave)),
        ])),
        Switch(
          value: valor,
          onChanged: onChange,
          activeColor: AppColors.rosaOscuro,
          activeTrackColor: AppColors.rosa,
        ),
      ]),
    );
  }

  Widget _infoTile(String label, String valor, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Icon(icon, color: AppColors.lilaOscuro, size: 20),
        const SizedBox(width: 12),
        Text(label, style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textoSuave)),
        const Spacer(),
        Text(valor, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.texto)),
      ]),
    );
  }
}
