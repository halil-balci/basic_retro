// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore_for_file: deprecated_member_use
import 'dart:js' as js;
import 'package:flutter/foundation.dart';

/// Service to handle web-specific browser events and session cleanup
class WebSessionService {
  static void registerSession(String sessionId, String userId) {
    if (kIsWeb) {
      try {
        js.context.callMethod('registerSession', [sessionId, userId]);
        debugPrint('Registered session with web: $sessionId, $userId');
      } catch (e) {
        debugPrint('Error registering session with web: $e');
      }
    }
  }
  
  static void unregisterSession() {
    if (kIsWeb) {
      try {
        js.context.callMethod('unregisterSession');
        debugPrint('Unregistered session from web');
      } catch (e) {
        debugPrint('Error unregistering session from web: $e');
      }
    }
  }
  
  static void setupFlutterWebBridge(Function() leaveSessionCallback) {
    if (kIsWeb) {
      try {
        // Register Flutter's leaveSession function with JavaScript
        js.context['flutterLeaveSession'] = js.allowInterop(() {
          debugPrint('JavaScript triggered leaveSession');
          leaveSessionCallback();
        });
        
        debugPrint('Flutter web bridge setup complete');
      } catch (e) {
        debugPrint('Error setting up Flutter web bridge: $e');
      }
    }
  }
  
  /// Setup browser event listeners - ONLY for actual page close/unload
  static void setupBrowserEventListeners(Function() onPageUnload) {
    if (kIsWeb) {
      try {
        // Only handle actual page unload events
        html.window.addEventListener('beforeunload', (event) {
          debugPrint('Browser beforeunload event triggered from Flutter');
          onPageUnload();
        });
        
        html.window.addEventListener('unload', (event) {
          debugPrint('Browser unload event triggered from Flutter');
          onPageUnload();
        });
        
        // REMOVED: visibilitychange event listener
        // We don't want to leave session when user switches tabs
        
        debugPrint('Browser event listeners setup complete (unload events only)');
      } catch (e) {
        debugPrint('Error setting up browser event listeners: $e');
      }
    }
  }
}
