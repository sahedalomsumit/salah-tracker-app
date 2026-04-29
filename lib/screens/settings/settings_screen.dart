import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/app_info_provider.dart';
import '../../services/auth_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionUserProvider);
    final themeMode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final surfaceBg = isDark ? AppColors.surface1Dark : AppColors.surface1Light;
    final surfaceIcon =
        isDark ? AppColors.surface2Dark : AppColors.surface2Light;

    String themeModeLabel() {
      switch (themeMode) {
        case ThemeMode.dark:
          return 'settings_theme_dark'.tr();
        case ThemeMode.light:
          return 'settings_theme_light'.tr();
        default:
          return 'settings_theme_system'.tr();
      }
    }

    String currentLanguageLabel() {
      final locale = context.locale;
      return locale.languageCode == 'bn' ? 'বাংলা 🇧🇩' : 'English 🇬🇧';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('settings_title'.tr()),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          // ── User Profile ──────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surfaceBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColors.softEmerald.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: user != null
                      ? AppColors.softEmerald
                      : AppColors.grey.withValues(alpha: 0.2),
                  backgroundImage:
                      user != null && user.userMetadata?['avatar_url'] != null
                          ? NetworkImage(user.userMetadata!['avatar_url'])
                          : null,
                  child:
                      user != null && user.userMetadata?['avatar_url'] != null
                          ? null
                          : Text(
                              user?.email?.substring(0, 1).toUpperCase() ?? '?',
                              style: TextStyle(
                                color: user != null
                                    ? AppColors.lightText
                                    : AppColors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.email ?? 'offline_mode'.tr(),
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user != null
                            ? 'connected_cloud'.tr()
                            : 'sign_in_to_sync'.tr(),
                        style: TextStyle(color: AppColors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                if (user == null)
                  ElevatedButton(
                    onPressed: () => context.push('/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.softEmerald,
                      foregroundColor: AppColors.deepGreen,
                      minimumSize: const Size(80, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('settings_sign_in'.tr(),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ── App Settings ──────────────────────────────────────────────────
          Text(
            'settings_app_settings'.tr(),
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.softEmerald,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 12),

          // Language Tile
          _SettingsTile(
            icon: Icons.language_rounded,
            title: 'settings_language'.tr(),
            subtitle: currentLanguageLabel(),
            surfaceColor: surfaceIcon,
            onTap: () => _showLanguagePicker(context),
          ),

          // Theme Tile
          _SettingsTile(
            icon: Icons.palette_outlined,
            title: 'settings_theme'.tr(),
            subtitle: themeModeLabel(),
            surfaceColor: surfaceIcon,
            onTap: () => _showThemePicker(context, ref),
          ),

          const SizedBox(height: 40),

          // ── Account Section ───────────────────────────────────────────────
          Text(
            'settings_account'.tr(),
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.softEmerald,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          if (user != null)
            _SettingsTile(
              icon: Icons.logout_rounded,
              title: 'settings_sign_out'.tr(),
              subtitle: 'settings_sign_out_subtitle'.tr(),
              color: Colors.redAccent,
              surfaceColor: surfaceIcon,
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor:
                        isDark ? AppColors.surface2Dark : Colors.white,
                    title: Text('settings_sign_out'.tr()),
                    content: Text('settings_sign_out_confirm'.tr()),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('settings_sign_out_cancel'.tr(),
                            style: const TextStyle(color: AppColors.grey)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text('settings_sign_out'.tr(),
                            style: const TextStyle(color: Colors.redAccent)),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await AuthService.instance.signOut();
                }
              },
            )
          else
            _SettingsTile(
              icon: Icons.login_rounded,
              title: 'settings_sign_in'.tr(),
              subtitle: 'settings_sign_in_subtitle'.tr(),
              surfaceColor: surfaceIcon,
              onTap: () => context.push('/login'),
            ),
          const SizedBox(height: 40),

          // ── Sadaqah Section ───────────────────────────────────────────────
          Text(
            'settings_sadaqah'.tr(),
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.softEmerald,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surfaceBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: AppColors.softEmerald.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'settings_sadaqah_text'.tr(),
                  style: TextStyle(
                    color: AppColors.grey,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final uri = Uri.parse(
                              'https://donate.stripe.com/3cI8wO6bWcqd7F46az8AE01');
                          try {
                            // Try to launch external application directly (more reliable on modern Android)
                            final launched = await launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                            if (!launched && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('settings_donation_error'.tr())),
                              );
                            }
                          } catch (e) {
                            debugPrint('Error launching Stripe URL: $e');
                          }
                        },
                        icon: const Icon(Icons.payment_rounded, size: 20),
                        label: Text('settings_stripe'.tr()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF635BFF), // Stripe Color
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showBkashDialog(context);
                        },
                        icon: const Icon(Icons.send_rounded, size: 20),
                        label: Text('settings_bkash'.tr()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFFE2136E), // bKash Color
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // ── Admin Section ─────────────────────────────────────────────────
          if (ref.watch(isAdminProvider)) ...[
            Text(
              'nav_admin'.tr(),
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppColors.softEmerald,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            _SettingsTile(
              icon: Icons.admin_panel_settings_outlined,
              title: 'nav_admin'.tr(),
              subtitle: 'admin_manage_users'.tr(),
              surfaceColor: surfaceIcon,
              onTap: () => context.push('/settings/admin'),
            ),
            const SizedBox(height: 40),
          ],

          ref.watch(appVersionProvider).when(
                data: (version) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Center(
                    child: Text(
                      '${'settings_version'.tr()} $version',
                      style: TextStyle(
                        color: AppColors.grey.withValues(alpha: 0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                loading: () => const SizedBox(),
                error: (e, __) => const SizedBox(),
              ),
          Center(
            child: Text(
              '© ${DateTime.now().year} Sahed Alom Sumit',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.grey.withValues(alpha: 0.5),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(child: _BuiltWithFooter()),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showThemePicker(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surface2Dark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _ThemePickerSheet(ref: ref),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surface2Dark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => const _LanguagePickerSheet(),
    );
  }

  void _showBkashDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.surface2Dark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('settings_bkash_send_money'.tr(),
            textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/icon/bkash-icon.webp',
                width: 44,
                height: 44,
                errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 44,
                    color: Color(0xFFE2136E)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'settings_bkash_description'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.grey),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () {
                Clipboard.setData(const ClipboardData(text: '01773615582'));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('settings_bkash_copied'.tr()),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surface3Dark
                      : AppColors.surface2Light,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE2136E).withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      '01773615582',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Color(0xFFE2136E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'settings_bkash_tap_to_copy'.tr(),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('settings_close'.tr(),
                style: const TextStyle(color: AppColors.grey)),
          ),
        ],
      ),
    );
  }
}

// ── Theme Picker Sheet ────────────────────────────────────────────────────────

class _ThemePickerSheet extends StatelessWidget {
  final WidgetRef ref;

  const _ThemePickerSheet({required this.ref});

  @override
  Widget build(BuildContext context) {
    final currentMode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);

    final options = [
      (ThemeMode.dark, Icons.dark_mode_rounded, 'settings_theme_dark'.tr()),
      (ThemeMode.light, Icons.light_mode_rounded, 'settings_theme_light'.tr()),
      (
        ThemeMode.system,
        Icons.brightness_auto_rounded,
        'settings_theme_system'.tr()
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('settings_theme'.tr(), style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          ...options.map((opt) {
            final (mode, icon, label) = opt;
            final isSelected = currentMode == mode;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _PickerOption(
                icon: icon,
                label: label,
                isSelected: isSelected,
                onTap: () async {
                  await ref.read(themeModeProvider.notifier).setTheme(mode);
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Language Picker Sheet ─────────────────────────────────────────────────────

class _LanguagePickerSheet extends StatelessWidget {
  const _LanguagePickerSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentLocale = context.locale;

    final options = [
      (const Locale('en'), '🇬🇧', 'English'),
      (const Locale('bn'), '🇧🇩', 'বাংলা'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('settings_language'.tr(), style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          ...options.map((opt) {
            final (locale, flag, label) = opt;
            final isSelected =
                currentLocale.languageCode == locale.languageCode;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _PickerOption(
                flag: flag,
                label: label,
                isSelected: isSelected,
                onTap: () async {
                  await context.setLocale(locale);
                  Intl.defaultLocale = locale.toString();
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Shared Picker Option ──────────────────────────────────────────────────────

class _PickerOption extends StatelessWidget {
  final IconData? icon;
  final String? flag;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PickerOption({
    this.icon,
    this.flag,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.softEmerald.withValues(alpha: 0.18)
            : (isDark ? AppColors.surface3Dark : AppColors.surface2Light),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? AppColors.softEmerald : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                if (flag != null)
                  Text(flag!, style: const TextStyle(fontSize: 24))
                else if (icon != null)
                  Icon(icon,
                      color:
                          isSelected ? AppColors.softEmerald : AppColors.grey,
                      size: 22),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isSelected ? AppColors.softEmerald : null,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (isSelected)
                  const Icon(Icons.check_rounded,
                      color: AppColors.softEmerald, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Settings Tile ─────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? color;
  final Color? surfaceColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.surfaceColor,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color ?? AppColors.softEmerald, size: 22),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.grey, fontSize: 13),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.grey),
    );
  }
}

class _BuiltWithFooter extends StatefulWidget {
  const _BuiltWithFooter();

  @override
  State<_BuiltWithFooter> createState() => _BuiltWithFooterState();
}

class _BuiltWithFooterState extends State<_BuiltWithFooter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () async {
        final uri = Uri.parse('https://sahedalomsumit.com');
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (e) {
          debugPrint('Error launching developer URL: $e');
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'settings_built_with'.tr(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.grey.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            ScaleTransition(
              scale: _animation,
              child: const Icon(
                Icons.favorite_rounded,
                color: Color(0xFFEF4444),
                size: 16,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'settings_by'.tr(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.grey.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'Sahed',
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFFFF8719),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
