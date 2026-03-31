import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:notification_listener_service/notification_event.dart';
import 'package:notification_listener_service/notification_listener_service.dart';

import 'deadline_reminder_service.dart';

const String _whatsAppPackageName = 'com.whatsapp';
const List<String> _backendBaseUrls = <String>[
  'http://192.168.1.16:5000',
  'http://10.0.2.2:5000',
  'http://127.0.0.1:5000',
  'http://localhost:5000',
];

class NotificationService {
  NotificationService._();

  static const Duration _duplicateWindow = Duration(seconds: 20);

  static final NotificationService instance = NotificationService._();

  StreamSubscription<ServiceNotificationEvent>? _subscription;
  bool _isStarting = false;
  final Map<String, DateTime> _recentFingerprints = <String, DateTime>{};

  Future<void> startNotificationListener() async {
    if (!_isAndroid) {
      _log('Notification listener skipped because this is not Android.');
      return;
    }

    if (_subscription != null) {
      _log('Notification listener is already running.');
      return;
    }

    if (_isStarting) {
      _log('Notification listener startup is already in progress.');
      return;
    }

    _isStarting = true;

    try {
      var hasPermission =
          await NotificationListenerService.isPermissionGranted();

      if (!hasPermission) {
        _log('Notification access not granted. Opening Android settings.');
        hasPermission = await NotificationListenerService.requestPermission();
      }

      if (!hasPermission) {
        _log('Notification listener permission was not granted.');
        return;
      }

      _subscription = NotificationListenerService.notificationsStream.listen(
        (event) {
          unawaited(_handleNotificationEvent(event));
        },
        onError: (Object error, StackTrace stackTrace) {
          _log('Notification stream error: $error', stackTrace: stackTrace);
        },
        cancelOnError: false,
      );

      _log('Notification listener started successfully.');
    } catch (error, stackTrace) {
      _log(
        'Failed to start notification listener: $error',
        stackTrace: stackTrace,
      );
    } finally {
      _isStarting = false;
    }
  }

  Future<void> _handleNotificationEvent(ServiceNotificationEvent event) async {
    try {
      if (event.packageName != _whatsAppPackageName) {
        return;
      }

      if (event.hasRemoved == true) {
        _log('Ignored removed WhatsApp notification.');
        return;
      }

      final String title = (event.title ?? '').trim();
      final String message = _sanitizeText(event.content ?? '');

      if (message.isEmpty) {
        _log(
          'Ignored WhatsApp notification with empty message. Title: '
          '${title.isEmpty ? 'Unknown' : title}',
        );
        return;
      }

      final String readableMessage = _buildReadableMessage(
        title: title,
        message: message,
      );

      final String fingerprint = _buildFingerprint(
        title: title,
        message: readableMessage,
      );

      if (_isDuplicateFingerprint(fingerprint)) {
        _log(
          'Ignored duplicate WhatsApp notification. '
          'Title: ${title.isEmpty ? 'Unknown' : title}',
        );
        return;
      }

      _log(
        'Captured WhatsApp notification. '
        'Title: ${title.isEmpty ? 'Unknown' : title}, '
        'Message: $readableMessage',
      );

      await _sendNotificationToBackend(title: title, message: readableMessage);
    } catch (error, stackTrace) {
      _log(
        'Failed to process notification event: $error',
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _showNewOpportunityNotification({
    required String title,
    required String message,
  }) async {
    try {
      await DeadlineReminderService.plugin.show(
        1,
        '🎯 New Opportunity Detected!',
        title.isNotEmpty ? '$title — $message' : message,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'new_opportunities',
            'New Opportunities',
            channelDescription:
                'Notifies when a new internship or job opportunity is detected',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    } catch (e) {
      _log('Failed to show external notification: $e');
    }
  }

  Future<void> _sendNotificationToBackend({
    required String title,
    required String message,
  }) async {
    final List<Uri> endpoints = _backendUris;

    for (final Uri endpoint in endpoints) {
      try {
        final response = await http
            .post(
              endpoint,
              headers: const {'Content-Type': 'application/json'},
              body: jsonEncode({
                'source': 'whatsapp',
                'title': title,
                'message': message,
              }),
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode >= 200 && response.statusCode < 300) {
          _log(
            'WhatsApp notification sent to backend successfully via '
            '$endpoint (status ${response.statusCode}).',
          );
          // Fire external system notification only when a NEW opportunity is saved (201)
          if (response.statusCode == 201) {
            await _showNewOpportunityNotification(
              title: title,
              message: message,
            );
          }
          return;
        }

        _log(
          'Backend rejected WhatsApp notification via '
          '$endpoint (status ${response.statusCode}): ${response.body}',
        );
      } catch (error, stackTrace) {
        _log(
          'Failed to send WhatsApp notification to $endpoint: $error',
          stackTrace: stackTrace,
        );
      }
    }

    _log('All backend delivery attempts failed for the captured message.');
  }

  List<Uri> get _backendUris {
    return _backendBaseUrls
        .map((baseUrl) => Uri.parse('$baseUrl/import-notification'))
        .toList();
  }

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  String _sanitizeText(String value) {
    return value
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll('\u{200B}', '')
        .trim();
  }

  String _buildReadableMessage({
    required String title,
    required String message,
  }) {
    final normalizedTitle = _sanitizeText(title);
    final normalizedMessage = _sanitizeText(message);

    if (normalizedTitle.isEmpty) {
      return normalizedMessage;
    }

    final lowerTitle = normalizedTitle.toLowerCase();
    final lowerMessage = normalizedMessage.toLowerCase();

    if (lowerMessage.startsWith(lowerTitle)) {
      return normalizedMessage;
    }

    return '$normalizedTitle: $normalizedMessage';
  }

  String _buildFingerprint({required String title, required String message}) {
    return '${title.trim().toLowerCase()}|${message.trim().toLowerCase()}';
  }

  bool _isDuplicateFingerprint(String fingerprint) {
    final now = DateTime.now();

    _recentFingerprints.removeWhere(
      (_, createdAt) => now.difference(createdAt) > _duplicateWindow,
    );

    if (_recentFingerprints.containsKey(fingerprint)) {
      return true;
    }

    _recentFingerprints[fingerprint] = now;
    return false;
  }

  void _log(String message, {StackTrace? stackTrace}) {
    developer.log(message, name: 'NotificationService', stackTrace: stackTrace);
  }
}

Future<void> startNotificationListener() {
  return NotificationService.instance.startNotificationListener();
}
