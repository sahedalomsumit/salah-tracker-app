import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/remote/supabase_service.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  List<Map<String, dynamic>> _profiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    setState(() => _isLoading = true);
    final profiles = await SupabaseService.instance.fetchAllProfiles();
    setState(() {
      _profiles = profiles;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('admin_dashboard'.tr()),
        actions: [
          IconButton(
            onPressed: _loadProfiles,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profiles.isEmpty
              ? Center(child: Text('admin_no_users'.tr()))
              : ListView.builder(
                  itemCount: _profiles.length,
                  itemBuilder: (context, index) {
                    final profile = _profiles[index];
                    final fullName = profile['full_name'] ?? 'admin_unknown_user'.tr();
                    final avatarUrl = profile['avatar_url'];
                    final role = profile['role'] ?? 'user';
                    final userId = profile['id'];

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                        child: avatarUrl == null ? const Icon(Icons.person) : null,
                      ),
                      title: Text(fullName),
                      subtitle: Text('admin_role'.tr(args: [role])),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        context.push('/settings/admin/user/$userId', extra: profile);
                      },
                    );
                  },
                ),
    );
  }
}
