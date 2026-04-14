import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../data/remote/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authStateProvider = StreamProvider<AuthState>((ref) {
  return AuthService.instance.onAuthStateChange;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final state = ref.watch(authStateProvider).asData?.value;
  return state?.session != null || AuthService.instance.currentUser != null;
});

final sessionUserProvider = Provider<User?>((ref) {
  final state = ref.watch(authStateProvider).asData?.value;
  return state?.session?.user ?? AuthService.instance.currentUser;
});

final userRoleProvider = FutureProvider<String>((ref) async {
  final user = ref.watch(sessionUserProvider);
  if (user == null) return 'user';
  return SupabaseService.instance.getRole(user.id);
});

final isAdminProvider = Provider<bool>((ref) {
  final role = ref.watch(userRoleProvider).asData?.value;
  return role == 'admin';
});
