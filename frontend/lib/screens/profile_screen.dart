import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import 'settings_screen.dart';

const _avatarOpciones = [
  {'key': 'conejo', 'emoji': '🐰'},
  {'key': 'gato', 'emoji': '🐱'},
  {'key': 'lechuza', 'emoji': '🦉'},
  {'key': 'leon', 'emoji': '🦁'},
  {'key': 'oso', 'emoji': '🐻'},
  {'key': 'panda', 'emoji': '🐼'},
  {'key': 'perico', 'emoji': '🦜'},
  {'key': 'tigre', 'emoji': '🐯'},
  {'key': 'zorro', 'emoji': '🦊'},
];

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> session;
  final void Function(Map<String, dynamic>) onSessionUpdated;
  const ProfileScreen({super.key, required this.session, required this.onSessionUpdated});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _estudiante;
  bool _loading = true;
  bool _editando = false;
  final _nombreCtrl = TextEditingController();
  String _avatarSeleccionado = 'panda';

  String get _nombre => widget.session['nombre'] as String? ?? '';
  int get _puntos => (widget.session['puntos'] as num?)?.toInt() ?? 0;
  int get _nivel => (_puntos / 300).floor() + 1;
  String get _avatar => widget.session['avatar'] as String? ?? 'panda';
  int get _racha => (widget.session['racha_actual'] as num?)?.toInt() ?? 0;

  String _emojiAvatar(String key) {
    return _avatarOpciones.firstWhere(
        (a) => a['key'] == key, orElse: () => {'emoji': '🐼'})['emoji'] as String;
  }

  @override
  void initState() {
    super.initState();
    _cargarEstudiante();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarEstudiante() async {
    try {
      final id = (widget.session['id'] as num).toInt();
      final token = widget.session['token'] as String?;
      final data = await ApiService().getEstudiante(id, token: token);
      setState(() {
        _estudiante = data;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _iniciarEdicion() {
    _nombreCtrl.text = _nombre;
    _avatarSeleccionado = _avatar;
    setState(() => _editando = true);
  }

  Future<void> _guardarPerfil() async {
    if (_nombreCtrl.text.trim().isEmpty) return;
    try {
      final id = (widget.session['id'] as num).toInt();
      final token = widget.session['token'] as String?;
      final data = await ApiService().actualizarPerfil(
          id, _nombreCtrl.text.trim(), _avatarSeleccionado, token: token);
      final nuevoSession = Map<String, dynamic>.from(widget.session)
        ..['nombre'] = data['nombre']
        ..['avatar'] = data['avatar'];
      await SessionService.saveSession({...nuevoSession, 'token': token ?? ''});
      widget.onSessionUpdated(nuevoSession);
      setState(() => _editando = false);
      _mostrarSnack('¡Perfil actualizado! 🎉');
    } catch (e) {
      _mostrarSnack(e.toString().replaceAll('Exception: ', ''), isError: true);
    }
  }

  void _mostrarCambiarPassword() {
    final actualCtrl = TextEditingController();
    final nuevoCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Cambiar Contraseña', style: GoogleFonts.baloo2(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.texto)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
            controller: actualCtrl,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Contraseña actual'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: nuevoCtrl,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Nueva contraseña'),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              try {
                final id = (widget.session['id'] as num).toInt();
                final token = widget.session['token'] as String?;
                await ApiService().cambiarPassword(id, actualCtrl.text, nuevoCtrl.text, token: token);
                if (context.mounted) Navigator.pop(context);
                _mostrarSnack('¡Contraseña actualizada! 🔒');
              } catch (e) {
                _mostrarSnack(e.toString().replaceAll('Exception: ', ''), isError: true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.rosa, elevation: 0),
            child: Text('Guardar', style: GoogleFonts.baloo2(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _mostrarSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
      backgroundColor: isError ? AppColors.errorTexto : AppColors.exitoTexto,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.rosaOscuro))
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildProfileCard(),
                        const SizedBox(height: 20),
                        if (_editando) _buildEditForm() else _buildStats(),
                        const SizedBox(height: 20),
                        _buildLogros(),
                        const SizedBox(height: 20),
                        _buildAcciones(),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(children: [
      Text('Mi Perfil', style: GoogleFonts.baloo2(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.texto)),
      const Spacer(),
      if (!_editando)
        TextButton.icon(
          onPressed: _iniciarEdicion,
          icon: const Icon(Icons.edit_rounded, size: 18),
          label: Text('Editar', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
          style: TextButton.styleFrom(foregroundColor: AppColors.rosaOscuro),
        ),
      IconButton(
        icon: const Icon(Icons.settings_rounded, color: AppColors.textoSuave),
        tooltip: 'Configuración',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SettingsScreen(session: widget.session)),
        ),
      ),
    ]);
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.rosa, AppColors.lila],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [AppColors.sombraRosa],
      ),
      child: Row(children: [
        Container(
          width: 80, height: 80,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Center(
            child: ClipOval(
              child: Image.network(
                ApiService.resolveStaticUrl(widget.session['avatar_url'] as String?),
                width: 80, height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Text(_emojiAvatar(_avatar), style: const TextStyle(fontSize: 44)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_nombre, style: GoogleFonts.baloo2(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.texto),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          Text('Nivel $_nivel • ${widget.session['edad']} años',
              style: GoogleFonts.nunito(fontSize: 14, color: AppColors.texto.withOpacity(0.75))),
          const SizedBox(height: 8),
          Row(children: [
            _badge('⭐ $_puntos pts', AppColors.amarillo.withOpacity(0.5)),
            const SizedBox(width: 8),
            _badge('🔥 $_racha días', AppColors.rosa.withOpacity(0.5)),
          ]),
        ])),
      ]),
    );
  }

  Widget _badge(String text, Color bg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
    child: Text(text, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.texto)),
  );

  Widget _buildStats() {
    final insignias = (_estudiante?['insignias'] as List<dynamic>? ?? []).length;
    final compras = (_estudiante?['compras'] as List<dynamic>? ?? []).length;
    return Row(children: [
      Expanded(child: _statCard('🏆', '$insignias', 'Logros', AppColors.amarillo.withOpacity(0.25))),
      const SizedBox(width: 12),
      Expanded(child: _statCard('🛍️', '$compras', 'Compras', AppColors.lila.withOpacity(0.25))),
      const SizedBox(width: 12),
      Expanded(child: _statCard('📖', '${(_puntos / 10).floor()}', 'Libros', AppColors.celeste.withOpacity(0.25))),
    ]);
  }

  Widget _statCard(String emoji, String val, String label, Color bg) => Container(
    padding: const EdgeInsets.symmetric(vertical: 16),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(18)),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(emoji, style: const TextStyle(fontSize: 26)),
      const SizedBox(height: 4),
      Text(val, style: GoogleFonts.baloo2(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.texto)),
      Text(label, style: GoogleFonts.nunito(fontSize: 11, color: AppColors.textoSuave)),
    ]),
  );

  Widget _buildEditForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppColors.sombraSuave],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Editar Perfil', style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.texto)),
        const SizedBox(height: 16),
        TextField(
          controller: _nombreCtrl,
          decoration: const InputDecoration(
            labelText: 'Nombre',
            prefixIcon: Icon(Icons.person_rounded, color: AppColors.rosaOscuro),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),
        Text('Elige tu avatar:', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.texto)),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, childAspectRatio: 1.0, crossAxisSpacing: 8, mainAxisSpacing: 8,
          ),
          itemCount: _avatarOpciones.length,
          itemBuilder: (_, i) {
            final av = _avatarOpciones[i];
            final sel = _avatarSeleccionado == av['key'];
            return GestureDetector(
              onTap: () => setState(() => _avatarSeleccionado = av['key'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: sel ? AppColors.rosa.withOpacity(0.3) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: sel ? Border.all(color: AppColors.rosaOscuro, width: 2) : null,
                ),
                child: Center(child: Text(av['emoji'] as String, style: const TextStyle(fontSize: 36))),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: OutlinedButton(
            onPressed: () => setState(() => _editando = false),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.lila, width: 2)),
            child: Text('Cancelar', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: AppColors.lilaOscuro)),
          )),
          const SizedBox(width: 12),
          Expanded(child: ElevatedButton(
            onPressed: _guardarPerfil,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.rosa, elevation: 0),
            child: Text('Guardar', style: GoogleFonts.baloo2(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.texto)),
          )),
        ]),
      ]),
    );
  }

  Widget _buildLogros() {
    final insignias = _estudiante?['insignias'] as List<dynamic>? ?? [];
    if (insignias.isEmpty) return const SizedBox();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Mis Logros 🏆', style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.texto)),
      const SizedBox(height: 12),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, childAspectRatio: 0.9, crossAxisSpacing: 10, mainAxisSpacing: 10,
        ),
        itemCount: insignias.length.clamp(0, 6),
        itemBuilder: (_, i) {
          final logro = (insignias[i]['logro'] as Map<String, dynamic>? ?? {});
          return Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: AppColors.gradienteLogros,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(logro['icono'] as String? ?? '🏆', style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 4),
              Text(logro['nombre'] as String? ?? '',
                  style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF8B6914)),
                  textAlign: TextAlign.center, maxLines: 2),
            ]),
          );
        },
      ),
    ]);
  }

  Widget _buildAcciones() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Opciones', style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.texto)),
      const SizedBox(height: 12),
      _accionTile(Icons.lock_reset_rounded, 'Cambiar Contraseña', AppColors.celeste, _mostrarCambiarPassword),
    ]);
  }

  Widget _accionTile(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppColors.sombraSuave],
        ),
        child: Row(children: [
          Container(width: 40, height: 40,
            decoration: BoxDecoration(color: color.withOpacity(0.25), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 22)),
          const SizedBox(width: 14),
          Text(label, style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.texto)),
          const Spacer(),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textoSuave),
        ]),
      ),
    );
  }
}
