import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import '../features/retro/domain/entities/action_item.dart';
import '../features/retro/domain/entities/retro_session.dart';
import '../features/retro/domain/entities/thought_group.dart';

/// Service for exporting action items to various formats
class ActionItemExportService {
  /// Export action items to a text file
  static void exportToText({
    required List<ActionItem> actionItems,
    required List<ThoughtGroup> groups,
    required RetroSession session,
  }) {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('=' * 60);
    buffer.writeln('RETROSPECTIVE ACTION ITEMS');
    buffer.writeln('=' * 60);
    buffer.writeln();
    buffer.writeln('Session: ${session.name}');
    buffer.writeln('Date: ${DateTime.now().toString().split('.')[0]}');
    buffer.writeln('Total Action Items: ${actionItems.length}');
    buffer.writeln();
    buffer.writeln('=' * 60);
    buffer.writeln();

    if (actionItems.isEmpty) {
      buffer.writeln('No action items were created during this retrospective.');
    } else {
      buffer.writeln('ACTION ITEMS:');
      buffer.writeln();
      
      int itemNumber = 1;
      for (final item in actionItems) {
        buffer.write('  $itemNumber. ${item.content}');
        if (item.assignee != null && item.assignee!.isNotEmpty) {
          buffer.write(' (Assignee: ${item.assignee})');
        }
        buffer.writeln();
        itemNumber++;
      }
      buffer.writeln();
    }

    buffer.writeln();
    buffer.writeln('=' * 60);
    buffer.writeln('End of Report');
    buffer.writeln('=' * 60);

    // Download the file
    _downloadFile(
      content: buffer.toString(),
      filename: 'action_items_${session.name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.txt',
      mimeType: 'text/plain',
    );
  }

  /// Download a file in the web browser
  static void _downloadFile({
    required String content,
    required String filename,
    required String mimeType,
  }) {
    if (kIsWeb) {
      // Create a blob from the content
      final bytes = html.Blob([content], mimeType);
      final url = html.Url.createObjectUrlFromBlob(bytes);
      
      // Create a temporary anchor element and trigger download
      html.AnchorElement(href: url)
        ..setAttribute('download', filename)
        ..click();
      
      // Clean up
      html.Url.revokeObjectUrl(url);
    } else {
      // For non-web platforms, you would use path_provider and file system
      debugPrint('File download is only supported on web platform');
    }
  }
}
