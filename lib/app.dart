import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/tracker/tracker_screen.dart';
import 'screens/stats/stats_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/user_detail_screen.dart';
import 'providers/prayer_provider.dart';
import 'providers/stats_provider.dart';

// ── Router ────────────────────────────────────────────────────────────────────

final _routerProvider = Provider<GoRouter>((ref) {
  final authStatus = ref.watch(isAuthenticatedProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == '/login';
      if (authStatus) {
        if (isLoggingIn) return '/home';
        return null;
      }
      // If not logged in, they must be on /login
      if (!isLoggingIn) return '/login';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            _ScaffoldWithNavBar(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/home',
              builder: (_, __) => const TrackerScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/stats',
              builder: (_, __) => const StatsScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/settings',
              builder: (_, __) => const SettingsScreen(),
              routes: [
                GoRoute(
                  path: 'admin',
                  builder: (_, __) => const AdminDashboardScreen(),
                  routes: [
                    GoRoute(
                      path: 'user/:userId',
                      builder: (context, state) {
                        final userId = state.pathParameters['userId']!;
                        final profile = state.extra as Map<String, dynamic>;
                        return UserDetailScreen(userId: userId, profile: profile);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ]),
        ],
      ),
    ],
  );
});

// ── Bottom Nav Shell ──────────────────────────────────────────────────────────

class _ScaffoldWithNavBar extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const _ScaffoldWithNavBar({required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(index,
            initialLocation: index == navigationShell.currentIndex),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: 'nav_home'.tr(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart_rounded),
            label: 'nav_statistics'.tr(),
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings_rounded),
            label: 'nav_settings'.tr(),
          ),
        ],
      ),
    );
  }
}

// ── App ───────────────────────────────────────────────────────────────────────

class SalahTrackerApp extends ConsumerWidget {
  const SalahTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for auth changes and sync data automatically.
    // This handles both login and app launch with existing session.
    ref.listen(sessionUserProvider, (previous, next) {
      if (next != null && previous != next) {
        // Run sync in the background
        Future.microtask(() async {
          await ref.read(prayerRepositoryProvider).syncFromRemote();
          // Invalidate to refresh UI
          ref.invalidate(dayPrayersProvider);
          ref.invalidate(statsProvider);
        });
      }
    });

    final router = ref.watch(_routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'app_name'.tr(),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
