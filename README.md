# Aetheris Audio Player

Aetheris is a modern, unified music player application built with Flutter. It bridges the gap between local lossless audio playback and cloud-based streaming by integrating Spotify metadata with YouTube Music stream fallbacks. Aetheris is designed to deliver a premium listening experience with a sleek glassmorphism UI, real-time Firebase synchronization, and a robust serverless download manager.

## Key Features

### Unified Music Experience
* **Spotify Integration**: Full access to the Spotify catalog (Tracks, Albums, Artists, Playlists) via OAuth PKCE, complete with real-time recommendations based on your listening history.
* **Smart Audio Fallback**: When official Spotify playback is unavailable, Aetheris intelligently resolves exact-match audio streams via YouTube Music while retaining the original Spotify metadata and high-resolution artwork.
* **Local Lossless Support**: Natively plays local high-fidelity formats like FLAC and WAV. The player automatically prioritizes local lossless files if they match the online track currently selected.

### Seamless Cloud Sync
* **Firebase Real-time Sync**: Bi-directional synchronization for Playlists, Liked Songs, Saved Albums, Followed Artists, and Playback History across multiple devices.
* **Offline-First Architecture**: Functions smoothly without an internet connection. Changes made in offline mode will automatically synchronize to Firestore once the connection is restored.

### Advanced Download Manager
* **Serverless Architecture**: Downloads are processed entirely on the client device using Dart and FFmpegKit. No external backend is required.
* **Extensive Format Support**: Supports downloading and transcoding audio into multiple formats including MP3, AAC, OPUS, OGG, FLAC, and WAV.
* **Anti-Fake Lossless**: Strict quality reporting ensures that transcoded lossy sources are not falsely labeled as true lossless. The application flags true Hi-Res formats appropriately.

### Premium Audio Engine
* **Native Hardware Detection**: Automatically detects physical USB DACs and Bluetooth LDAC hardware on Android for a bit-perfect bypass.
* **System Integration**: Full support for Android MediaSession and Notification.MediaStyle, allowing control from the lock screen, connected wearables, and external Bluetooth devices.

---

## Architecture Overview

Aetheris utilizes a clean, service-oriented architecture to keep data fetching, state management, and UI rendering strictly decoupled.

* **State Management**: Handled natively using Riverpod for predictable and scalable state distribution.
* **Source Resolution**: The music engine queries the Spotify API for metadata, and dynamically fetches the optimal audio stream through the YouTube Music API (via `youtube_explode_dart`) if a local lossless source is not found.
* **Playback Engine**: Built on top of `just_audio` with a custom background isolation layer to handle gapless playback and queue management.

---

## Development Setup

### Prerequisites
* Flutter SDK (Version 3.19.0 or higher)
* Dart SDK (Version 3.3.0 or higher)
* Android Studio / Android SDK (for Android builds)

### 1. Firebase Configuration
Aetheris requires Firebase for user authentication and cross-device synchronization.
1. Create a project in the Firebase Console.
2. Enable Firebase Authentication (Email/Password and Google Sign-In).
3. Enable Cloud Firestore.
4. Download the `google-services.json` file and place it in the `android/app/` directory.

### 2. Spotify Developer Setup
1. Go to the Spotify Developer Dashboard.
2. Create a new Application.
3. Add your Android application package name and SHA-1 fingerprint.
4. Set the Redirect URI to match the intent filter in the Android manifest (e.g., `aetheris://spotify-login`).
5. Retrieve your Client ID and Client Secret.

### 3. Build Configuration
Run the project by injecting your API credentials via Dart compile-time variables.

```bash
flutter run \
  --dart-define=SPOTIFY_CLIENT_ID=your_client_id_here \
  --dart-define=SPOTIFY_CLIENT_SECRET=your_client_secret_here
```

To build a release APK for Android:

```bash
flutter build apk --release \
  --dart-define=SPOTIFY_CLIENT_ID=your_client_id_here \
  --dart-define=SPOTIFY_CLIENT_SECRET=your_client_secret_here
```

---

## Optional: Self-Hosted Lossless Backend

For users with a personal collection of lossless music, Aetheris supports connecting to a self-hosted backend to stream FLAC/WAV files remotely instead of relying on lossy stream fallbacks.

1. Navigate to the `lossless_backend/` directory.
2. Install Node.js dependencies using `npm install`.
3. Set your environment variables:
   * `MUSIC_DIR`: Path to your lossless music folder.
   * `API_KEY`: A custom secret key to authenticate your app requests.
4. Start the server using `npm start`.

To connect Aetheris to your backend, add the following flags when building:

```bash
  --dart-define=TIDAL_API_URL=http://your_server_ip:3977 \
  --dart-define=TIDAL_API_KEY=your_secret_key
```

---

## Disclaimer

Aetheris is an independent, non-commercial project created for educational purposes. It utilizes public APIs from Spotify and YouTube Music. The application does not bypass DRM protection, and it is the user's responsibility to ensure they comply with the terms of service of all connected third-party platforms.
