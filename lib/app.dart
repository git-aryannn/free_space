import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:free_space/presentation/providers/settings_provider.dart';
import 'package:free_space/core/router/app_router.dart';
import 'package:free_space/core/theme/app_theme.dart';

/// The root widget of the Free Space application.
///
/// Configures theming, routing, and reads global settings from Riverpod.
class FreeSpaceApp extends ConsumerWidget {
  const FreeSpaceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Free Space',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
