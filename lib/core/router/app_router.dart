import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:free_space/presentation/screens/home/home_shell.dart';
import 'package:free_space/presentation/screens/home/dashboard_screen.dart';
import 'package:free_space/presentation/screens/temporary/temporary_screen.dart';
import 'package:free_space/presentation/screens/permanent/permanent_screen.dart';
import 'package:free_space/presentation/screens/bin/bin_screen.dart';
import 'package:free_space/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:free_space/presentation/screens/settings/settings_screen.dart';
import 'package:free_space/presentation/screens/inbox/inbox_screen.dart';
import 'package:free_space/presentation/providers/settings_provider.dart';

/// Provides the GoRouter configuration for the application.
final routerProvider = Provider<GoRouter>((ref) {
  final onboardingComplete =
      ref.watch(onboardingCompleteProvider).valueOrNull ?? false;

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      if (!onboardingComplete && state.matchedLocation != '/onboarding') {
        return '/onboarding';
      }
      if (onboardingComplete && state.matchedLocation == '/onboarding') {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/inbox',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const InboxScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SettingsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomeShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/temporary',
                builder: (context, state) => const TemporaryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/permanent',
                builder: (context, state) => const PermanentScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/bin',
                builder: (context, state) => const BinScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
