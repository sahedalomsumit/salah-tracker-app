import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class StatsPaginationHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final VoidCallback onForward;
  final bool isForwardEnabled;

  const StatsPaginationHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onBack,
    required this.onForward,
    this.isForwardEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleMedium),
              Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.grey)),
            ],
          ),
        ),
        Row(
          children: [
            _IconButton(
              icon: Icons.chevron_left_rounded,
              onPressed: onBack,
              enabled: true,
            ),
            const SizedBox(width: 4),
            _IconButton(
              icon: Icons.chevron_right_rounded,
              onPressed: onForward,
              enabled: isForwardEnabled,
            ),
          ],
        ),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool enabled;

  const _IconButton({
    required this.icon,
    required this.onPressed,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: enabled ? AppColors.softEmerald : AppColors.grey.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}
