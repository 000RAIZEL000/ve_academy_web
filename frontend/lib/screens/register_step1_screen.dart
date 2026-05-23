import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/app_logo.dart';

const _avatars = [
  {'key': 'conejo', 'emoji': '🐰', 'name': 'Conejo'},
  {'key': 'gato', 'emoji': '🐱', 'name': 'Gato'},
  {'key': 'lechuza', 'emoji': '🦉', 'name': 'Lechuza'},
  {'key': 'leon', 'emoji': '🦁', 'name': 'León'},
  {'key': 'oso', 'emoji': '🐻', 'name': 'Oso'},
  {'key': 'panda', 'emoji': '🐼', 'name': 'Panda'},
  {'key': 'perico', 'emoji': '🦜', 'name': 'Perico'},
  {'key': 'tigre', 'emoji': '🐯', 'name': 'Tigre'},
  {'key': 'zorro', 'emoji': '🦊', 'name': 'Zorro'},
];

class RegisterStep1Screen extends StatefulWidget {
  const RegisterStep1Screen({super.key});

  @override
  State<RegisterStep1Screen> createState() => _RegisterStep1ScreenState();
}

class _RegisterStep1ScreenState extends State<RegisterStep1Screen>
    with SingleTickerProviderStateMixin {
  final _nombreCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _edad = 5;
  String _avatar = 'panda';
  late AnimationController _animCtrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _continuar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pushNamed(context, '/register/step2', arguments: {
      'nombre': _nombreCtrl.text.trim(),
      'edad': _edad,
      'avatar': _avatar,
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isWide = w > 700;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradienteSplash),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                  horizontal: isWide ? w * 0.22 : 20, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.texto),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Paso 1 de 2', style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textoSuave)),
                          Text('Tu Perfil', style: GoogleFonts.baloo2(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.texto)),
                        ]),
                      ),
                      const AppLogo(size: 48, withShadow: false),
                    ]),
                    const SizedBox(height: 8),
                    // Barra de progreso
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: 0.5,
                        backgroundColor: AppColors.lila.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation(AppColors.rosaOscuro),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Card principal
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [AppColors.sombraSuave],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nombre
                          Text('¿Cómo te llamas?',
                              style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.texto)),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _nombreCtrl,
                            decoration: const InputDecoration(
                              hintText: 'Mi nombre es...',
                              prefixIcon: Icon(Icons.person_rounded, color: AppColors.rosaOscuro),
                            ),
                            textCapitalization: TextCapitalization.words,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Escribe tu nombre';
                              if (v.trim().length < 2) return 'El nombre es muy corto';
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Edad
                          Text('¿Cuántos años tienes?',
                              style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.texto)),
                          const SizedBox(height: 12),
                          Row(
                            children: [5, 6, 7].map((e) {
                              final sel = _edad == e;
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: GestureDetector(
                                    onTap: () => setState(() => _edad = e),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      height: 70,
                                      decoration: BoxDecoration(
                                        color: sel ? AppColors.rosa : AppColors.lila.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(18),
                                        border: sel ? Border.all(color: AppColors.rosaOscuro, width: 2.5) : null,
                                        boxShadow: sel ? [AppColors.sombraRosa] : [],
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text('$e', style: GoogleFonts.baloo2(fontSize: 28, fontWeight: FontWeight.w800,
                                              color: sel ? AppColors.rosaOscuro : AppColors.texto)),
                                          Text('años', style: GoogleFonts.nunito(fontSize: 12, color: sel ? AppColors.rosaOscuro : AppColors.textoSuave)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),

                          // Avatar
                          Text('Elige tu avatar',
                              style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.texto)),
                          const SizedBox(height: 12),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 0.95,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: _avatars.length,
                            itemBuilder: (_, i) {
                              final av = _avatars[i];
                              final sel = _avatar == av['key'];
                              return GestureDetector(
                                onTap: () => setState(() => _avatar = av['key'] as String),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: sel
                                        ? AppColors.coloresAvatares[i % AppColors.coloresAvatares.length]
                                        : Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(18),
                                    border: sel
                                        ? Border.all(color: AppColors.rosaOscuro, width: 2.5)
                                        : Border.all(color: Colors.grey.shade200, width: 1.5),
                                    boxShadow: sel ? [AppColors.sombraSuave] : [],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(av['emoji'] as String, style: const TextStyle(fontSize: 38)),
                                      const SizedBox(height: 4),
                                      Text(av['name'] as String,
                                          style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700,
                                              color: sel ? AppColors.rosaOscuro : AppColors.texto)),
                                      if (sel)
                                        const Icon(Icons.check_circle, color: AppColors.rosaOscuro, size: 16),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity, height: 56,
                      child: ElevatedButton(
                        onPressed: _continuar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.rosa,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                          elevation: 0,
                        ),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text('Continuar',
                              style: GoogleFonts.baloo2(fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.texto)),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, color: AppColors.texto),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
