import 'package:flutter/material.dart';

import '../services/download_service.dart';
import '../theme/aetheris_colors.dart';
import '../widgets/glass_container.dart';

/// Overlay page showing all active and recent downloads with live progress.
class ActiveDownloadsPage extends StatelessWidget {
  const ActiveDownloadsPage({super.key, required this.downloadService});

  final DownloadService downloadService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AetherisColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AetherisColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Downloads',
          style: TextStyle(
            color: AetherisColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: downloadService,
        builder: (context, _) {
          final jobs = downloadService.activeJobs;

          if (jobs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.download_done_rounded,
                      color: AetherisColors.textTertiary.withValues(alpha: 0.4),
                      size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'No downloads yet',
                    style: TextStyle(
                      color: AetherisColors.textPrimary.withValues(alpha: 0.5),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Search for a song and tap the ⋮ menu to download',
                    style: TextStyle(
                      color: AetherisColors.textTertiary.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              return _DownloadJobTile(
                job: jobs[index],
                onCancel: () => downloadService.cancelDownload(jobs[index].id),
              );
            },
          );
        },
      ),
    );
  }
}

class _DownloadJobTile extends StatelessWidget {
  const _DownloadJobTile({required this.job, required this.onCancel});

  final DownloadJob job;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusIcon) = _statusVisuals(job.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassContainer(
        padding: const EdgeInsets.all(14),
        radius: 16,
        color: Colors.white.withValues(alpha: 0.04),
        borderColor: statusColor.withValues(alpha: 0.15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Status icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(child: statusIcon),
                ),
                const SizedBox(width: 12),

                // Title & artist
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.track.title.isNotEmpty ? job.track.title : 'Resolving...',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AetherisColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (job.track.artist.isNotEmpty)
                        Text(
                          job.track.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AetherisColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),

                // Quality badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    job.qualityFormat.toUpperCase(),
                    style: const TextStyle(
                      color: AetherisColors.accentSoft,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                // Cancel button (only for active jobs)
                if (job.isActive) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.close_rounded,
                        color: AetherisColors.textTertiary.withValues(alpha: 0.6),
                        size: 18),
                    onPressed: onCancel,
                    tooltip: 'Cancel download',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                  ),
                ],
              ],
            ),

            // Progress bar
            if (job.isActive) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: job.progress,
                  backgroundColor: Colors.white.withValues(alpha: 0.06),
                  valueColor: AlwaysStoppedAnimation(statusColor),
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _statusLabel(job.status),
                    style: TextStyle(
                      color: statusColor.withValues(alpha: 0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${(job.progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: AetherisColors.textTertiary.withValues(alpha: 0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],

            // Completed info
            if (job.status == DownloadJobStatus.completed) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: AetherisColors.success.withValues(alpha: 0.7),
                      size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'Downloaded${job.fileSizeLabel.isNotEmpty ? ' • ${job.fileSizeLabel}' : ''} • ${job.qualityFormat.toUpperCase()}',
                    style: TextStyle(
                      color: AetherisColors.success.withValues(alpha: 0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],

            // Error info
            if (job.status == DownloadJobStatus.failed && job.error != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.error_outline_rounded,
                      color: AetherisColors.error.withValues(alpha: 0.7),
                      size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      job.error!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AetherisColors.error.withValues(alpha: 0.7),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  (Color, Widget) _statusVisuals(DownloadJobStatus status) {
    return switch (status) {
      DownloadJobStatus.queued || DownloadJobStatus.paused => (
          AetherisColors.warning,
          const Icon(Icons.hourglass_top_rounded,
              color: AetherisColors.warning, size: 20),
        ),
      DownloadJobStatus.downloading || DownloadJobStatus.resuming => (
          AetherisColors.accentSoft,
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AetherisColors.accentSoft,
            ),
          ),
        ),
      DownloadJobStatus.converting || DownloadJobStatus.validating => (
          AetherisColors.accentSoft,
          const Icon(Icons.sync_rounded,
              color: AetherisColors.accentSoft, size: 20),
        ),
      DownloadJobStatus.completed => (
          AetherisColors.success,
          const Icon(Icons.check_circle_rounded,
              color: AetherisColors.success, size: 20),
        ),
      DownloadJobStatus.failed => (
          AetherisColors.error,
          const Icon(Icons.error_rounded,
              color: AetherisColors.error, size: 20),
        ),
      DownloadJobStatus.cancelled => (
          AetherisColors.textTertiary,
          const Icon(Icons.cancel_rounded,
              color: AetherisColors.textTertiary, size: 20),
        ),
    };
  }

  String _statusLabel(DownloadJobStatus status) {
    return switch (status) {
      DownloadJobStatus.queued => 'Waiting...',
      DownloadJobStatus.paused => 'Paused',
      DownloadJobStatus.resuming => 'Resuming...',
      DownloadJobStatus.downloading => 'Downloading...',
      DownloadJobStatus.converting => 'Converting...',
      DownloadJobStatus.validating => 'Validating...',
      DownloadJobStatus.completed => 'Completed',
      DownloadJobStatus.failed => 'Failed',
      DownloadJobStatus.cancelled => 'Cancelled',
    };
  }
}
