import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'app.dart';
import 'providers/theme_provider.dart';
import 'services/notification_service.dart';

const _supabaseUrl = 'https://xpnsoabfznjlwiwcmrlf.supabase.co';
const _supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhwbnNvYWJmem5qbHdpd2NtcmxmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUxNjgyNTIsImV4cCI6MjA5MDc0NDI1Mn0.DDImy4LDepikeoYKTPhHmNaDHjfnFSJCX8LvBSvrjb4';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Easy localization
  await EasyLocalization.ensureInitialized();
  Intl.defaultLocale = 'en';

  // Supabase initialization
  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabaseAnonKey,
  );

  // Google Sign-In initialization required in 7.x+
  // serverClientId = Web OAuth 2.0 Client ID (required on Android to exchange tokens)
  await GoogleSignIn.instance.initialize(
    serverClientId:
        '766340410258-q79skk39410b42vum4e8lflvdobl0iig.apps.googleusercontent.com',
  );

  // Notification service initialization
  await NotificationService.instance.initialize();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('bn')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      useOnlyLangCode: true,
      child: const ProviderScope(
        child: _AppWithTheme(),
      ),
    ),
  );
}

class _AppWithTheme extends ConsumerStatefulWidget {
  const _AppWithTheme();

  @override
  ConsumerState<_AppWithTheme> createState() => _AppWithThemeState();
}

class _AppWithThemeState extends ConsumerState<_AppWithTheme> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(themeModeProvider.notifier).init();
      NotificationService.instance.scheduleDailyReminder();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const SalahTrackerApp();
  }
}
