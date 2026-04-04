import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final SupabaseClient _supabase = Supabase.instance.client;

  // Uses singleton instance instead of constructor in 7.x+
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  /// Initiate Google Sign-In flow
  Future<AuthResponse> signInWithIdToken() async {
    try {
      // Replaced signIn() with authenticate() in 7.x
      final googleUser = await _googleSignIn.authenticate();
      // In 7.x, authenticate() might throw or return a non-null account if successful.
      // If the lint says it can't be null, we remove the check or handle it differently.

      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'No Google ID Token found.';
      }

      // Pass idToken to Supabase (accessToken is optional/separated in 7.x)
      return _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out from both Google and Supabase
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _supabase.auth.signOut();
  }

  /// Current user
  User? get currentUser => _supabase.auth.currentUser;

  /// Stream of auth state changes
  Stream<AuthState> get onAuthStateChange => _supabase.auth.onAuthStateChange;
}
