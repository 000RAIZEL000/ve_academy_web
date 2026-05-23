import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../services/api_service.dart';
import '../services/session_service.dart';
import '../widgets/app_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _obscure = true;
  String? _error;
  late AnimationController _animCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn));
    _slide =
        Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
            CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      final data =
          await ApiService().loginEmail(_emailCtrl.text.trim(), _passCtrl.text);
      await SessionService.saveSession(data);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home', arguments: data);
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isWide = w > 700;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.gradienteSplash),
        child: Stack(
          children: [
            _bgCircle(top: -70, left: -70, size: 220, c: AppColors.rosa.withOpacity(0.18)),
            _bgCircle(bottom: -60, right: -60, size: 200, c: AppColors.lila.withOpacity(0.15)),
            _bgCircle(top: 180, right: -20, size: 110, c: AppColors.celeste.withOpacity(0.2)),
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                    horizontal: isWide ? w * 0.28 : 24, vertical: 40),
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: Container(
                      padding: const EdgeInsets.all(36),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [AppColors.sombraLila],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const AppLogo(size: 100, withShadow: true),
                            const SizedBox(height: 20),
                            Text('¡Bienvenido de vuelta!',
                                style: GoogleFonts.baloo2(
                                    fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.texto),
                                textAlign: TextAlign.center),
                            const SizedBox(height: 6),
                            Text('Inicia sesión para continuar leyendo',
                                style: GoogleFonts.nunito(fontSize: 15, color: AppColors.textoSuave),
                                textAlign: TextAlign.center),
                            const SizedBox(height: 32),

                            TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Correo electrónico',
                                prefixIcon: Icon(Icons.email_rounded, color: AppColors.lilaOscuro),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Ingresa tu correo';
                                if (!v.contains('@')) return 'Correo inválido';
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _passCtrl,
                              obscureText: _obscure,
                              onFieldSubmitted: (_) => _login(),
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                prefixIcon: const Icon(Icons.lock_rounded, color: AppColors.lilaOscuro),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                      color: AppColors.textoSuave),
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
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

                            const SizedBox(height: 28),

                            SizedBox(
                              width: double.infinity, height: 54,
                              child: ElevatedButton(
                                onPressed: _loading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.rosa,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                  elevation: 0,
                                ),
                                child: _loading
                                    ? const SizedBox(width: 24, height: 24,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : Text('Iniciar Sesión',
                                        style: GoogleFonts.baloo2(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.texto)),
                              ),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity, height: 54,
                              child: OutlinedButton(
                                onPressed: () => Navigator.pushNamed(context, '/register/step1'),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.lila, width: 2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                  foregroundColor: AppColors.lilaOscuro,
                                ),
                                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  const Icon(Icons.stars_rounded, size: 20),
                                  const SizedBox(width: 8),
                                  Text('Crear Cuenta Nueva',
                                      style: GoogleFonts.baloo2(fontSize: 17, fontWeight: FontWeight.w600)),
                                ]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bgCircle({double? top, double? bottom, double? left, double? right,
      required double size, required Color c}) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Container(
          width: size, height: size,
          decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
    );
  }
}
