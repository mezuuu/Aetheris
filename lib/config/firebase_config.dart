import 'package:firebase_core/firebase_core.dart';

/// Firebase configuration for Aetheris.
///
/// HOW TO SET UP:
/// 1. Go to https://console.firebase.google.com
/// 2. Create a new project named "Aetheris"
/// 3. Add an Android app with package name: com.mezuu.aetheris.player
/// 4. Download google-services.json → place it in android/app/
/// 5. Copy the values from google-services.json into this file
/// 6. Enable Authentication (Email/Password + Google) in Firebase Console
/// 7. Enable Cloud Firestore in Firebase Console
///
/// IMPORTANT: Do NOT commit real values to version control.
/// Use environment variables or a .env file for production.
class FirebaseConfig {
  FirebaseConfig._();

  /// Whether Firebase has been configured.
  /// Set to `true` after filling in the values below.
  static const bool isConfigured = true;

  /// Firebase options for Android.
  /// Fill these from your google-services.json file.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCaSDqhbq_ccRZvfsEmykajQedwqLiF_XE',
    appId: '1:399687106219:android:ff5d2544da09265e9681ee',
    messagingSenderId: '399687106219',
    projectId: 'aetheris-68452',
    storageBucket: 'aetheris-68452.firebasestorage.app',
  );

  /// Get the appropriate options for the current platform.
  static FirebaseOptions get currentPlatform => android;
}
