import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionUserProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          // ── User Profile ──────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface1,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: user != null ? AppColors.softEmerald : AppColors.grey.withValues(alpha: 0.2),
                  child: Text(
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
                        user?.email ?? 'Offline Mode',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user != null ? 'Connected to Cloud' : 'Sign in to sync your data',
                        style: const TextStyle(color: AppColors.grey, fontSize: 13),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // ── App Settings ──────────────────────────────────────────────────
          Text(
            'App Settings',
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.softEmerald,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.notifications_none_rounded,
            title: 'Prayer Notifications',
            subtitle: 'Reminders for each salah',
            trailing: Switch(
              value: true,
              onChanged: (val) {},
              activeThumbColor: AppColors.softEmerald,
            ),
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.language_rounded,
            title: 'Language',
            subtitle: 'English',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Theme',
            subtitle: 'System default',
            onTap: () {},
          ),
          const SizedBox(height: 40),

          // ── Account Section ───────────────────────────────────────────────
          Text(
            'Account',
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
              title: 'Sign Out',
              subtitle: 'Disconnect from Supabase',
              color: Colors.redAccent,
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: AppColors.surface2,
                    title: const Text('Sign Out'),
                    content: const Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel', style: TextStyle(color: AppColors.grey)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Sign Out', style: TextStyle(color: Colors.redAccent)),
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
              title: 'Sign In',
              subtitle: 'Cloud sync & backup',
              onTap: () => context.push('/login'),
            ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;
  final Color? color;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface1,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color ?? AppColors.softEmerald, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.grey, fontSize: 13),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: AppColors.grey),
    );
  }
}
