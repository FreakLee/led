import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:torch_light/torch_light.dart';
import '../models/models.dart';
import '../viewmodels/app_viewmodel.dart';
import 'widgets/section_label.dart';

class FlashlightView extends ConsumerStatefulWidget {
  const FlashlightView({super.key});
  @override
  ConsumerState<FlashlightView> createState() => _FlashlightViewState();
}

class _FlashlightViewState extends ConsumerState<FlashlightView> {
  bool _isOn = false;
  bool _torchAvailable = false; // 模拟器上为 false
  Timer? _timer;
  int _sosIdx = 0;

  static const _sosTiming = [
    200, 200, 200, 200, 200, 600,
    600, 200, 600, 200, 600, 600,
    200, 200, 200, 200, 200, 1200,
  ];

  @override
  void initState() {
    super.initState();
    // 异步检测设备是否支持手电筒（模拟器不支持）
    _checkTorchAvailability();
  }

  Future<void> _checkTorchAvailability() async {
    try {
      await TorchLight.enableTorch();
      await TorchLight.disableTorch();
      if (mounted) setState(() => _torchAvailable = true);
    } catch (_) {
      // 模拟器或无摄像头设备：静默处理，退化为纯 UI 演示
      if (mounted) setState(() => _torchAvailable = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _rawDisableTorch();
    super.dispose();
  }

  // Bug 2 修复：所有 torch 操作全部 try/catch 包裹
  // 模拟器上抛异常不影响 UI 状态，不会卡死
  Future<void> _rawEnableTorch() async {
    try { await TorchLight.enableTorch(); } catch (_) {}
  }

  Future<void> _rawDisableTorch() async {
    try { await TorchLight.disableTorch(); } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final strobeMode = ref.watch(appProvider.select((s) => s.strobeMode));
    final notifier = ref.read(appProvider.notifier);

    return Scaffold(
      backgroundColor: _isOn ? const Color(0xFFF2F2F2) : Colors.black,
      appBar: AppBar(
        backgroundColor:
            _isOn ? const Color(0xFFF2F2F2) : const Color(0xFF0A0A0F),
        title: Text('手电筒',
            style: TextStyle(color: _isOn ? Colors.black : Colors.white)),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 模拟器提示
            if (!_torchAvailable)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.4)),
                ),
                child: const Text(
                  '模拟器不支持手电筒，UI 演示模式',
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                ),
              ),

            Text(_isOn ? '手电筒已开启' : '点击开启手电筒',
                style: TextStyle(
                    fontSize: 15,
                    color: _isOn ? Colors.black45 : Colors.grey)),
            const SizedBox(height: 24),

            // 主按钮
            GestureDetector(
              onTap: _toggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isOn
                      ? const Color(0xFFFFD700)
                      : const Color(0xFF1A1A1A),
                  boxShadow: _isOn
                      ? [
                          BoxShadow(
                              color: Colors.yellow.withOpacity(0.4),
                              blurRadius: 40,
                              spreadRadius: 10)
                        ]
                      : [],
                ),
                child: Icon(
                  _isOn ? Icons.flashlight_on : Icons.flashlight_off,
                  size: 44,
                  color: _isOn ? Colors.black87 : Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // 频闪模式
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionLabel('频闪模式'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: StrobeMode.values.map((mode) {
                      final active = strobeMode == mode;
                      return GestureDetector(
                        onTap: () => _setStrobe(mode, notifier),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: active
                                ? (_isOn
                                    ? Colors.black12
                                    : const Color(0xFF1A1A1A))
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: active
                                  ? (_isOn
                                      ? Colors.black38
                                      : const Color(0xFF7C3AED))
                                  : const Color(0xFF333333),
                            ),
                          ),
                          child: Text(mode.label,
                              style: TextStyle(
                                  fontSize: 13,
                                  color: active
                                      ? (_isOn
                                          ? Colors.black87
                                          : const Color(0xFF7C3AED))
                                      : (_isOn
                                          ? Colors.black38
                                          : Colors.grey))),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const Spacer(),
            Text('注意：长时间使用会消耗电量',
                style: TextStyle(
                    fontSize: 11,
                    color: _isOn
                        ? Colors.black26
                        : const Color(0xFF333333))),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Bug 2 修复：toggle 先更新 UI 状态，再异步操作 torch
  // 即使 torch 操作失败，UI 也已经切换，不会卡死
  void _toggle() {
    if (_isOn) {
      _turnOff();
    } else {
      _turnOn();
    }
  }

  void _turnOn() {
    // 先更新 UI（同步）
    setState(() => _isOn = true);
    // 再操作硬件（异步，失败不影响 UI）
    _rawEnableTorch();
    _applyStrobe(ref.read(appProvider).strobeMode);
  }

  void _turnOff() {
    // 先停 timer，再更新 UI，最后操作硬件
    _timer?.cancel();
    _timer = null;
    setState(() => _isOn = false);
    _rawDisableTorch();
  }

  void _setStrobe(StrobeMode mode, AppNotifier notifier) {
    notifier.setStrobeMode(mode);
    _timer?.cancel();
    _timer = null;
    if (_isOn) _applyStrobe(mode);
  }

  void _applyStrobe(StrobeMode mode) {
    _timer?.cancel();
    _timer = null;

    switch (mode) {
      case StrobeMode.off:
      case StrobeMode.steady:
        _rawEnableTorch();

      case StrobeMode.slow:
        _strobeFlash(const Duration(milliseconds: 500));

      case StrobeMode.fast:
        _strobeFlash(const Duration(milliseconds: 80));

      case StrobeMode.sos:
        _sosIdx = 0;
        _scheduleSOS();
    }
  }

  void _strobeFlash(Duration interval) {
    bool torchOn = true;
    _timer = Timer.periodic(interval, (_) {
      // Bug 2 修复：每次都检查 mounted，避免 dispose 后回调
      if (!mounted) return;
      torchOn ? _rawEnableTorch() : _rawDisableTorch();
      torchOn = !torchOn;
    });
  }

  void _scheduleSOS() {
    if (!mounted) return;
    final ms = _sosTiming[_sosIdx];
    _sosIdx % 2 == 0 ? _rawEnableTorch() : _rawDisableTorch();
    _timer = Timer(Duration(milliseconds: ms), () {
      if (!mounted) return;
      _sosIdx = (_sosIdx + 1) % _sosTiming.length;
      _scheduleSOS();
    });
  }
}
