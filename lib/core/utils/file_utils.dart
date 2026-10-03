import 'package:flutter/material.dart';
import 'package:free_space/data/models/item_enums.dart';

/// Utilities for file operations and display
class FileUtils {
  FileUtils._();

  /// Converts bytes to human-readable format
  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    return '${size.toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')} ${suffixes[i]}';
  }

  /// Extracts file extension from path
  static String getFileExtension(String path) {
    final lastDotIndex = path.lastIndexOf('.');
    if (lastDotIndex == -1 || lastDotIndex == path.length - 1) {
      return '';
    }
    return path.substring(lastDotIndex + 1).toLowerCase();
  }

  /// Extracts file name from path
  static String getFileName(String path) {
    final lastSlashIndex = path.lastIndexOf('/');
    if (lastSlashIndex == -1) {
      return path;
    }
    return path.substring(lastSlashIndex + 1);
  }

  /// Returns Material icon for MIME type
  static IconData getIconForMimeType(String? mimeType) {
    if (mimeType == null) return Icons.insert_drive_file;
    if (mimeType.startsWith('image/')) return Icons.image;
    if (mimeType.startsWith('video/')) return Icons.movie;
    if (mimeType.startsWith('audio/')) return Icons.audiotrack;
    if (mimeType.contains('pdf')) return Icons.picture_as_pdf;
    if (mimeType.contains('zip') || mimeType.contains('compressed')) {
      return Icons.folder_zip;
    }
    if (mimeType.contains('text') || mimeType.contains('document')) {
      return Icons.description;
    }
    return Icons.insert_drive_file;
  }

  static IconData getIconForItem({
    required ItemType type,
    required String name,
    String? mimeType,
  }) {
    if (type == ItemType.app) {
      return Icons.apps_outlined;
    }

    final normalizedMimeType = mimeType?.toLowerCase() ?? '';
    final extension = getFileExtension(name);
    final isVideo = normalizedMimeType.startsWith('video/') ||
        const {
          'avi',
          'm4v',
          'mkv',
          'mov',
          'mp4',
          'mpeg',
          'mpg',
          'webm',
        }.contains(extension);
    if (type == ItemType.media) {
      if (isVideo) return Icons.movie_outlined;
      if (normalizedMimeType.startsWith('audio/') ||
          const {'aac', 'aiff', 'flac', 'm4a', 'mp3', 'wav'}
              .contains(extension)) {
        return Icons.audiotrack_outlined;
      }
      return Icons.photo_outlined;
    }

    if (normalizedMimeType.contains('pdf') || extension == 'pdf') {
      return Icons.picture_as_pdf_outlined;
    }
    if (normalizedMimeType.contains('zip') ||
        normalizedMimeType.contains('compressed') ||
        const {'7z', 'gz', 'rar', 'tar', 'zip'}.contains(extension)) {
      return Icons.folder_zip_outlined;
    }
    if (normalizedMimeType.startsWith('text/') ||
        normalizedMimeType.contains('document') ||
        const {
          'csv',
          'doc',
          'docx',
          'md',
          'odt',
          'rtf',
          'txt',
          'xls',
          'xlsx',
        }.contains(extension)) {
      return Icons.description_outlined;
    }
    return Icons.insert_drive_file_outlined;
  }

  /// Returns broad category for MIME type
  static String getFileCategory(String? mimeType) {
    if (mimeType == null) {
      return 'other';
    }
    if (mimeType.startsWith('image/')) {
      return 'image';
    }
    if (mimeType.startsWith('video/')) {
      return 'video';
    }
    if (mimeType.startsWith('audio/')) {
      return 'audio';
    }
    if (mimeType.contains('pdf') ||
        mimeType.contains('document') ||
        mimeType.contains('text')) {
      return 'document';
    }
    if (mimeType.contains('zip') ||
        mimeType.contains('compressed') ||
        mimeType.contains('tar')) {
      return 'archive';
    }
    return 'other';
  }
}
