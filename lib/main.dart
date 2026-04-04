import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'viewmodels/app_viewmodel.dart';
import 'views/banner_view.dart';
import 'views/flashlight_view.dart';
import 'views/bigtext_view.dart';
import 'views/settings_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const ProviderScope(child: LEDBannerApp()));
}

class LEDBannerApp extends StatelessWidget {
  const LEDBannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LED Banner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C3AED),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A0A0F),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF0D0D18),
          selectedItemColor: Color(0xFF7C3AED),
          unselectedItemColor: Color(0xFF666666),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      home: const RootPage(),
    );
  }
}

// 注意：类名不以 _ 开头，避免私有类跨文件引用的潜在问题
class RootPage extends ConsumerWidget {
  const RootPage({super.key});

  static const _pages = <Widget>[
    BannerView(),
    FlashlightView(),
    BigTextView(),
    SettingsView(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(appProvider.select((s) => s.selectedTab));
    final notifier = ref.read(appProvider.notifier);

    return Scaffold(
      body: IndexedStack(
        index: selectedTab,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
              top: BorderSide(color: Color(0xFF1A1A2E), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: selectedTab,
          onTap: notifier.setSelectedTab,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.tv), label: '跑马灯'),
            BottomNavigationBarItem(
                icon: Icon(Icons.flashlight_on), label: '手电筒'),
            BottomNavigationBarItem(
                icon: Icon(Icons.text_fields), label: '大字幕'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: '设置'),
          ],
        ),
      ),
    );
  }
}
