import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/auth_service.dart';
import '../data/remote/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_provider.g.dart';

@riverpod
Stream<AuthState> authState(Ref ref) {
  return AuthService.instance.onAuthStateChange;
}

@riverpod
bool isAuthenticated(Ref ref) {
  final state = ref.watch(authStateProvider).asData?.value;
  return state?.session != null || AuthService.instance.currentUser != null;
}

@riverpod
User? sessionUser(Ref ref) {
  final state = ref.watch(authStateProvider).asData?.value;
  return state?.session?.user ?? AuthService.instance.currentUser;
}

@riverpod
String userRole(Ref ref) {
  // Watch sessionUser to reactively update role on login/logout
  final user = ref.watch(sessionUserProvider);
  if (user == null) return 'user';
  return SupabaseService.instance.getRole();
}

@riverpod
bool isAdmin(Ref ref) {
  final role = ref.watch(userRoleProvider);
  return role == 'admin';
}
