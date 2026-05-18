import 'package:flutter/material.dart';

// NOTE: BackdropFilter (blur) was removed intentionally.
// It causes GPU crashes on Android Impeller/OpenGLES backend.
// The glassmorphism effect is achieved through layered semi-transparent
// containers, which is visually equivalent on dark backgrounds and stable.

class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.radius = 16,
    this.color,
    this.borderColor,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final Color? color;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final br = BorderRadius.circular(radius);

    final content = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? const Color(0x12FFFFFF),
        borderRadius: br,
        border: Border.all(
          color: borderColor ?? const Color(0x14FFFFFF),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      borderRadius: br,
      child: InkWell(
        borderRadius: br,
        onTap: onTap,
        splashColor: Colors.white.withValues(alpha: 0.05),
        highlightColor: Colors.white.withValues(alpha: 0.03),
        child: content,
      ),
    );
  }
}
