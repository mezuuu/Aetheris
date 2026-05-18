# Aetheris Streaming Catalog

Run the app with an online catalog:

```powershell
flutter run --dart-define=AETHERIS_CATALOG_URL=https://your-domain.example/catalog.json
```

Expected catalog shape:

```json
{
  "tracks": [
    {
      "id": "track-1",
      "title": "Track Title",
      "artist": "Artist Name",
      "album": "Album Title",
      "format": "AAC",
      "bitDepth": 16,
      "sampleRateKhz": 44,
      "durationMs": 213000,
      "streamUrl": "https://your-cdn.example/audio/track-1.m4a",
      "artworkUrl": "https://your-cdn.example/art/track-1.jpg",
      "coverColors": ["#0F273F", "#8C5B7D", "#101422"],
      "lyrics": ["First line", "Second line"],
      "isBitPerfect": false,
      "playCount": 0
    }
  ],
  "albums": [
    {
      "id": "album-1",
      "title": "Album Title",
      "artist": "Artist Name",
      "description": "Album description",
      "trackIds": ["track-1"]
    }
  ]
}
```

Rules:

- `streamUrl` must be an HTTPS URL reachable by the device.
- Tracks without valid `streamUrl` are ignored by the remote catalog loader.
- If `albums` is missing or empty, the app groups albums from track metadata.
- The app falls back to the bundled demo library until the remote catalog loads.
