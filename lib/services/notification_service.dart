import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../services/api_service.dart';

/// Singleton service for scheduling local push-like notifications.
/// Notifications fire even when the app is closed (uses Android Alarm Manager
/// via `flutter_local_notifications`).
///
/// Also provides in-app notification polling for Web and real-time badge updates.
class NotificationService {
  NotificationService._();
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // ── In-app notification polling ──
  Timer? _pollTimer;
  int _lastUnreadCount = 0;
  final StreamController<int> _unreadCountController =
      StreamController<int>.broadcast();
  final StreamController<String> _newNotificationController =
      StreamController<String>.broadcast();

  /// Stream of unread notification count updates (for badge display)
  Stream<int> get unreadCountStream => _unreadCountController.stream;

  /// Stream that emits a message when a NEW notification is detected
  Stream<String> get newNotificationStream => _newNotificationController.stream;

  /// Current unread count (synchronous access)
  int get lastUnreadCount => _lastUnreadCount;

  // ── Initialise (call once in main.dart) ──
  Future<void> init() async {
    if (kIsWeb) {
      debugPrint('[NotificationService] Skipped native init on Web');
      // Still initialize polling for web
      return;
    }
    
    if (_isInitialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
      macOS: darwinInit,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request Android 13+ notification permission
    if (Platform.isAndroid) {
      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
      await androidPlugin?.requestExactAlarmsPermission();
    }

    _isInitialized = true;
    debugPrint('[NotificationService] Initialised');
  }

  void _onNotificationTapped(NotificationResponse details) {
    debugPrint('[NotificationService] Tapped: ${details.payload}');
  }

  // ── Start polling for unread notification count ──
  void startPolling({Duration interval = const Duration(seconds: 30)}) {
    stopPolling(); // Cancel any existing timer
    _pollTimer = Timer.periodic(interval, (_) => _pollUnreadCount());
    // Also poll immediately
    _pollUnreadCount();
    debugPrint('[NotificationService] Polling started (every ${interval.inSeconds}s)');
  }

  // ── Stop polling ──
  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  // ── Poll the backend for unread count ──
  Future<void> _pollUnreadCount() async {
    try {
      final response = await ApiService.getUnreadNotificationCount();
      if (response['success'] == true) {
        final int newCount = response['unreadCount'] ?? 0;
        
        // Detect new notifications
        if (newCount > _lastUnreadCount && _lastUnreadCount >= 0) {
          final int diff = newCount - _lastUnreadCount;
          _newNotificationController.add(
            'You have $diff new notification${diff > 1 ? 's' : ''}',
          );
          debugPrint('[NotificationService] $diff new notification(s) detected');
        }

        _lastUnreadCount = newCount;
        _unreadCountController.add(newCount);
      }
    } catch (e) {
      debugPrint('[NotificationService] Poll error: $e');
    }
  }

  /// Force a poll now (e.g., when returning to a screen)
  Future<void> pollNow() async {
    await _pollUnreadCount();
  }

  // ── Android notification channel ──
  AndroidNotificationDetails _androidDetails({
    String channelId = 'visit_reminders',
    String channelName = 'Visit Reminders',
  }) {
    return AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'Reminders for scheduled visits and tasks',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );
  }

  // ── Show an immediate notification ──
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: _androidDetails(),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  // ── Schedule a notification at an exact future time ──
  Future<void> scheduleAt({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    if (kIsWeb) return; // Ignore on web

    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    // Don't schedule if it's in the past
    if (tzTime.isBefore(tz.TZDateTime.now(tz.local))) {
      debugPrint('[NotificationService] Skipped — time in the past');
      return;
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      NotificationDetails(
        android: _androidDetails(),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );

    debugPrint('[NotificationService] Scheduled #$id at $tzTime');
  }

  // ── Schedule a reminder N minutes before a visit ──
  Future<void> scheduleVisitReminder({
    required int visitId,
    required String clientName,
    required String title,
    required DateTime visitTime,
    int minutesBefore = 30,
  }) async {
    final reminderTime =
        visitTime.subtract(Duration(minutes: minutesBefore));

    await scheduleAt(
      id: (visitId.hashCode % 2147483647).abs(),
      title: '🔔 Upcoming Visit: $clientName',
      body: '$title — in $minutesBefore minutes',
      scheduledTime: reminderTime,
      payload: 'visit_$visitId',
    );
  }

  // ── Schedule a task due reminder ──
  Future<void> scheduleTaskReminder({
    required int taskId,
    required String taskTitle,
    required DateTime dueTime,
    int minutesBefore = 15,
  }) async {
    final reminderTime = dueTime.subtract(Duration(minutes: minutesBefore));

    await scheduleAt(
      id: ((taskId.hashCode + 10000) % 2147483647).abs(),
      title: '📋 Task Due Soon',
      body: '$taskTitle — due in $minutesBefore minutes',
      scheduledTime: reminderTime,
      payload: 'task_$taskId',
    );
  }

  // ── Cancel a specific notification ──
  Future<void> cancel(int id) => _plugin.cancel(id);

  // ── Cancel all ──
  Future<void> cancelAll() => _plugin.cancelAll();

  // ── Dispose (cleanup) ──
  void dispose() {
    stopPolling();
    _unreadCountController.close();
    _newNotificationController.close();
  }
}
