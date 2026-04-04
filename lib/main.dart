import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'app.dart';
import 'services/notification_service.dart';

const _supabaseUrl = 'https://xpnsoabfznjlwiwcmrlf.supabase.co';
const _supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhwbnNvYWJmem5qbHdpd2NtcmxmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUxNjgyNTIsImV4cCI6MjA5MDc0NDI1Mn0.DDImy4LDepikeoYKTPhHmNaDHjfnFSJCX8LvBSvrjb4';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase initialization
  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabaseAnonKey,
  );

  // Google Sign-In initialization required in 7.x+
  await GoogleSignIn.instance.initialize();

  // Notification service initialization
  await NotificationService.instance.initialize();

  runApp(
    const ProviderScope(
      child: SalahTrackerApp(),
    ),
  );
}
