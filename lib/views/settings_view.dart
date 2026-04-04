import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/app_viewmodel.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appProvider);
    final notifier = ref.read(appProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0F),
        title: const Text('设置', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(children: [
        _header('显示设置'),
        _toggle('防止自动锁屏', '使用期间保持屏幕常亮',
            Icons.lock_open, Colors.green,
            state.keepScreenOn, notifier.setKeepScreenOn),
        _toggle('水平镜像', '翻转文字方向（镜子模式）',
            Icons.flip, Colors.blue,
            state.mirrorHorizontal, notifier.setMirror),
        _toggle('自动循环播放', '滚动完成后自动切换下一条',
            Icons.repeat, Colors.purple,
            state.autoAdvance, notifier.setAutoAdvance),
        _header('亮度控制'),
        _brightness(context, state, notifier),
        _header('关于'),
        _info('版本', '1.0.0'),
        _info('状态管理', 'Riverpod 2.x Notifier'),
        _info('渲染引擎', 'CustomPainter + Ticker'),
        _info('最低 SDK', 'Flutter 3.x / Dart 3.x'),
        const SizedBox(height: 40),
      ]),
    );
  }

  Widget _header(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Text(t.toUpperCase(),
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Color(0xFF585858),
                letterSpacing: 1.2)),
      );

  Widget _toggle(String title, String sub, IconData icon, Color color,
      bool value, void Function(bool) onChanged) {
    return Container(
      color: const Color(0xFF0D0D0D),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: const TextStyle(color: Colors.white, fontSize: 15)),
            const SizedBox(height: 2),
            Text(sub,
                style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ]),
        ),
        Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF7C3AED)),
      ]),
    );
  }

  Widget _brightness(
      BuildContext context, AppState state, AppNotifier notifier) {
    return Container(
      color: const Color(0xFF0D0D0D),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(children: [
        Row(children: [
          const Icon(Icons.brightness_high, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          const Text('全局亮度',
              style: TextStyle(color: Colors.white, fontSize: 15)),
          const Spacer(),
          Text('${(state.brightness * 100).toInt()}%',
              style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ]),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF7C3AED),
            inactiveTrackColor: const Color(0xFF333333),
            thumbColor: Colors.white,
            trackHeight: 3,
          ),
          child: Slider(
            value: state.brightness,
            min: 0.2, max: 1.0,
            onChanged: notifier.setBrightness,
          ),
        ),
      ]),
    );
  }

  Widget _info(String label, String value) => Container(
        color: const Color(0xFF0D0D0D),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const Spacer(),
          Text(value,
              style: const TextStyle(color: Color(0xFF888888), fontSize: 13)),
        ]),
      );
}
