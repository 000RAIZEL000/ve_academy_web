import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import '../widgets/app_logo.dart';

class RegisterStep2Screen extends StatefulWidget {
  final Map<String, dynamic> step1Data;
  const RegisterStep2Screen({super.key, required this.step1Data});

  @override
  State<RegisterStep2Screen> createState() => _RegisterStep2ScreenState();
}

class _RegisterStep2ScreenState extends State<RegisterStep2Screen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  String? _error;
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
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ApiService().register(
        nombre: widget.step1Data['nombre'] as String,
        edad: widget.step1Data['edad'] as int,
        avatar: widget.step1Data['avatar'] as String,
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );
      await SessionService.saveSession(data);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false, arguments: data);
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  String _avatarEmoji() {
    const map = {
      'conejo': '🐰', 'gato': '🐱', 'lechuza': '🦉', 'leon': '🦁',
      'oso': '🐻', 'panda': '🐼', 'perico': '🦜', 'tigre': '🐯', 'zorro': '🦊',
    };
    return map[widget.step1Data['avatar']] ?? '🐼';
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
                    Row(children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.texto),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Paso 2 de 2', style: GoogleFonts.nunito(fontSize: 13, color: AppColors.textoSuave)),
                          Text('Tu Cuenta', style: GoogleFonts.baloo2(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.texto)),
                        ]),
                      ),
                      const AppLogo(size: 48, withShadow: false),
                    ]),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: const LinearProgressIndicator(
                        value: 1.0,
                        backgroundColor: Color(0xFFE0D4FF),
                        valueColor: AlwaysStoppedAnimation(AppColors.rosaOscuro),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Resumen del paso 1
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.rosa.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.rosa, width: 1.5),
                      ),
                      child: Row(children: [
                        ClipOval(
                          child: Image.asset(
                            'assets/avatars/${widget.step1Data['avatar']}.png',
                            width: 50, height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Text(_avatarEmoji(), style: const TextStyle(fontSize: 32)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(widget.step1Data['nombre'] as String,
                              style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.texto)),
                          Text('${widget.step1Data['edad']} años',
                              style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textoSuave)),
                        ]),
                        const Spacer(),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cambiar', style: GoogleFonts.nunito(color: AppColors.rosaOscuro, fontWeight: FontWeight.w600)),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 24),

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
                          Text('Crea tu cuenta',
                              style: GoogleFonts.baloo2(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.texto)),
                          const SizedBox(height: 6),
                          Text('Necesitamos tu correo para proteger tu cuenta',
                              style: GoogleFonts.nunito(fontSize: 14, color: AppColors.textoSuave)),
                          const SizedBox(height: 24),

                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Correo electrónico',
                              prefixIcon: Icon(Icons.email_rounded, color: AppColors.lilaOscuro),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Ingresa tu correo';
                              if (!v.contains('@') || !v.contains('.')) return 'Correo inválido';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _passCtrl,
                            obscureText: _obscurePass,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: const Icon(Icons.lock_rounded, color: AppColors.lilaOscuro),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePass ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                    color: AppColors.textoSuave),
                                onPressed: () => setState(() => _obscurePass = !_obscurePass),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Ingresa una contraseña';
                              if (v.length < 6) return 'Mínimo 6 caracteres';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _confirmCtrl,
                            obscureText: _obscureConfirm,
                            onFieldSubmitted: (_) => _registrar(),
                            decoration: InputDecoration(
                              labelText: 'Confirmar contraseña',
                              prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.lilaOscuro),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureConfirm ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                    color: AppColors.textoSuave),
                                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Confirma tu contraseña';
                              if (v != _passCtrl.text) return 'Las contraseñas no coinciden';
                              return null;
                            },
                          ),

                          if (_error != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(children: [
                                const Icon(Icons.error_rounded, color: AppColors.errorTexto, size: 18),
                                const SizedBox(width: 8),
                                Expanded(child: Text(_error!,
                                    style: GoogleFonts.nunito(color: AppColors.errorTexto, fontWeight: FontWeight.w600, fontSize: 14))),
                              ]),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity, height: 56,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _registrar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.rosa,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                          elevation: 0,
                        ),
                        child: _loading
                            ? const SizedBox(width: 24, height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                const Text('🎉', style: TextStyle(fontSize: 22)),
                                const SizedBox(width: 10),
                                Text('¡Crear mi Cuenta!',
                                    style: GoogleFonts.baloo2(fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.texto)),
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
