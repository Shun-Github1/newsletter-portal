import 'package:flutter/material.dart';

/// Portal mark that swaps light/dark assets with theme brightness.
class BrandLogo extends StatelessWidget {
  final double size;

  const BrandLogo({super.key, this.size = 28});

  static const lightAsset = 'assets/images/logo_light.png';
  static const darkAsset = 'assets/images/logo_dark.png';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Image.asset(
      isDark ? darkAsset : lightAsset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      semanticLabel: 'Newsletter Portal',
    );
  }
}
