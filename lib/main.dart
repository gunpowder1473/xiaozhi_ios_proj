import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:xintong_ai/providers/theme_provider.dart';
import 'package:xintong_ai/providers/config_provider.dart';
import 'package:xintong_ai/providers/conversation_provider.dart';
import 'package:xintong_ai/providers/user_provider.dart';
import 'package:xintong_ai/screens/home_screen.dart';
import 'package:xintong_ai/screens/settings_screen.dart';
import 'package:xintong_ai/screens/chat_screen_fixed.dart';
import 'package:xintong_ai/utils/app_theme.dart';
import 'package:opus_flutter/opus_flutter.dart' as opus_flutter;
import 'package:opus_dart/opus_dart.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';
import 'package:xintong_ai/utils/audio_util.dart';
import 'package:intelligence/intelligence.dart';
import 'package:intelligence/model/representable.dart';

// 是否启用调试工具
const bool enableDebugTools = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 设置全局沉浸式导航栏
  await _setupSystemUI();

  // 设置状态栏颜色变化监听器，确保状态栏样式始终如一
  SystemChannels.lifecycle.setMessageHandler((msg) async {
    if (msg == AppLifecycleState.resumed.toString()) {
      // 应用回到前台时重新应用系统UI设置
      await _setupSystemUI();
    }
    return null;
  });

  // 设置高性能渲染
  // 启用SkSL预热，提高首次渲染性能
  await Future.delayed(const Duration(milliseconds: 50));
  PaintingBinding.instance.imageCache.maximumSize = 1000;
  // 增加图像缓存容量
  PaintingBinding.instance.imageCache.maximumSizeBytes =
      100 * 1024 * 1024; // 100 MB

  // 请求录音和存储权限
  await [Permission.microphone, Permission.storage].request();

  // 添加中文本地化支持
  timeago.setLocaleMessages('zh', timeago.ZhMessages());
  timeago.setDefaultLocale('zh');

  // 初始化Opus库
  try {
    initOpus(await opus_flutter.load());
    print('Opus初始化成功: ${getOpusVersion()}');
  } catch (e) {
    print('Opus初始化失败: $e');
  }

  // 初始化录音和播放器
  try {
    await AudioUtil.initRecorder();
    await AudioUtil.initPlayer();
    print('音频系统初始化成功');
  } catch (e) {
    print('音频系统初始化失败: $e');
  }

  // 初始化配置管理
  final configProvider = ConfigProvider();
  final userProvider = UserProvider();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: configProvider),
        ChangeNotifierProvider.value(value: userProvider),
        ChangeNotifierProvider(create: (_) => ConversationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

// 设置系统UI沉浸式效果
Future<void> _setupSystemUI() async {
  // 设置状态栏和导航栏透明
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  // iOS上设置为全屏显示但保留状态栏
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top],
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _intelligencePlugin = Intelligence();
  final _receivedItems = [];
  static final GoRouter _router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: 'home',
        builder: (BuildContext context, GoRouterState state) {
          return const HomeScreen();
        },
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (BuildContext context, GoRouterState state) {
          return const ChatScreenFixed();
        },
      ),]
  );

  @override
  void initState() {
    super.initState();
    unawaited(init());
  }

  Future<void> init() async {
    try {
      await _intelligencePlugin.populate(const [
        Representable(representation: '聊天', id: 'chat'),
      ]);
      _intelligencePlugin.selectionsStream().listen(_handleSelection);
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    }
  }

  void _handleSelection(String id) {
    setState(() {
      _receivedItems.add(id);
    });
    _MyAppState._router.push('/chat');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    // 路由配置

    return MaterialApp.router(
      title: 'AI_For_XinTong',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      routerConfig: _router,
      // 添加平滑滚动设置
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        // 启用物理滚动
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        // 确保所有平台都有滚动条和弹性效果
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown,
        },
      ),
    );
  }
}
