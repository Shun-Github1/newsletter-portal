import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:window_manager/window_manager.dart';
import 'package:newsletter_portal/core/theme/app_theme.dart';
import 'package:newsletter_portal/core/router/app_router.dart';
import 'package:newsletter_portal/core/network/dio_client.dart';
import 'package:newsletter_portal/presentation/providers/theme_provider.dart';

import 'package:newsletter_portal/core/network/local_llm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  
  if (!kIsWeb) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1200, 800),
      minimumSize: Size(1200, 800),
      center: true,
      title: 'Newsletter Portal',
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  final dioClient = DioClient();
  await dioClient.init();

  runApp(
    ProviderScope(
      overrides: [
        dioClientProvider.overrideWithValue(dioClient),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(localLlmServiceProvider).startServer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    // Wrap in ExcludeSemantics to prevent Flutter from generating a semantics
    // tree, which eliminates "Failed to update ui::AXTree" errors on Windows.
    // This is safe for an internal desktop tool that doesn't need screen reader
    // support.
    return ExcludeSemantics(
      child: MaterialApp.router(
        title: 'Newsletter Portal',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
