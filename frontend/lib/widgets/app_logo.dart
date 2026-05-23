import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

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
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: withShadow
            ? [
                BoxShadow(
                  color: AppColors.rosa.withOpacity(0.45),
                  blurRadius: size * 0.22,
                  spreadRadius: size * 0.06,
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: EdgeInsets.all(size * 0.1),
        child: Image.asset(
          'assets/images/logo_vye_academy.png',
          fit: BoxFit.contain,
          errorBuilder: (ctx, err, st) => Center(
            child: Text('📚', style: TextStyle(fontSize: size * 0.48)),
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
    return Image.asset(
      'assets/images/logo_vye_academy.png',
      width: logoSize,
      height: logoSize,
      fit: BoxFit.contain,
      errorBuilder: (ctx, err, st) =>
          Text('📚', style: TextStyle(fontSize: logoSize * 0.65)),
    );
  }
}
