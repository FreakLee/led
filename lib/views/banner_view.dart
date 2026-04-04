import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../viewmodels/app_viewmodel.dart';
import '../widgets/led_canvas.dart';
import 'widgets/section_label.dart';
import 'widgets/color_grid.dart';

class BannerView extends ConsumerStatefulWidget {
  const BannerView({super.key});
  @override
  ConsumerState<BannerView> createState() => _BannerViewState();
}

class _BannerViewState extends ConsumerState<BannerView> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider);
    final notifier = ref.read(appProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0F),
        title: const Text('LED Banner',
            style: TextStyle(color: Colors.white, fontSize: 17)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Color(0xFF7C3AED)),
            onPressed: () => _showAddSheet(context, notifier),
          ),
        ],
      ),
      body: Column(
        children: [
          _ledDisplay(state, notifier),
          _modeToggle(state, notifier),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _messageList(state, notifier),
                  const SizedBox(height: 20),
                  const SectionLabel('颜色主题'),
                  const SizedBox(height: 10),
                  ColorGrid(
                    selectedId: state.currentMessage?.colorThemeId,
                    onSelect: (id) => notifier.updateCurrentMessage(
                        (m) => m.copyWith(colorThemeId: id)),
                  ),
                  const SizedBox(height: 20),
                  const SectionLabel('文字特效'),
                  const SizedBox(height: 10),
                  EffectChips(
                    selectedId: state.currentMessage?.effectId,
                    onSelect: (id) => notifier.updateCurrentMessage(
                        (m) => m.copyWith(effectId: id)),
                  ),
                  const SizedBox(height: 20),
                  _sliders(state, notifier),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ledDisplay(AppState state, AppNotifier notifier) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF050508),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.hardEdge,
      child: state.currentMessage != null
          ? LEDCanvas(
              key: ValueKey(state.activeIndex),
              message: state.currentMessage!,
              isScrollMode: state.isScrollMode,
              mirrorH: state.mirrorHorizontal,
              // Bug 3 修复：去掉 onScrollComplete -> selectNext
              // selectNext 会改变 activeIndex → 重建 BannerView
              // → 颜色/特效列表跟着重置，用户选择被打断
              // 滚动循环在 LEDCanvas 内部处理，不需要外部 state 联动
              onScrollComplete: null,
            )
          : const SizedBox(
              height: 160,
              child: Center(
                  child: Text('+ 添加消息',
                      style: TextStyle(color: Colors.grey)))),
    );
  }

  Widget _modeToggle(AppState state, AppNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: ['滚动', '静态'].map((label) {
          final isScroll = label == '滚动';
          final active = state.isScrollMode == isScroll;
          return GestureDetector(
            onTap: () => notifier.setScrollMode(isScroll),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFF7C3AED)
                    : const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(label,
                  style: TextStyle(
                      color: active ? Colors.white : Colors.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _messageList(AppState state, AppNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('消息列表'),
        const SizedBox(height: 8),
        ...state.messages.asMap().entries.map((e) {
          final i = e.key;
          final msg = e.value;
          final active = i == state.activeIndex;
          return GestureDetector(
            onTap: () => notifier.selectMessage(i),
            child: Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF111120),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: active
                      ? const Color(0xFF7C3AED)
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      color: ColorTheme.find(msg.colorThemeId).singleColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(msg.text,
                        style: TextStyle(
                            color: active ? Colors.white : Colors.grey,
                            fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  if (active)
                    const Icon(Icons.graphic_eq,
                        size: 16, color: Color(0xFF7C3AED)),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => notifier.deleteMessage(i),
                    child: const Icon(Icons.close,
                        size: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _sliders(AppState state, AppNotifier notifier) {
    final msg = state.currentMessage;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sliderRow(
          label: '滚动速度', icon: Icons.speed,
          value: msg?.speed ?? 5, min: 1, max: 10, divisions: 9,
          format: (v) => v.toInt().toString(),
          onChanged: (v) =>
              notifier.updateCurrentMessage((m) => m.copyWith(speed: v)),
        ),
        const SizedBox(height: 16),
        _sliderRow(
          label: '字体大小', icon: Icons.format_size,
          value: msg?.fontSize ?? 72, min: 24, max: 100, divisions: 19,
          format: (v) => v.toInt().toString(),
          onChanged: (v) =>
              notifier.updateCurrentMessage((m) => m.copyWith(fontSize: v)),
        ),
        const SizedBox(height: 16),
        _sliderRow(
          label: '屏幕亮度', icon: Icons.brightness_high,
          value: state.brightness, min: 0.2, max: 1.0, divisions: 16,
          format: (v) => '${(v * 100).toInt()}%',
          onChanged: notifier.setBrightness,
        ),
      ],
    );
  }

  Widget _sliderRow({
    required String label,
    required IconData icon,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String Function(double) format,
    required void Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFF7C3AED),
                  inactiveTrackColor: const Color(0xFF222222),
                  thumbColor: Colors.white,
                  trackHeight: 3,
                ),
                child: Slider(
                  value: value.clamp(min, max),
                  min: min, max: max, divisions: divisions,
                  onChanged: onChanged,
                ),
              ),
            ),
            SizedBox(
              width: 40,
              child: Text(format(value),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.right),
            ),
          ],
        ),
      ],
    );
  }

  void _showAddSheet(BuildContext context, AppNotifier notifier) {
    _ctrl.clear();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0A0A0F),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20, right: 20, top: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ctrl,
              autofocus: true,
              maxLength: 40,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: InputDecoration(
                hintText: '输入要显示的文字...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                filled: true,
                fillColor: const Color(0xFF111120),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                counterStyle: const TextStyle(color: Colors.grey),
              ),
              onSubmitted: (v) {
                _add(v, notifier);
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey,
                        side: const BorderSide(color: Color(0xFF333333))),
                    child: const Text('取消'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _add(_ctrl.text, notifier);
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED)),
                    child: const Text('添加',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _add(String text, AppNotifier notifier) {
    final t = text.trim();
    if (t.isEmpty) return;
    notifier.addMessage(LEDMessage(text: t));
  }
}
