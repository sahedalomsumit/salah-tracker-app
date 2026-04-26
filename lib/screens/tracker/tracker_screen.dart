import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/prayer_record.dart';
import '../../providers/prayer_provider.dart';

class TrackerScreen extends ConsumerWidget {
  const TrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final prayersAsync = ref.watch(dayPrayersProvider);
    final notifier = ref.read(dayPrayersProvider.notifier);
    final isToday = SalahDateUtils.isToday(SalahDateUtils.toKey(selectedDate));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Date Header ──────────────────────────────────────────────────
            _DateHeader(
              date: selectedDate,
              isToday: isToday,
              onPrev: notifier.previousDay,
              onNext: notifier.nextDay,
              onToday: notifier.goToToday,
            ),

            const SizedBox(height: 8),

            // ── Prayer Cards ─────────────────────────────────────────────────
            Expanded(
              child: prayersAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.softEmerald),
                ),
                error: (e, _) => Center(
                  child: Text('error_loading_prayers'.tr(args: [e.toString()])),
                ),
                data: (records) => RefreshIndicator(
                  onRefresh: () => ref.read(dayPrayersProvider.notifier).refresh(),
                  color: AppColors.softEmerald,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: records.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final record = records[i];
                      return GlassPrayerCard(
                        index: i,
                        record: record,
                        date: selectedDate,
                        onTap: () => _showStatusSheet(context, ref, record, selectedDate),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusSheet(
      BuildContext context, WidgetRef ref, PrayerRecord record, DateTime date) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor:
          isDark ? AppColors.surface2Dark : AppColors.surface2Light,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _StatusSheet(record: record, ref: ref, date: date),
    );
  }
}

// ── Glass Prayer Card ─────────────────────────────────────────────────────────

class GlassPrayerCard extends StatelessWidget {
  final int index;
  final PrayerRecord record;
  final DateTime date;
  final VoidCallback onTap;

  const GlassPrayerCard({
    super.key,
    required this.index,
    required this.record,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final status = record.status;
    final statusColor = status.color;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: status == PrayerStatus.none
              ? (isDark ? AppColors.glassBorder : AppColors.lightGlassBorder)
              : statusColor.withValues(alpha: 0.45),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: isDark ? 0.08 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.glassCard : AppColors.lightGlassCard,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(18),
                splashColor: statusColor.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 18),
                  child: Row(
                    children: [
                      // Prayer icon container
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.deepGreen
                              : AppColors.surface2Light,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.softEmerald.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Icon(
                          kPrayerIcons[index],
                          color: AppColors.softEmerald,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Prayer name + arabic
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (index == 1 && date.weekday == DateTime.friday)
                                  ? 'prayer_jummah'.tr()
                                  : kPrayerKeys[index].tr(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              (index == 1 && date.weekday == DateTime.friday)
                                  ? kJummahArabic
                                  : kPrayerArabic[index],
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Status pill
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: statusColor.withValues(alpha: 0.3),
                              width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(status.icon, color: statusColor, size: 15),
                            const SizedBox(width: 5),
                            Text(
                              status.labelKey.tr(),
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Date Header Widget ────────────────────────────────────────────────────────

class _DateHeader extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onToday;

  const _DateHeader({
    required this.date,
    required this.isToday,
    required this.onPrev,
    required this.onNext,
    required this.onToday,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, size: 28),
                onPressed: onPrev,
                tooltip: 'tooltip_prev_day'.tr(),
              ),
              GestureDetector(
                onTap: isToday ? null : onToday,
                child: Column(
                  children: [
                    Text(
                      isToday ? 'date_today'.tr() : SalahDateUtils.shortDate(date),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: isToday
                            ? AppColors.softEmerald
                            : null,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      SalahDateUtils.displayDate(date),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.chevron_right_rounded,
                  size: 28,
                  color: isToday ? AppColors.grey : null,
                ),
                onPressed: isToday ? null : onNext,
                tooltip: 'tooltip_next_day'.tr(),
              ),
            ],
          ),
          if (!isToday) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onToday,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.softEmerald.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.softEmerald.withValues(alpha: 0.4)),
                ),
                child: Text(
                  'date_back_to_today'.tr(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.softEmerald,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Status Bottom Sheet ───────────────────────────────────────────────────────

class _StatusSheet extends ConsumerWidget {
  final PrayerRecord record;
  final WidgetRef ref;
  final DateTime date;

  const _StatusSheet({required this.record, required this.ref, required this.date});

  static const _statuses = [
    PrayerStatus.onTime,
    PrayerStatus.qaza,
    PrayerStatus.missed,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
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
          Text(
            (record.prayerName == 'Dhuhr' && date.weekday == DateTime.friday)
                ? 'prayer_jummah'.tr()
                : kPrayerKeys[kPrayerNames.indexOf(record.prayerName)].tr(),
            style: theme.textTheme.headlineMedium,
          ),
          Text(
            'status_select'.tr(),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 20),
          ...List.generate(_statuses.length, (i) {
            final s = _statuses[i];
            final isSelected = record.status == s;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _StatusOption(
                status: s,
                isSelected: isSelected,
                onTap: () async {
                  await ref
                      .read(dayPrayersProvider.notifier)
                      .updateStatus(record.prayerName, s);
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

class _StatusOption extends StatelessWidget {
  final PrayerStatus status;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusOption({
    required this.status,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = status.color;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected
            ? color.withValues(alpha: 0.2)
            : (isDark ? AppColors.surface3Dark : AppColors.surface2Light),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? color : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(status.icon, color: color, size: 22),
                const SizedBox(width: 16),
                Text(
                  status.labelKey.tr(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isSelected ? color : null,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (isSelected) Icon(Icons.check_rounded, color: color, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
