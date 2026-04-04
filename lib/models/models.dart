import 'package:flutter/material.dart';

// ── LEDMessage ──────────────────────────────────────────
class LEDMessage {
  final String id;
  String text;
  String colorThemeId;
  String effectId;
  double fontSize;
  double speed;

  LEDMessage({
    String? id,
    required this.text,
    this.colorThemeId = 'rainbow',
    this.effectId = 'normal',
    this.fontSize = 72,
    this.speed = 5,
  }) : id = id ?? UniqueKey().toString();

  LEDMessage copyWith({
    String? text,
    String? colorThemeId,
    String? effectId,
    double? fontSize,
    double? speed,
  }) =>
      LEDMessage(
        id: id,
        text: text ?? this.text,
        colorThemeId: colorThemeId ?? this.colorThemeId,
        effectId: effectId ?? this.effectId,
        fontSize: fontSize ?? this.fontSize,
        speed: speed ?? this.speed,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'colorThemeId': colorThemeId,
        'effectId': effectId,
        'fontSize': fontSize,
        'speed': speed,
      };

  factory LEDMessage.fromJson(Map<String, dynamic> j) => LEDMessage(
        id: j['id'],
        text: j['text'],
        colorThemeId: j['colorThemeId'] ?? 'rainbow',
        effectId: j['effectId'] ?? 'normal',
        fontSize: (j['fontSize'] ?? 72).toDouble(),
        speed: (j['speed'] ?? 5).toDouble(),
      );
}

// ── ColorTheme ──────────────────────────────────────────
class ColorTheme {
  final String id;
  final String name;
  final List<Color> colors;

  const ColorTheme({required this.id, required this.name, required this.colors});

  LinearGradient get gradient => LinearGradient(
        colors: colors,
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );

  Color get singleColor => colors.first;
  bool get isGradient => colors.length > 1;

  static const List<ColorTheme> all = [
    ColorTheme(id: 'rainbow', name: '彩虹', colors: [
      Color(0xFFf43f5e), Color(0xFFf97316), Color(0xFFfbbf24),
      Color(0xFF22c55e), Color(0xFF3b82f6), Color(0xFFa855f7),
    ]),
    ColorTheme(id: 'red',    name: '玫红', colors: [Color(0xFFf43f5e)]),
    ColorTheme(id: 'orange', name: '橙色', colors: [Color(0xFFf97316)]),
    ColorTheme(id: 'yellow', name: '黄色', colors: [Color(0xFFfbbf24)]),
    ColorTheme(id: 'green',  name: '绿色', colors: [Color(0xFF22c55e)]),
    ColorTheme(id: 'blue',   name: '蓝色', colors: [Color(0xFF3b82f6)]),
    ColorTheme(id: 'purple', name: '紫色', colors: [Color(0xFFa855f7)]),
    ColorTheme(id: 'cyan',   name: '青色', colors: [Color(0xFF06b6d4)]),
    ColorTheme(id: 'white',  name: '白色', colors: [Color(0xFFffffff)]),
  ];

  static ColorTheme find(String id) =>
      all.firstWhere((t) => t.id == id, orElse: () => all.first);
}

// ── LEDEffect ───────────────────────────────────────────
class LEDEffect {
  final String id;
  final String name;
  final IconData icon;

  const LEDEffect({required this.id, required this.name, required this.icon});

  static const List<LEDEffect> all = [
    LEDEffect(id: 'normal',  name: '正常',   icon: Icons.text_fields),
    LEDEffect(id: 'blink',   name: '闪烁',   icon: Icons.bolt),
    LEDEffect(id: 'breath',  name: '呼吸',   icon: Icons.air),
    LEDEffect(id: 'wave',    name: '波浪',   icon: Icons.waves),
    LEDEffect(id: 'neon',    name: '霓虹',   icon: Icons.auto_awesome),
    LEDEffect(id: 'rainbow', name: '彩虹流', icon: Icons.gradient),
  ];

  static LEDEffect find(String id) =>
      all.firstWhere((e) => e.id == id, orElse: () => all.first);
}

// ── StrobeMode ──────────────────────────────────────────
enum StrobeMode {
  off('关闭'),
  steady('常亮'),
  slow('慢闪'),
  fast('快闪'),
  sos('SOS');

  final String label;
  const StrobeMode(this.label);
}
