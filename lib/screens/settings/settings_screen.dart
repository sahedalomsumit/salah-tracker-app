import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
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
                  backgroundImage: user != null && user.userMetadata?['avatar_url'] != null
                      ? NetworkImage(user.userMetadata!['avatar_url'])
                      : null,
                  child: user != null && user.userMetadata?['avatar_url'] != null
                      ? null
                      : Text(
                          user?.email?.substring(0, 1).toUpperCase() ?? '?',
                          style: TextStyle(
                            color: user != null ? AppColors.lightText : AppColors.grey,
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
          const SizedBox(height: 48),
          Center(
            child: Text(
              '© ${DateTime.now().year} Sahed Alom Sumit \n   // Built with good vibes and clean code',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.grey.withValues(alpha: 0.5),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
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
