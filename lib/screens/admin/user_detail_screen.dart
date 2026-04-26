import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/remote/supabase_service.dart';
import '../../data/models/prayer_record.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart';

class UserDetailScreen extends ConsumerStatefulWidget {
  final String userId;
  final Map<String, dynamic> profile;

  const UserDetailScreen({
    super.key,
    required this.userId,
    required this.profile,
  });

  @override
  ConsumerState<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends ConsumerState<UserDetailScreen> {
  List<PrayerRecord> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserRecords();
  }

  Future<void> _loadUserRecords() async {
    setState(() => _isLoading = true);
    final records = await SupabaseService.instance.fetchByUserId(widget.userId);
    setState(() {
      _records = records;
      _isLoading = false;
    });
  }

  Future<void> _resetRecord(PrayerRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('admin_confirm_reset'.tr()),
        content: Text('admin_reset_desc'.tr(args: [
          SalahDateUtils.getPrayerDisplayName(record.prayerName, record.date),
          record.date
        ])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('settings_sign_out_cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: Text('admin_reset'.tr()),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await SupabaseService.instance.adminDeleteRecord(
        userId: widget.userId,
        date: record.date,
        prayerName: record.prayerName,
      );
      _loadUserRecords();
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullName = widget.profile['full_name'] ?? 'admin_unknown_user'.tr();

    return Scaffold(
      appBar: AppBar(
        title: Text(fullName),
        actions: [
          IconButton(
            onPressed: _loadUserRecords,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
              ? Center(child: Text('admin_no_records'.tr()))
              : ListView.builder(
                  itemCount: _records.length,
                  itemBuilder: (context, index) {
                    final record = _records[index];
                    return ListTile(
                      title: Text('${SalahDateUtils.getPrayerDisplayName(record.prayerName, record.date)} - ${record.date}'),
                      subtitle: Text('admin_status'.tr(args: [record.status.labelKey.tr()])),
                      leading: Icon(record.status.icon, color: record.status.color),
                      trailing: IconButton(
                        icon: const Icon(Icons.history_rounded, color: Colors.grey),
                        onPressed: () => _resetRecord(record),
                        tooltip: 'admin_reset_tooltip'.tr(),
                      ),
                    );
                  },
                ),
    );
  }
}
