import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../viewmodels/app_viewmodel.dart';
import 'widgets/section_label.dart';
import 'widgets/color_grid.dart';

class BigTextView extends ConsumerWidget {
  const BigTextView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appProvider);
    final notifier = ref.read(appProvider.notifier);
    final theme = ColorTheme.find(state.bigTextColorId);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0F),
        title: const Text('大字幕',
            style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onDoubleTap: () => _fullscreen(context, state, notifier),
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFF050508),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(20),
                child: _text(state, theme),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text('双击进入全屏',
                  style: TextStyle(fontSize: 12, color: Color(0xFF444444))),
            ),
            const SizedBox(height: 20),
            const SectionLabel('显示内容'),
            const SizedBox(height: 8),
            TextField(
              controller:
                  TextEditingController(text: state.bigTextContent)
                    ..selection = TextSelection.collapsed(
                        offset: state.bigTextContent.length),
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: '输入文字...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                filled: true,
                fillColor: const Color(0xFF111120),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
              onChanged: notifier.setBigText,
            ),
            const SizedBox(height: 20),
            const SectionLabel('字体大小'),
            const SizedBox(height: 6),
            Row(children: [
              const Icon(Icons.format_size, size: 14, color: Colors.grey),
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
                    value: state.bigTextSize,
                    min: 24, max: 160, divisions: 34,
                    onChanged: notifier.setBigTextSize,
                  ),
                ),
              ),
              SizedBox(
                width: 36,
                child: Text('${state.bigTextSize.toInt()}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    textAlign: TextAlign.right),
              ),
            ]),
            const SizedBox(height: 20),
            const SectionLabel('文字颜色'),
            const SizedBox(height: 10),
            ColorGrid(
                selectedId: state.bigTextColorId,
                onSelect: notifier.setBigTextColor),
          ],
        ),
      ),
    );
  }

  Widget _text(AppState state, ColorTheme theme) {
    final style = TextStyle(
      fontSize: state.bigTextSize,
      fontWeight: FontWeight.bold,
    );
    final content =
        state.bigTextContent.isEmpty ? ' ' : state.bigTextContent;
    if (theme.isGradient) {
      return ShaderMask(
        shaderCallback: (b) => theme.gradient.createShader(b),
        child: Text(content,
            style: style.copyWith(color: Colors.white),
            textAlign: TextAlign.center),
      );
    }
    return Text(content,
        style: style.copyWith(color: theme.singleColor),
        textAlign: TextAlign.center);
  }

  void _fullscreen(
      BuildContext context, AppState state, AppNotifier notifier) {
    Navigator.of(context).push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) =>
          _FullscreenPage(state: state),
    ));
  }
}

class _FullscreenPage extends StatefulWidget {
  final AppState state;
  const _FullscreenPage({required this.state});
  @override
  State<_FullscreenPage> createState() => _FullscreenPageState();
}

class _FullscreenPageState extends State<_FullscreenPage> {
  bool _showClose = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(
        const Duration(seconds: 3),
        () { if (mounted) setState(() => _showClose = false); });
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final theme = ColorTheme.find(state.bigTextColorId);
    final content =
        state.bigTextContent.isEmpty ? ' ' : state.bigTextContent;
    final style = TextStyle(
        fontSize: state.bigTextSize, fontWeight: FontWeight.bold);

    return GestureDetector(
      onTap: () => setState(() => _showClose = !_showClose),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: theme.isGradient
                  ? ShaderMask(
                      shaderCallback: (b) =>
                          theme.gradient.createShader(b),
                      child: Text(content,
                          style: style.copyWith(color: Colors.white),
                          textAlign: TextAlign.center))
                  : Text(content,
                      style: style.copyWith(color: theme.singleColor),
                      textAlign: TextAlign.center),
            ),
          ),
          if (_showClose)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.cancel,
                    color: Color(0xFF666666), size: 32),
                onPressed: () => Navigator.pop(context),
              ),
            ),
        ]),
      ),
    );
  }
}
