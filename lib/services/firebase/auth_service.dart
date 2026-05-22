import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

// ---------------------------------------------------------------------------
// Firebase Authentication Service
// ---------------------------------------------------------------------------

/// Wraps Firebase Auth for email/password and Google Sign-In.
///
/// Designed to be a singleton provided via Riverpod.
/// All methods are safe to call even when Firebase is not configured —
/// they will throw a descriptive error instead of crashing.
class AuthService extends ChangeNotifier {
  AuthService({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
      : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  /// Current authenticated user (null if signed out).
  User? get currentUser => _auth.currentUser;

  /// Whether a user is currently signed in.
  bool get isSignedIn => _auth.currentUser != null;

  /// UID shorthand.
  String? get uid => _auth.currentUser?.uid;

  /// Stream of auth state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // -------------------------------------------------------------------------
  // Email / Password
  // -------------------------------------------------------------------------

  /// Create a new account with email and password.
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (displayName != null && displayName.isNotEmpty) {
        await credential.user?.updateDisplayName(displayName);
      }
      notifyListeners();
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    }
  }

  /// Sign in with email and password.
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      notifyListeners();
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    }
  }

  // -------------------------------------------------------------------------
  // Google Sign-In
  // -------------------------------------------------------------------------

  /// Sign in with Google.
  Future<User?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      notifyListeners();
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException.fromFirebase(e);
    }
  }

  // -------------------------------------------------------------------------
  // Profile
  // -------------------------------------------------------------------------

  /// Update the user's display name.
  Future<void> updateDisplayName(String name) async {
    await _auth.currentUser?.updateDisplayName(name);
    notifyListeners();
  }

  /// Send a password reset email.
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // -------------------------------------------------------------------------
  // Sign Out
  // -------------------------------------------------------------------------

  /// Sign out from all providers.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    notifyListeners();
  }
}

// ---------------------------------------------------------------------------
// Auth Exception
// ---------------------------------------------------------------------------

/// Human-readable authentication error.
class AuthException implements Exception {
  const AuthException(this.message, {this.code = ''});

  factory AuthException.fromFirebase(FirebaseAuthException e) {
    final message = switch (e.code) {
      'email-already-in-use' => 'This email is already registered.',
      'invalid-email' => 'Invalid email address.',
      'weak-password' => 'Password is too weak (min 6 characters).',
      'user-not-found' => 'No account found with this email.',
      'wrong-password' => 'Incorrect password.',
      'user-disabled' => 'This account has been disabled.',
      'too-many-requests' => 'Too many attempts. Please try again later.',
      'operation-not-allowed' => 'This sign-in method is not enabled.',
      'network-request-failed' => 'Network error. Check your connection.',
      _ => e.message ?? 'Authentication failed.',
    };
    return AuthException(message, code: e.code);
  }

  final String message;
  final String code;

  @override
  String toString() => message;
}
