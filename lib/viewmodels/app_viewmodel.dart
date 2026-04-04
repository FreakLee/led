import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:screen_brightness/screen_brightness.dart';
import '../models/models.dart';

// ── AppState ─────────────────────────────────────────────
class AppState {
  final List<LEDMessage> messages;
  final int activeIndex;
  final double brightness;
  final bool keepScreenOn;
  final bool mirrorHorizontal;
  final bool autoAdvance;
  final StrobeMode strobeMode;
  final String bigTextContent;
  final double bigTextSize;
  final String bigTextColorId;
  final int selectedTab;
  final bool isScrollMode;

  const AppState({
    required this.messages,
    this.activeIndex = 0,
    this.brightness = 1.0,
    this.keepScreenOn = true,
    this.mirrorHorizontal = false,
    this.autoAdvance = true,
    this.strobeMode = StrobeMode.off,
    this.bigTextContent = 'Hello!',
    this.bigTextSize = 80,
    this.bigTextColorId = 'white',
    this.selectedTab = 0,
    this.isScrollMode = true,
  });

  AppState copyWith({
    List<LEDMessage>? messages,
    int? activeIndex,
    double? brightness,
    bool? keepScreenOn,
    bool? mirrorHorizontal,
    bool? autoAdvance,
    StrobeMode? strobeMode,
    String? bigTextContent,
    double? bigTextSize,
    String? bigTextColorId,
    int? selectedTab,
    bool? isScrollMode,
  }) {
    return AppState(
      messages: messages ?? this.messages,
      activeIndex: activeIndex ?? this.activeIndex,
      brightness: brightness ?? this.brightness,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      mirrorHorizontal: mirrorHorizontal ?? this.mirrorHorizontal,
      autoAdvance: autoAdvance ?? this.autoAdvance,
      strobeMode: strobeMode ?? this.strobeMode,
      bigTextContent: bigTextContent ?? this.bigTextContent,
      bigTextSize: bigTextSize ?? this.bigTextSize,
      bigTextColorId: bigTextColorId ?? this.bigTextColorId,
      selectedTab: selectedTab ?? this.selectedTab,
      isScrollMode: isScrollMode ?? this.isScrollMode,
    );
  }

  LEDMessage? get currentMessage =>
      messages.isNotEmpty && activeIndex < messages.length
          ? messages[activeIndex]
          : null;
}

// ── AppNotifier (Riverpod 2.x: Notifier, NOT StateNotifier) ──
class AppNotifier extends Notifier<AppState> {
  @override
  AppState build() {
    Future.microtask(() => WakelockPlus.enable());
    return AppState(
      messages: [
        LEDMessage(text: '欢迎使用 LED Banner! 🎉'),
        LEDMessage(text: 'Hello World!', colorThemeId: 'blue', effectId: 'neon'),
        LEDMessage(text: '加油！Fighting！', colorThemeId: 'red', effectId: 'wave'),
      ],
    );
  }

  void addMessage(LEDMessage msg) {
    final list = [...state.messages, msg];
    state = state.copyWith(messages: list, activeIndex: list.length - 1);
  }

  void deleteMessage(int index) {
    if (index < 0 || index >= state.messages.length) return;
    final list = [...state.messages]..removeAt(index);
    final idx = list.isEmpty ? 0 : state.activeIndex.clamp(0, list.length - 1);
    state = state.copyWith(messages: list, activeIndex: idx);
  }

  void selectMessage(int index) => state = state.copyWith(activeIndex: index);

  void selectNext() {
    if (state.messages.length <= 1) return;
    state = state.copyWith(
        activeIndex: (state.activeIndex + 1) % state.messages.length);
  }

  void updateCurrentMessage(LEDMessage Function(LEDMessage) fn) {
    final cur = state.currentMessage;
    if (cur == null) return;
    final list = [...state.messages];
    list[state.activeIndex] = fn(cur);
    state = state.copyWith(messages: list);
  }

  void setScrollMode(bool v) => state = state.copyWith(isScrollMode: v);

  Future<void> setBrightness(double v) async {
    state = state.copyWith(brightness: v);
    try { await ScreenBrightness().setScreenBrightness(v); } catch (_) {}
  }

  Future<void> restoreBrightness() async {
    try { await ScreenBrightness().resetScreenBrightness(); } catch (_) {}
  }

  void setKeepScreenOn(bool v) {
    state = state.copyWith(keepScreenOn: v);
    v ? WakelockPlus.enable() : WakelockPlus.disable();
  }

  void setMirror(bool v)        => state = state.copyWith(mirrorHorizontal: v);
  void setAutoAdvance(bool v)   => state = state.copyWith(autoAdvance: v);
  void setStrobeMode(StrobeMode m) => state = state.copyWith(strobeMode: m);
  void setSelectedTab(int t)    => state = state.copyWith(selectedTab: t);
  void setBigText(String t)     => state = state.copyWith(bigTextContent: t);
  void setBigTextSize(double s) => state = state.copyWith(bigTextSize: s);
  void setBigTextColor(String c) => state = state.copyWith(bigTextColorId: c);

  Future<void> saveMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'messages', state.messages.map((m) => jsonEncode(m.toJson())).toList());
  }

  Future<void> loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('messages');
    if (list != null && list.isNotEmpty) {
      state = state.copyWith(
          messages: list.map((s) => LEDMessage.fromJson(jsonDecode(s))).toList());
    }
  }
}

// ── Provider (Riverpod 2.x: NotifierProvider, NOT StateNotifierProvider) ──
final appProvider = NotifierProvider<AppNotifier, AppState>(AppNotifier.new);
