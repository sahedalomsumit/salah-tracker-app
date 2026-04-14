import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/remote/supabase_service.dart';
import '../../data/models/prayer_record.dart';
import '../../core/constants/app_constants.dart';

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

  Future<void> _deleteRecord(PrayerRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete the ${record.prayerName} record for ${record.date}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (record.id != null) {
        await SupabaseService.instance.deleteRecord(record.id!);
        _loadUserRecords();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullName = widget.profile['full_name'] ?? 'Unknown User';

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
              ? const Center(child: Text('No records found for this user'))
              : ListView.builder(
                  itemCount: _records.length,
                  itemBuilder: (context, index) {
                    final record = _records[index];
                    return ListTile(
                      title: Text('${record.prayerName} - ${record.date}'),
                      subtitle: Text('Status: ${record.status.label}'),
                      leading: Icon(record.status.icon, color: record.status.color),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.grey),
                        onPressed: () => _deleteRecord(record),
                      ),
                    );
                  },
                ),
    );
  }
}
