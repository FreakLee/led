import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../models/models.dart';

// ── LEDCanvas Widget ─────────────────────────────────────
class LEDCanvas extends StatefulWidget {
  final LEDMessage message;
  final bool isScrollMode;
  final bool mirrorH;
  final VoidCallback? onScrollComplete;

  const LEDCanvas({
    super.key,
    required this.message,
    required this.isScrollMode,
    this.mirrorH = false,
    this.onScrollComplete,
  });

  @override
  State<LEDCanvas> createState() => _LEDCanvasState();
}

class _LEDCanvasState extends State<LEDCanvas>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  double _scrollX = 0;
  double _textWidth = 0;
  Duration _lastElapsed = Duration.zero;
  double _phase = 0;

  @override
  void initState() {
    super.initState();
    _measureTextWidth();
    _ticker = createTicker(_onTick)..start();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scrollX = (context.size?.width ?? 400) + 40;
    });
  }

  @override
  void didUpdateWidget(LEDCanvas old) {
    super.didUpdateWidget(old);
    if (old.message.text != widget.message.text ||
        old.message.fontSize != widget.message.fontSize) {
      _measureTextWidth();
      _scrollX = (context.size?.width ?? 400) + 40;
      _phase = 0;
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _measureTextWidth() {
    final tp = TextPainter(
      text: TextSpan(
        text: widget.message.text,
        style: TextStyle(
            fontSize: widget.message.fontSize, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: double.infinity);
    _textWidth = tp.width;
  }

  void _onTick(Duration elapsed) {
    if (!mounted) return;
    final dt = _lastElapsed == Duration.zero
        ? 0.016
        : (elapsed - _lastElapsed).inMicroseconds / 1e6;
    _lastElapsed = elapsed;
    _phase += dt;

    if (widget.isScrollMode) {
      _scrollX -= widget.message.speed * 60 * dt;
      if (_scrollX < -(_textWidth + 60)) {
        _scrollX = (context.size?.width ?? 400) + 40;
        widget.onScrollComplete?.call();
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _LEDPainter(
          message: widget.message,
          isScrollMode: widget.isScrollMode,
          mirrorH: widget.mirrorH,
          scrollX: _scrollX,
          textWidth: _textWidth,
          phase: _phase,
        ),
        size: const Size.fromHeight(160),
      ),
    );
  }
}

// ── _LEDPainter ──────────────────────────────────────────
class _LEDPainter extends CustomPainter {
  final LEDMessage message;
  final bool isScrollMode;
  final bool mirrorH;
  final double scrollX;
  final double textWidth;
  final double phase;

  _LEDPainter({
    required this.message,
    required this.isScrollMode,
    required this.mirrorH,
    required this.scrollX,
    required this.textWidth,
    required this.phase,
  });

  @override
  bool shouldRepaint(_LEDPainter old) => true;

  @override
  void paint(Canvas canvas, Size size) {
    final W = size.width;
    final H = size.height;

    // 背景
    canvas.drawRect(Rect.fromLTWH(0, 0, W, H),
        Paint()..color = const Color(0xFF050508));

    // 扫描线
    if (message.effectId != 'neon') {
      final p = Paint()..color = Colors.black.withOpacity(0.15);
      for (double y = 0; y < H; y += 5) {
        canvas.drawRect(Rect.fromLTWH(0, y, W, 2), p);
      }
    }

    // 镜像
    if (mirrorH) {
      canvas.save();
      canvas.translate(W, 0);
      canvas.scale(-1, 1);
    }

    final x = isScrollMode ? scrollX : (W - textWidth) / 2;
    final y = H / 2;
    _drawText(canvas, x, y);

    if (mirrorH) canvas.restore();

    // 点阵
    final dp = Paint()..color = Colors.black.withOpacity(0.08);
    for (double dx = 0; dx < W; dx += 5) {
      for (double dy = 0; dy < H; dy += 5) {
        canvas.drawRect(Rect.fromLTWH(dx, dy, 1.5, 1.5), dp);
      }
    }
  }

  void _drawText(Canvas canvas, double x, double y) {
    final theme = ColorTheme.find(message.colorThemeId);
    switch (message.effectId) {
      case 'blink':
        final a = (sin(phase * 5) + 1) / 2 * 0.8 + 0.2;
        _drawString(canvas, x, y, theme, opacity: a);
      case 'breath':
        final a = (sin(phase * 1.5) + 1) / 2 * 0.7 + 0.3;
        _drawString(canvas, x, y, theme, opacity: a);
      case 'wave':
        _drawWave(canvas, x, y, theme);
      case 'neon':
        _drawNeon(canvas, x, y, theme);
      case 'rainbow':
        _drawRainbow(canvas, x, y);
      default:
        _drawString(canvas, x, y, theme);
    }
  }

  void _drawString(Canvas canvas, double x, double y, ColorTheme theme,
      {double opacity = 1.0}) {
    if (theme.isGradient) {
      _drawGradient(canvas, x, y, theme, opacity: opacity);
    } else {
      _tp(theme.singleColor.withOpacity(opacity))
        ..layout(maxWidth: double.infinity)
        ..paint(canvas, _offset(x, y));
    }
  }

  void _drawGradient(Canvas canvas, double x, double y, ColorTheme theme,
      {double opacity = 1.0}) {
    final tp = _tp(Colors.white)..layout(maxWidth: double.infinity);
    final rect = Rect.fromLTWH(x, y - tp.height / 2, textWidth, tp.height);
    canvas.saveLayer(
        Rect.fromLTWH(x - 10, y - tp.height, textWidth + 20, tp.height * 2),
        Paint());
    tp.paint(canvas, _offset(x, y));
    canvas.drawRect(
      rect,
      Paint()
        ..blendMode = BlendMode.srcIn
        ..shader = LinearGradient(
          colors: theme.colors.map((c) => c.withOpacity(opacity)).toList(),
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(rect),
    );
    canvas.restore();
  }

  void _drawWave(Canvas canvas, double x, double y, ColorTheme theme) {
    double curX = x;
    final chars = message.text.split('');
    for (int i = 0; i < chars.length; i++) {
      final waveY = y + sin(phase * 3 + i * 0.6) * 14;
      final tp = _tpChar(chars[i], theme.singleColor)
        ..layout(maxWidth: double.infinity);
      tp.paint(canvas, Offset(curX, waveY - tp.height / 2));
      curX += tp.width;
    }
  }

  void _drawNeon(Canvas canvas, double x, double y, ColorTheme theme) {
    final glow = (sin(phase * 2) + 1) / 2 * 8 + 8;
    final color = theme.singleColor;
    final style = TextStyle(
      fontSize: message.fontSize,
      fontWeight: FontWeight.bold,
      color: color,
      shadows: [
        Shadow(color: color.withOpacity(0.9), blurRadius: glow * 2),
        Shadow(color: color.withOpacity(0.5), blurRadius: glow * 4),
      ],
    );
    final tp = TextPainter(
      text: TextSpan(text: message.text, style: style),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: double.infinity);
    tp.paint(canvas, _offset(x, y));
  }

  void _drawRainbow(Canvas canvas, double x, double y) {
    double curX = x;
    final chars = message.text.split('');
    for (int i = 0; i < chars.length; i++) {
      final hue = ((phase * 0.3 + i * 0.12) % 1.0) * 360;
      final color = HSVColor.fromAHSV(1, hue, 1, 1).toColor();
      final tp = _tpChar(chars[i], color)..layout(maxWidth: double.infinity);
      tp.paint(canvas, Offset(curX, y - tp.height / 2));
      curX += tp.width;
    }
  }

  Offset _offset(double x, double y) {
    final tp = _tp(Colors.white)..layout(maxWidth: double.infinity);
    return Offset(x, y - tp.height / 2);
  }

  TextPainter _tp(Color color) => TextPainter(
        text: TextSpan(
          text: message.text,
          style: TextStyle(
              fontSize: message.fontSize,
              fontWeight: FontWeight.bold,
              color: color),
        ),
        textDirection: TextDirection.ltr,
      );

  TextPainter _tpChar(String char, Color color) => TextPainter(
        text: TextSpan(
          text: char,
          style: TextStyle(
              fontSize: message.fontSize,
              fontWeight: FontWeight.bold,
              color: color),
        ),
        textDirection: TextDirection.ltr,
      );
}
