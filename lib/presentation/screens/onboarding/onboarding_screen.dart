import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:free_space/presentation/providers/settings_provider.dart';
import 'package:free_space/presentation/providers/storage_provider.dart';
import 'package:free_space/presentation/providers/notification_provider.dart';
import 'package:free_space/presentation/widgets/item_action_helpers.dart';

/// The onboarding screen demonstrating app features and requesting permissions.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _checkingAccess = true;
  bool _requestingAccess = false;
  bool _storageAccessGranted = false;
  bool _notificationsGranted = false;

  @override
  void initState() {
    super.initState();
    _loadExistingStorageAccess();
  }

  Future<void> _loadExistingStorageAccess() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      if (mounted) setState(() => _checkingAccess = false);
      return;
    }
    try {
      final nativeService = ref.read(nativePlatformServiceProvider);
      final access = await Future.wait([
        nativeService.getScanRoot(),
        nativeService.hasAllFilesAccess(),
      ]);
      if (!mounted) return;
      setState(() {
        _storageAccessGranted = access[0] != null && access[1] == true;
        _checkingAccess = false;
      });
    } catch (_) {
      if (mounted) setState(() => _checkingAccess = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == 2 && !_storageAccessGranted) return;
    if (_currentPage == 3 && !_notificationsGranted) return;
    if (_currentPage < 3) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _getStarted();
    }
  }

  Future<void> _getStarted() async {
    if (!_storageAccessGranted || !_notificationsGranted) return;
    await ref.read(settingsRepositoryProvider).setOnboardingComplete();
    ref.invalidate(onboardingCompleteProvider);
    await ref.read(onboardingCompleteProvider.future);
    if (mounted) {
      context.go('/');
    }
  }

  Future<void> _requestStorageAccess() async {
    if (_requestingAccess) return;
    setState(() => _requestingAccess = true);
    try {
      final nativeService = ref.read(nativePlatformServiceProvider);
      final granted = await ensureAllFilesAccess(context, ref);
      if (!mounted) return;
      if (!granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Storage access is required to continue.')),
        );
        return;
      }

      // Default to Downloads folder natively to avoid SAF privacy block
      final downloadsPath = await nativeService.getDownloadsPath();
      await nativeService.setScanRoot(downloadsPath);

      setState(() => _storageAccessGranted = true);
      _nextPage();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not grant storage access: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _requestingAccess = false);
    }
  }

  Future<void> _requestNotificationsAccess() async {
    if (_requestingAccess) return;
    setState(() => _requestingAccess = true);
    try {
      final granted =
          await ref.read(notificationServiceProvider).requestPermission();
      if (!mounted) return;
      if (!granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification access is required to continue.'),
          ),
        );
        return;
      }
      setState(() => _notificationsGranted = true);
      _nextPage();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Could not grant notification access: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _requestingAccess = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              _buildWelcomePage(),
              _buildHowItWorksPage(),
              _buildPermissionPage(
                icon: Icons.folder,
                title: 'Storage Access',
                description:
                    'Allow Free Space to manage shared files on your device. Android requires this access to automatically scan your Downloads and manage files securely.',
                buttonText: 'Grant Access',
                granted: _storageAccessGranted,
                busy: _checkingAccess || _requestingAccess,
                onPressed: _requestStorageAccess,
              ),
              _buildPermissionPage(
                icon: Icons.notifications,
                title: 'Notifications',
                description: 'Allow notifications for automatic Bin alerts.',
                buttonText: 'Enable Notifications',
                granted: _notificationsGranted,
                busy: _requestingAccess,
                onPressed: _requestNotificationsAccess,
              ),
            ],
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) => _buildDot(index)),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _checkingAccess ||
                          (_currentPage == 2 && !_storageAccessGranted) ||
                          (_currentPage == 3 && !_notificationsGranted)
                      ? null
                      : _currentPage == 3
                          ? _getStarted
                          : _nextPage,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentPage == 3 ? 'Get Started' : 'Next',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomePage() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      color: theme.scaffoldBackgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.0),
            duration: const Duration(seconds: 1),
            curve: Curves.elasticOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Icon(
                  Icons.cleaning_services_rounded,
                  size: 100,
                  color: colorScheme.primary,
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          Text(
            'Welcome to Free Space',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Declutter your device automatically with smart tracking and easy file management.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 100), // Space for bottom controls
        ],
      ),
    );
  }

  Widget _buildHowItWorksPage() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.autorenew, size: 80, color: colorScheme.primary),
          const SizedBox(height: 32),
          Text(
            'How it works',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          _buildStepRow(
            icon: Icons.all_inbox,
            title: '1. Permanent',
            desc: 'Unused files drop down to Temporary after a few days.',
            color: colorScheme.primary,
          ),
          const SizedBox(height: 16),
          _buildStepRow(
            icon: Icons.hourglass_bottom,
            title: '2. Temporary',
            desc: 'Files wait here. If unused for 30 days, they move to Bin.',
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildStepRow(
            icon: Icons.delete_outline,
            title: '3. System Bin',
            desc: 'Safely binned. Deleted forever only when OS limit hits.',
            color: Colors.red,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildStepRow(
      {required IconData icon,
      required String title,
      required String desc,
      required Color color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(desc, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionPage({
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required bool granted,
    required bool busy,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 80,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          Text(
            title,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          FilledButton.tonalIcon(
            onPressed: granted || busy ? null : onPressed,
            icon: busy
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(granted ? Icons.check_circle : icon),
            style: FilledButton.styleFrom(
              minimumSize: const Size(200, 48),
            ),
            label: Text(granted ? 'Access granted' : buttonText),
          ),
          const SizedBox(height: 100), // Space for bottom controls
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
