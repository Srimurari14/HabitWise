import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../data/local/app_database.dart';

class NotificationService {
  NotificationService._();

  static final instance = NotificationService._();
  static const _patternReminderId = 101;
  static const _reflectionReminderId = 102;
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    try {
      final current = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(current.identifier));
    } on Object {
      // tz.local remains a valid fallback when a platform cannot report an
      // IANA identifier. Scheduling still stays device-local.
    }
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: darwin),
    );
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    await initialize();
    final android = await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    final ios = await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: false, sound: true);
    return android ?? ios ?? true;
  }

  Future<void> schedulePatternReminder(List<CravingLog> logs) async {
    await initialize();
    final hour = _mostCommonHour(logs) ?? 16;
    await _scheduleDaily(
      id: _patternReminderId,
      hour: hour,
      minute: 0,
      title: 'A gentle HabitWise check-in',
      body: 'Would food, rest, comfort, or another support help around now?',
    );
  }

  Future<void> scheduleReflectionReminder() async {
    await initialize();
    await _scheduleDaily(
      id: _reflectionReminderId,
      hour: 20,
      minute: 0,
      title: 'A private moment for you',
      body: 'Notice what helped today. No score, no streak to protect.',
    );
  }

  Future<void> cancelPatternReminder() =>
      _plugin.cancel(id: _patternReminderId);
  Future<void> cancelReflectionReminder() =>
      _plugin.cancel(id: _reflectionReminderId);

  Future<void> _scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduled,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'habitwise_gentle_reminders',
          'Gentle reminders',
          channelDescription: 'Optional private HabitWise check-ins',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  int? _mostCommonHour(List<CravingLog> logs) {
    if (logs.length < 3) return null;
    final counts = <int, int>{};
    for (final log in logs) {
      counts[log.completedAt.hour] = (counts[log.completedAt.hour] ?? 0) + 1;
    }
    final entries = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.first.key;
  }
}
