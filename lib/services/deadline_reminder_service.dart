import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/opportunity.dart';
import 'api_service.dart';

/// ╔══════════════════════════════════════════════════════════════╗
/// ║  🎯  HACKATHON DEMO — Change the time below to test now!   ║
/// ║                                                              ║
/// ║  Set _reminderHour & _reminderMinute to current time + 1.  ║
/// ║  Example: to trigger at 3:45 PM set:                        ║
/// ║     _reminderHour   = 15  (24-hour clock)                   ║
/// ║     _reminderMinute = 45                                     ║
/// ║                                                              ║
/// ║  Production value: 18 = 6 PM (fires at exactly 18:00).     ║
/// ╚══════════════════════════════════════════════════════════════╝
class DeadlineReminderService {
  DeadlineReminderService._();

  // ── Reminder time ─────────────────────────────────────────────
  static const int _reminderHour = 17; // 🎯 DEMO: 8 AM
  static const int _reminderMinute = 00; // 🎯 DEMO: fires at 8:36 AM
  // ──────────────────────────────────────────────────────────────

  static const int _daysThreshold =
      3; // Notify only for deadlines within 3 days

  static final plugin = FlutterLocalNotificationsPlugin();
  static Timer? _timer;
  static DateTime? _lastFiredDate;

  static bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Call once from main() after WidgetsFlutterBinding.ensureInitialized().
  static Future<void> init() async {
    if (!_isAndroid) return;

    await _initPlugin();
    await _requestPermission();
    _startPeriodicCheck();
    _log(
      'Deadline reminder service started (fires daily at $_reminderHour:${_reminderMinute.toString().padLeft(2, '0')}).',
    );
  }

  // ── Private ────────────────────────────────────────────────────

  static Future<void> _initPlugin() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const settings = InitializationSettings(android: androidSettings);
    await plugin.initialize(settings);
  }

  static Future<void> _requestPermission() async {
    try {
      final android = plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await android?.requestNotificationsPermission();
    } catch (e) {
      _log('Could not request notification permission: $e');
    }
  }

  /// Checks every minute whether it is time to send notifications.
  static void _startPeriodicCheck() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _checkTime());
  }

  static Future<void> _checkTime() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Reset if it's a new day so it can fire again tomorrow.
    if (_lastFiredDate != null && _lastFiredDate!.isBefore(today)) {
      _lastFiredDate = null;
    }

    // Already fired today — skip.
    if (_lastFiredDate != null) return;

    if (now.hour == _reminderHour && now.minute == _reminderMinute) {
      _lastFiredDate = today;
      await _sendDeadlineNotifications();
    }
  }

  static Future<void> _sendDeadlineNotifications() async {
    try {
      final opportunities = await ApiService.instance.fetchOpportunities();

      final upcoming = opportunities.where((opp) {
        final days = _daysLeft(opp.deadline);
        return days >= 0 && days <= _daysThreshold;
      }).toList();

      if (upcoming.isEmpty) {
        _log('No deadlines within $_daysThreshold days — nothing to notify.');
        return;
      }

      for (int i = 0; i < upcoming.length; i++) {
        await _showNotification(upcoming[i], i);
      }

      _log('Sent ${upcoming.length} deadline notification(s).');
    } catch (e, st) {
      _log('Failed to send deadline reminders: $e', stackTrace: st);
    }
  }

  static Future<void> _showNotification(Opportunity opp, int index) async {
    final days = _daysLeft(opp.deadline);
    final urgencyLabel = switch (days) {
      0 => '🔴 Due TODAY',
      1 => '🟠 1 day left',
      2 => '🟡 2 days left',
      _ => '🟢 3 days left',
    };

    const channelId = 'deadline_reminders';

    await plugin.show(
      100 + index,
      '$urgencyLabel — ${opp.company}',
      '${opp.role} · Apply before the deadline!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          'Deadline Reminders',
          channelDescription:
              'Daily reminder at 6 PM when an opportunity deadline is within 3 days',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  static int _daysLeft(DateTime deadline) {
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final deadlineMidnight = DateTime(
      deadline.year,
      deadline.month,
      deadline.day,
    );
    return deadlineMidnight.difference(todayMidnight).inDays;
  }

  static void _log(String message, {StackTrace? stackTrace}) {
    developer.log(
      message,
      name: 'DeadlineReminderService',
      stackTrace: stackTrace,
    );
  }

  static void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
