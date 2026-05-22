package com.mezuu.aetheris.player

import android.Manifest
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.ContentUris
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.AudioDeviceInfo
import android.media.MediaMetadata
import android.media.MediaPlayer
import android.media.MediaMetadataRetriever
import android.media.session.MediaSession
import android.media.session.PlaybackState
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.charset.Charset

class MainActivity : FlutterActivity() {
    private val mediaChannel = "aetheris/media_store"
    private val audioChannel = "aetheris/native_audio"
    private val notificationChannelName = "aetheris/playback_notification"
    private val playbackNotificationId = 1120
    private val playbackChannelId = "aetheris_playback"
    private var mediaPlayer: MediaPlayer? = null
    private var completed = false
    private var playbackNotificationChannel: MethodChannel? = null
    private var playbackMediaSession: MediaSession? = null
    private var currentTrackId: String? = null
    private var currentArtworkBitmap: Bitmap? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "aetheris/hardware")
            .setMethodCallHandler { call, result ->
                if (call.method == "scanHardware") {
                    var hasDac = false
                    var hasLdac = false
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                        val devices = audioManager.getDevices(AudioManager.GET_DEVICES_OUTPUTS)
                        for (device in devices) {
                            val type = device.type
                            if (type == AudioDeviceInfo.TYPE_USB_DEVICE || 
                                type == AudioDeviceInfo.TYPE_USB_ACCESSORY || 
                                (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && type == AudioDeviceInfo.TYPE_USB_HEADSET)) {
                                hasDac = true
                            }
                            if (type == AudioDeviceInfo.TYPE_BLUETOOTH_A2DP) {
                                hasLdac = true
                            }
                        }
                    }
                    result.success(mapOf("hasDac" to hasDac, "hasLdac" to hasLdac))
                } else {
                    result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, mediaChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "scanAudio" -> result.success(scanAudio())
                    "readMetadata" -> {
                        val uri = call.argument<String>("uri")
                        val path = call.argument<String>("path")
                        val id = call.argument<String>("id") ?: uri.hashCode().toString()
                        if (uri.isNullOrBlank()) {
                            result.error("ARGUMENT", "Missing uri", null)
                        } else {
                            result.success(readEmbeddedMetadata(Uri.parse(uri), id, path))
                        }
                    }
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, audioChannel)
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "load" -> {
                            val uri = call.argument<String>("uri")
                            if (uri.isNullOrBlank()) {
                                result.error("ARGUMENT", "Missing uri", null)
                            } else {
                                result.success(loadNativeAudio(uri))
                            }
                        }
                        "play" -> {
                            completed = false
                            mediaPlayer?.start()
                            result.success(null)
                        }
                        "pause" -> {
                            mediaPlayer?.pause()
                            result.success(null)
                        }
                        "seek" -> {
                            val positionMs = call.argument<Int>("positionMs") ?: 0
                            mediaPlayer?.seekTo(positionMs)
                            completed = false
                            result.success(null)
                        }
                        "state" -> result.success(nativeAudioState())
                        "dispose" -> {
                            releaseNativeAudio()
                            result.success(null)
                        }
                        else -> result.notImplemented()
                    }
                } catch (error: Exception) {
                    result.error("NATIVE_AUDIO", error.message, null)
                }
            }

        playbackNotificationChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            notificationChannelName
        )
        playbackNotificationChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "show" -> {
                    showPlaybackNotification(call.arguments as? Map<*, *>)
                    result.success(null)
                }
                "hide" -> {
                    hidePlaybackNotification()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
        handlePlaybackIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handlePlaybackIntent(intent)
    }

    private fun loadNativeAudio(uriValue: String): Map<String, Any?> {
        releaseNativeAudio()
        completed = false

        val player = MediaPlayer()
        player.setAudioAttributes(
            AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_MEDIA)
                .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                .build()
        )
        player.setOnCompletionListener {
            completed = true
        }
        player.setOnErrorListener { _, _, _ ->
            completed = false
            false
        }
        player.setDataSource(this, Uri.parse(uriValue))
        player.prepare()
        mediaPlayer = player
        return nativeAudioState()
    }

    private fun showPlaybackNotification(args: Map<*, *>?) {
        val trackId = args?.get("trackId") as? String
        val title = args?.get("title") as? String ?: "Aetheris"
        val artist = args?.get("artist") as? String ?: ""
        val isPlaying = args?.get("isPlaying") as? Boolean ?: false
        val positionMs = (args?.get("positionMs") as? Number)?.toInt() ?: 0
        val durationMs = (args?.get("durationMs") as? Number)?.toInt() ?: 0
        val artworkUrl = args?.get("artworkUrl") as? String

        if (trackId != null && trackId != currentTrackId) {
            currentTrackId = trackId
            currentArtworkBitmap = null
            if (!artworkUrl.isNullOrEmpty()) {
                Thread {
                    try {
                        val url = java.net.URL(artworkUrl)
                        val connection = url.openConnection()
                        connection.connectTimeout = 5000
                        connection.readTimeout = 5000
                        val bitmap = BitmapFactory.decodeStream(connection.getInputStream())
                        runOnUiThread {
                            if (currentTrackId == trackId && bitmap != null) {
                                currentArtworkBitmap = bitmap
                                showPlaybackNotification(args)
                            }
                        }
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                }.start()
            }
        }

        val artworkBitmap = currentArtworkBitmap ?: BitmapFactory.decodeResource(resources, R.mipmap.launcher_icon)
        updatePlaybackMediaSession(title, artist, isPlaying, positionMs, durationMs, artworkBitmap)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
            checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED
        ) {
            requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 1121)
            return
        }

        ensurePlaybackNotificationChannel()

        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, playbackChannelId)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }

        val openIntent = PendingIntent.getActivity(
            this,
            10,
            Intent(this, MainActivity::class.java),
            pendingIntentFlags()
        )
        builder
            .setSmallIcon(R.mipmap.launcher_icon)
            .setLargeIcon(artworkBitmap)
            .setContentTitle(title)
            .setContentText(artist)
            .setContentIntent(openIntent)
            .setOnlyAlertOnce(true)
            .setShowWhen(false)
            .setOngoing(isPlaying)
            .setCategory(Notification.CATEGORY_TRANSPORT)
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .setPriority(Notification.PRIORITY_LOW)
            .setStyle(
                Notification.MediaStyle()
                    .setMediaSession(ensurePlaybackMediaSession().sessionToken)
                    .setShowActionsInCompactView(0, 1, 2)
            )
            .addAction(
                android.R.drawable.ic_media_previous,
                "Previous",
                playbackActionIntent("previous", 11)
            )
            .addAction(
                if (isPlaying) android.R.drawable.ic_media_pause else android.R.drawable.ic_media_play,
                if (isPlaying) "Pause" else "Play",
                playbackActionIntent("toggle", 12)
            )
            .addAction(
                android.R.drawable.ic_media_next,
                "Next",
                playbackActionIntent("next", 13)
            )

        if (durationMs > 0) {
            builder.setProgress(durationMs, positionMs.coerceIn(0, durationMs), false)
        }

        manager.notify(playbackNotificationId, builder.build())
    }

    private fun hidePlaybackNotification() {
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        manager.cancel(playbackNotificationId)
        playbackMediaSession?.isActive = false
    }

    private fun ensurePlaybackNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (manager.getNotificationChannel(playbackChannelId) != null) return
        val channel = NotificationChannel(
            playbackChannelId,
            "Playback",
            NotificationManager.IMPORTANCE_LOW
        )
        channel.description = "Music playback controls"
        manager.createNotificationChannel(channel)
    }

    private fun playbackActionIntent(action: String, requestCode: Int): PendingIntent {
        val intent = Intent(this, MainActivity::class.java).apply {
            this.action = "aetheris.playback.$action"
            putExtra("playbackAction", action)
        }
        return PendingIntent.getActivity(this, requestCode, intent, pendingIntentFlags())
    }

    private fun pendingIntentFlags(): Int {
        return PendingIntent.FLAG_UPDATE_CURRENT or
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) PendingIntent.FLAG_IMMUTABLE else 0
    }

    private fun handlePlaybackIntent(intent: Intent?) {
        val action = intent?.getStringExtra("playbackAction") ?: return
        playbackNotificationChannel?.invokeMethod("action", mapOf("action" to action))
    }

    private fun ensurePlaybackMediaSession(): MediaSession {
        val existing = playbackMediaSession
        if (existing != null) return existing

        val session = MediaSession(this, "AetherisPlayback").apply {
            setSessionActivity(
                PendingIntent.getActivity(
                    this@MainActivity,
                    10,
                    Intent(this@MainActivity, MainActivity::class.java),
                    pendingIntentFlags()
                )
            )
            setCallback(object : MediaSession.Callback() {
                override fun onPlay() {
                    sendPlaybackAction("toggle")
                }

                override fun onPause() {
                    sendPlaybackAction("toggle")
                }

                override fun onSkipToNext() {
                    sendPlaybackAction("next")
                }

                override fun onSkipToPrevious() {
                    sendPlaybackAction("previous")
                }

                override fun onSeekTo(pos: Long) {
                    playbackNotificationChannel?.invokeMethod(
                        "action",
                        mapOf("action" to "seek", "positionMs" to pos)
                    )
                }
            })
        }
        playbackMediaSession = session
        return session
    }

    private fun updatePlaybackMediaSession(
        title: String,
        artist: String,
        isPlaying: Boolean,
        positionMs: Int,
        durationMs: Int,
        artworkBitmap: Bitmap
    ) {
        val session = ensurePlaybackMediaSession()
        session.setMetadata(
            MediaMetadata.Builder()
                .putString(MediaMetadata.METADATA_KEY_TITLE, title)
                .putString(MediaMetadata.METADATA_KEY_ARTIST, artist)
                .putLong(MediaMetadata.METADATA_KEY_DURATION, durationMs.toLong())
                .putBitmap(
                    MediaMetadata.METADATA_KEY_ALBUM_ART,
                    artworkBitmap
                )
                .build()
        )
        session.setPlaybackState(
            PlaybackState.Builder()
                .setActions(
                    PlaybackState.ACTION_PLAY or
                        PlaybackState.ACTION_PAUSE or
                        PlaybackState.ACTION_PLAY_PAUSE or
                        PlaybackState.ACTION_SKIP_TO_PREVIOUS or
                        PlaybackState.ACTION_SKIP_TO_NEXT or
                        PlaybackState.ACTION_SEEK_TO
                )
                .setState(
                    if (isPlaying) PlaybackState.STATE_PLAYING else PlaybackState.STATE_PAUSED,
                    positionMs.toLong(),
                    if (isPlaying) 1.0f else 0.0f
                )
                .build()
        )
        session.isActive = true
    }

    private fun sendPlaybackAction(action: String) {
        playbackNotificationChannel?.invokeMethod("action", mapOf("action" to action))
    }

    private fun nativeAudioState(): Map<String, Any?> {
        val player = mediaPlayer
        return mapOf(
            "positionMs" to (player?.currentPosition ?: 0),
            "durationMs" to (player?.duration ?: 0),
            "isPlaying" to (player?.isPlaying ?: false),
            "completed" to completed,
        )
    }

    private fun releaseNativeAudio() {
        mediaPlayer?.release()
        mediaPlayer = null
        completed = false
    }

    private fun scanAudio(): List<Map<String, Any?>> {
        val collection =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                MediaStore.Audio.Media.getContentUri(MediaStore.VOLUME_EXTERNAL)
            } else {
                MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
            }

        val projection = arrayOf(
            MediaStore.Audio.Media._ID,
            MediaStore.Audio.Media.DISPLAY_NAME,
            MediaStore.Audio.Media.TITLE,
            MediaStore.Audio.Media.ARTIST,
            MediaStore.Audio.Media.ALBUM,
            MediaStore.Audio.Media.ALBUM_ID,
            MediaStore.Audio.Media.DURATION,
            MediaStore.Audio.Media.MIME_TYPE,
            MediaStore.Audio.Media.DATA,
        )

        val selection = "${MediaStore.Audio.Media.IS_MUSIC} != 0"
        val sortOrder = "${MediaStore.Audio.Media.DATE_ADDED} DESC"
        val tracks = mutableListOf<Map<String, Any?>>()

        contentResolver.query(collection, projection, selection, null, sortOrder)?.use { cursor ->
            val idColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media._ID)
            val displayNameColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DISPLAY_NAME)
            val titleColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.TITLE)
            val artistColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ARTIST)
            val albumColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM)
            val albumIdColumn = cursor.getColumnIndex(MediaStore.Audio.Media.ALBUM_ID)
            val durationColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DURATION)
            val mimeColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.MIME_TYPE)
            val dataColumn = cursor.getColumnIndex(MediaStore.Audio.Media.DATA)

            while (cursor.moveToNext()) {
                val id = cursor.getLong(idColumn)
                val contentUri = ContentUris.withAppendedId(collection, id)
                val displayName = cursor.getString(displayNameColumn) ?: ""
                val filePath = if (dataColumn >= 0) cursor.getString(dataColumn) else null
                val title = cursor.getString(titleColumn)
                    ?: displayName.substringBeforeLast('.')
                val artist = cursor.getString(artistColumn)?.takeUnless { it == "<unknown>" }
                val album = cursor.getString(albumColumn)?.takeUnless { it == "<unknown>" }
                val albumId = if (albumIdColumn >= 0) cursor.getLong(albumIdColumn) else 0L
                val duration = cursor.getLong(durationColumn)
                val mime = cursor.getString(mimeColumn)
                val artworkUri = readLowResArtworkUri(contentUri, id.toString(), albumId)

                tracks.add(
                    mapOf(
                        "id" to id.toString(),
                        "path" to (filePath ?: displayName),
                        "displayName" to displayName,
                        "uri" to contentUri.toString(),
                        "title" to title,
                        "artist" to (artist ?: "Unknown Artist"),
                        "album" to (album ?: "Local Music"),
                        "durationMs" to duration,
                        "mimeType" to mime,
                        "artworkUri" to artworkUri,
                    )
                )
            }
        }

        return tracks
    }

    private fun readLowResArtworkUri(audioUri: Uri, audioId: String, albumId: Long): String? {
        val artworkFile = File(artworkCacheDir(), "thumb_$audioId.jpg")
        if (artworkFile.exists() && artworkFile.length() > 0) {
            return Uri.fromFile(artworkFile).toString()
        }

        try {
            if (albumId > 0) {
                val albumArtUri = ContentUris.withAppendedId(
                    Uri.parse("content://media/external/audio/albumart"),
                    albumId
                )
                contentResolver.openInputStream(albumArtUri)?.use { input ->
                    return writeScaledArtwork(input.readBytes(), artworkFile, 180)
                }
            }
        } catch (_: Exception) {
            // Some Android builds do not expose album-art rows. Fall back below.
        }

        return try {
            val retriever = MediaMetadataRetriever()
            retriever.setDataSource(this, audioUri)
            val picture = retriever.embeddedPicture
            retriever.release()
            if (picture == null) null else writeScaledArtwork(picture, artworkFile, 180)
        } catch (_: Exception) {
            null
        }
    }

    private fun writeScaledArtwork(bytes: ByteArray, outputFile: File, targetSize: Int): String? {
        if (bytes.isEmpty()) return null

        val bounds = BitmapFactory.Options().apply {
            inJustDecodeBounds = true
        }
        BitmapFactory.decodeByteArray(bytes, 0, bytes.size, bounds)
        if (bounds.outWidth <= 0 || bounds.outHeight <= 0) return null

        val options = BitmapFactory.Options().apply {
            inSampleSize = calculateInSampleSize(bounds.outWidth, bounds.outHeight, targetSize)
        }
        val bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.size, options) ?: return null
        return try {
            outputFile.outputStream().use { output ->
                bitmap.compress(Bitmap.CompressFormat.JPEG, 72, output)
            }
            Uri.fromFile(outputFile).toString()
        } finally {
            bitmap.recycle()
        }
    }

    private fun calculateInSampleSize(width: Int, height: Int, targetSize: Int): Int {
        var sampleSize = 1
        var halfWidth = width / 2
        var halfHeight = height / 2
        while (halfWidth / sampleSize >= targetSize && halfHeight / sampleSize >= targetSize) {
            sampleSize *= 2
        }
        return sampleSize.coerceAtLeast(1)
    }

    private fun readEmbeddedMetadata(
        uri: Uri,
        id: String,
        filePath: String?,
    ): Map<String, Any?> {
        val metadata = mutableMapOf<String, Any?>()

        try {
            val retriever = MediaMetadataRetriever()
            retriever.setDataSource(this, uri)
            metadata["title"] = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_TITLE)
            metadata["artist"] = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ARTIST)
            metadata["album"] = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ALBUM)

            retriever.embeddedPicture?.let { picture ->
                val artworkFile = File(artworkCacheDir(), "full_$id.jpg")
                if (!artworkFile.exists() || artworkFile.length() <= 0) {
                    artworkFile.writeBytes(picture)
                }
                metadata["artworkUri"] = Uri.fromFile(artworkFile).toString()
            }
            retriever.release()
        } catch (_: Exception) {
            // MediaStore data is still enough for playback if metadata extraction fails.
        }

        if (filePath?.lowercase()?.endsWith(".flac") == true) {
            metadata.putAll(readFlacVorbisComments(filePath))
        }

        return metadata.filterValues { value ->
            value !is String || value.isNotBlank()
        }
    }

    private fun artworkCacheDir(): File {
        val dir = File(filesDir, "aetheris_artwork_cache")
        if (!dir.exists()) {
            dir.mkdirs()
        }
        return dir
    }

    private fun readFlacVorbisComments(filePath: String): Map<String, String> {
        val file = File(filePath)
        if (!file.exists() || !file.canRead()) return emptyMap()

        file.inputStream().use { input ->
            val marker = ByteArray(4)
            if (input.read(marker) != 4 || String(marker, Charsets.US_ASCII) != "fLaC") {
                return emptyMap()
            }

            while (true) {
                val header = ByteArray(4)
                if (input.read(header) != 4) return emptyMap()
                val isLast = (header[0].toInt() and 0x80) != 0
                val blockType = header[0].toInt() and 0x7F
                val length = ((header[1].toInt() and 0xFF) shl 16) or
                    ((header[2].toInt() and 0xFF) shl 8) or
                    (header[3].toInt() and 0xFF)

                if (blockType == 4) {
                    val block = ByteArray(length)
                    if (input.read(block) != length) return emptyMap()
                    return parseVorbisCommentBlock(block)
                }

                input.skip(length.toLong())
                if (isLast) return emptyMap()
            }
        }
    }

    private fun parseVorbisCommentBlock(block: ByteArray): Map<String, String> {
        val values = mutableMapOf<String, String>()
        var offset = 0

        fun readLeInt(): Int {
            val value = ByteBuffer
                .wrap(block, offset, 4)
                .order(ByteOrder.LITTLE_ENDIAN)
                .int
            offset += 4
            return value
        }

        fun readString(length: Int): String {
            val value = String(block, offset, length, Charset.forName("UTF-8"))
            offset += length
            return value
        }

        if (block.size < 8) return emptyMap()
        val vendorLength = readLeInt()
        if (vendorLength < 0 || offset + vendorLength > block.size) return emptyMap()
        offset += vendorLength
        if (offset + 4 > block.size) return emptyMap()

        val commentCount = readLeInt()
        repeat(commentCount.coerceAtMost(256)) {
            if (offset + 4 > block.size) return@repeat
            val length = readLeInt()
            if (length < 0 || offset + length > block.size) return@repeat
            val raw = readString(length)
            val separator = raw.indexOf('=')
            if (separator <= 0) return@repeat
            val key = raw.substring(0, separator).uppercase()
            val value = raw.substring(separator + 1).trim()
            when (key) {
                "TITLE" -> values["title"] = value
                "ARTIST", "ALBUMARTIST" -> values.putIfAbsent("artist", value)
                "ALBUM" -> values["album"] = value
                "LYRICS", "UNSYNCEDLYRICS", "UNSYNCED LYRICS" -> values["lyrics"] = value
            }
        }

        return values
    }
}
