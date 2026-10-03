import re

with open("lib/core/router/app_router.dart", "r") as f:
    content = f.read()

if "import '../../presentation/screens/inbox/inbox_screen.dart';" not in content:
    content = content.replace(
        "import '../../presentation/screens/settings/settings_screen.dart';",
        "import '../../presentation/screens/settings/settings_screen.dart';\nimport '../../presentation/screens/inbox/inbox_screen.dart';"
    )

target = r'''      GoRoute\(
        path: '/settings',
        pageBuilder: \(context, state\) => CustomTransitionPage\('''

replacement = r'''      GoRoute(
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
        pageBuilder: (context, state) => CustomTransitionPage('''

content = re.sub(target, replacement, content)

with open("lib/core/router/app_router.dart", "w") as f:
    f.write(content)

