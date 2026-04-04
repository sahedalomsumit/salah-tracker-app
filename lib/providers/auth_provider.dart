import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/auth_service.dart';
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
