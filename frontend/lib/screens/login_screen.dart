import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final TextEditingController _nameController = TextEditingController();
  int _selectedAge = 5;
  String _selectedAvatar = 'panda';
  bool _isLoading = false;

  late AnimationController _entryController;
  late Animation<double> _cardSlide;
  late Animation<double> _cardFade;

  final List<int> _edades = [5, 6, 7];
  final List<Map<String, String>> _avatares = [
    {'id': 'conejo', 'emoji': '🐰', 'name': 'Conejo'},
    {'id': 'gato', 'emoji': '🐱', 'name': 'Gato'},
    {'id': 'lechuza', 'emoji': '🦉', 'name': 'Lechuza'},
    {'id': 'leon', 'emoji': '🦁', 'name': 'León'},
    {'id': 'oso', 'emoji': '🐻', 'name': 'Oso'},
    {'id': 'panda', 'emoji': '🐼', 'name': 'Panda'},
    {'id': 'Perico', 'emoji': '🦜', 'name': 'Perico'},
    {'id': 'tigre', 'emoji': '🐯', 'name': 'Tigre'},
    {'id': 'zorro', 'emoji': '🦊', 'name': 'Zorro'},
  ];

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _cardSlide = Tween<double>(begin: 60, end: 0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );
    _cardFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );
    _entryController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final nombre = _nameController.text.trim();
    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Por favor, escribe tu nombre!')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final estudiante =
          await _apiService.login(nombre, _selectedAge, _selectedAvatar);
      await SessionService.saveSession(estudiante);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (ctx, anim, _) => HomeScreen(
            estudianteId: estudiante['id'] as int,
            estudianteEdad: estudiante['edad'] as int,
          ),
          transitionsBuilder: (ctx, anim, _, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Hubo un problema. ¿Está el servidor corriendo?')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF6C3DE0),
                  Color(0xFF9C4DCC),
                  Color(0xFFE040A0),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Floating decorative elements
          const _BackgroundDecorations(),
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Illustration header
                  const _IllustrationHeader(),
                  // Form card
                  AnimatedBuilder(
                    animation: _entryController,
                    builder: (ctx, child) => Transform.translate(
                      offset: Offset(0, _cardSlide.value),
                      child: Opacity(opacity: _cardFade.value, child: child),
                    ),
                    child: _FormCard(
                      nameController: _nameController,
                      edades: _edades,
                      avatares: _avatares,
                      selectedAge: _selectedAge,
                      selectedAvatar: _selectedAvatar,
                      isLoading: _isLoading,
                      onAgeChanged: (a) => setState(() => _selectedAge = a),
                      onAvatarChanged: (a) =>
                          setState(() => _selectedAvatar = a),
                      onSubmit: _handleLogin,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundDecorations extends StatelessWidget {
  const _BackgroundDecorations();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
            top: 30, left: 20,
            child: _FloatingItem('⭐', 36, 0.7)),
        Positioned(
            top: 80, right: 30,
            child: _FloatingItem('🌈', 40, 0.6)),
        Positioned(
            top: 140, left: 60,
            child: _FloatingItem('✏️', 30, 0.5)),
        Positioned(
            bottom: 200, right: 16,
            child: _FloatingItem('🌟', 32, 0.6)),
        Positioned(
            bottom: 300, left: 10,
            child: _FloatingItem('🦋', 28, 0.5)),
        // Large semi-transparent circles
        Positioned(
          top: -60,
          left: -60,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(15),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          right: -80,
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(10),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}

class _FloatingItem extends StatelessWidget {
  final String emoji;
  final double size;
  final double opacity;

  const _FloatingItem(this.emoji, this.size, this.opacity);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Text(emoji, style: TextStyle(fontSize: size)),
    );
  }
}

class _IllustrationHeader extends StatelessWidget {
  const _IllustrationHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 8),
      child: Column(
        children: [
          const Text('🎓', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 12),
          Text(
            'V&E Academy',
            style: GoogleFonts.baloo2(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(40),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '¡Aprende leyendo y diviértete! 🌟',
              style: GoogleFonts.nunito(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final TextEditingController nameController;
  final List<int> edades;
  final List<Map<String, String>> avatares;
  final int selectedAge;
  final String selectedAvatar;
  final bool isLoading;
  final ValueChanged<int> onAgeChanged;
  final ValueChanged<String> onAvatarChanged;
  final VoidCallback onSubmit;

  const _FormCard({
    required this.nameController,
    required this.edades,
    required this.avatares,
    required this.selectedAge,
    required this.selectedAvatar,
    required this.isLoading,
    required this.onAgeChanged,
    required this.onAvatarChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(50),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¡Regístrate para jugar!',
                style: GoogleFonts.baloo2(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.texto,
                ),
              ),
              const SizedBox(height: 20),

              // Nombre
              const _Label('¿Cómo te llamas?', '👦'),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Tu nombre aquí...',
                  prefixIcon: const Icon(Icons.face_rounded,
                      color: Color(0xFF6C3DE0)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: Color(0xFF6C3DE0), width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
              const SizedBox(height: 20),

              // Edad
              const _Label('¿Cuántos años tienes?', '🎂'),
              const SizedBox(height: 8),
              Row(
                children: edades.map((edad) {
                  final sel = selectedAge == edad;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onAgeChanged(edad),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          gradient: sel
                              ? const LinearGradient(colors: [
                                  Color(0xFF6C3DE0),
                                  Color(0xFF9C4DCC),
                                ])
                              : null,
                          color: sel ? null : Colors.grey[100],
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: sel
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF6C3DE0).withAlpha(80),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : null,
                        ),
                        child: Text(
                          '$edad',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.baloo2(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: sel ? Colors.white : AppColors.gris,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Avatar
              const _Label('Elige tu personaje:', '🎭'),
              const SizedBox(height: 8),
              SizedBox(
                height: 108,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: avatares.length,
                  itemBuilder: (ctx, i) {
                    final av = avatares[i];
                    final sel = selectedAvatar == av['id'];
                    return GestureDetector(
                      onTap: () => onAvatarChanged(av['id']!),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 76,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          gradient: sel
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF6C3DE0),
                                    Color(0xFFE040A0)
                                  ],
                                )
                              : null,
                          color: sel ? null : Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: sel
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF6C3DE0).withAlpha(80),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  )
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: Image.network(
                                ApiService.resolveStaticUrl(
                                    '/static/img/avatars/${av['id']}.png'),
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, e, st) => Text(
                                  av['emoji']!,
                                  style: const TextStyle(fontSize: 34),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              av['name']!,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color:
                                    sel ? Colors.white : AppColors.gris,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),

              // Botón
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 6,
                  ).copyWith(
                    backgroundColor: WidgetStateProperty.all(
                        Colors.transparent),
                    shadowColor: WidgetStateProperty.all(
                        const Color(0xFF6C3DE0).withAlpha(100)),
                  ),
                  onPressed: isLoading ? null : onSubmit,
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: isLoading
                          ? null
                          : const LinearGradient(
                              colors: [Color(0xFF6C3DE0), Color(0xFFE040A0)],
                            ),
                      color: isLoading ? Colors.grey[300] : null,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              '¡A JUGAR! 🚀',
                              style: GoogleFonts.baloo2(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  final String emoji;

  const _Label(this.text, this.emoji);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.baloo2(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            color: AppColors.texto,
          ),
        ),
      ],
    );
  }
}
