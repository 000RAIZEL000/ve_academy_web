import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

const _logoPath = 'assets/images/logo_vye_academy.webp';

class AppLogo extends StatelessWidget {
  final double size;
  final bool withShadow;

  const AppLogo({super.key, this.size = 80, this.withShadow = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: withShadow
            ? [
                BoxShadow(
                  color: AppColors.rosa.withOpacity(0.5),
                  blurRadius: size * 0.25,
                  spreadRadius: size * 0.05,
                ),
              ]
            : null,
      ),
      child: ClipOval(
        child: Image.asset(
          _logoPath,
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, st) => Container(
            color: Colors.white,
            child: Center(
              child: Text('📚', style: TextStyle(fontSize: size * 0.48)),
            ),
          ),
        ),
      ),
    );
  }
}

class AppLogoSmall extends StatelessWidget {
  final double logoSize;

  const AppLogoSmall({super.key, this.logoSize = 40});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        _logoPath,
        width: logoSize,
        height: logoSize,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, st) =>
            Text('📚', style: TextStyle(fontSize: logoSize * 0.65)),
      ),
    );
  }
}
