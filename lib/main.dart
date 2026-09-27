// import 'package:example/src/platform_menu.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mssh/src/appstate.dart';
import 'package:mssh/src/layout.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(1200, 800),
    minimumSize: Size(800, 600),
    center: true,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  runApp(MyApp());
}

bool get isDesktop {
  if (kIsWeb) return false;
  return [
    TargetPlatform.windows,
    TargetPlatform.linux,
    TargetPlatform.macOS,
  ].contains(defaultTargetPlatform);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Appstate()),
        ChangeNotifierProvider(create: (context) => FiletreeState()),
        ChangeNotifierProvider(create: (context) => TagItemState()),
        ChangeNotifierProvider(create: (context) => SidebarState()),
        ChangeNotifierProvider(create: (context) => AppThemeState()), // 主题状态
        ChangeNotifierProvider(create: (context) => ProfilerState()), // 监控侧边栏
        ChangeNotifierProvider(
          create: (context) {
            var quickConnectState = QuickConnectState();
            quickConnectState.jsonToState();
            return quickConnectState;
          },
        ),
      ],
      child: Consumer<AppThemeState>(
        builder: (context, value, _) => MaterialApp(
          title: 'xterm2 demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            // 设置字体颜色
            colorScheme: ColorScheme.fromSeed(
              seedColor: value.primary,
            ).copyWith(onSurface: value.textPrimary),
            fontFamily: 'AlibabaPuHuiTi',
            fontFamilyFallback: const [
              'PingFang SC', // 兜底：macOS/iOS 中文
              'Microsoft YaHei', // 兜底：Windows 中文
              'Source Han Sans', // 兜底：Android/Linux 中文
            ],
          ),
          home: Scaffold(backgroundColor: value.bgBase, body: Layout()),
        ),
      ),
    );
  }
}
