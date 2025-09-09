import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import '../features/medication/models/medication_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
    print('✅ Notification Service Initialized');
  }

  static void _onNotificationTapped(NotificationResponse response) {
    final medicationId = response.payload;
    print('Notification tapped for medication: $medicationId');
  }

  static Future<bool> requestPermissions() async {
    final status = await Permission.notification.request();

    if (status.isGranted) {
      final alarmStatus = await Permission.systemAlertWindow.request();
      print('Alarm permission: ${alarmStatus.isGranted}');
    }

    return status.isGranted;
  }

  static Future<void> scheduleMedicationNotifications(
    Medication medication,
  ) async {
    await _ensureInitialized();

    await cancelMedicationNotifications(medication.id);

    final notificationTimes = _calculateNotificationTimes(
      medication.time,
      medication.timesPerDay,
    );

    print(
      '📅 Scheduling ${notificationTimes.length} notifications for ${medication.name}',
    );

    for (int i = 0; i < notificationTimes.length; i++) {
      await _scheduleRepeatingNotification(medication, notificationTimes[i], i);
    }
  }

  static List<TimeOfDay> _calculateNotificationTimes(
    String baseTime,
    int timesPerDay,
  ) {
    final List<TimeOfDay> times = [];

    final parts = baseTime.split(':');
    int hour = int.parse(parts[0]);
    final minutePart = parts[1].split(' ');
    int minute = int.parse(minutePart[0]);

    if (minutePart.length > 1) {
      final ampm = minutePart[1].toLowerCase();
      if (ampm == 'pm' && hour != 12) {
        hour += 12;
      } else if (ampm == 'am' && hour == 12) {
        hour = 0;
      }
    }

    if (timesPerDay == 1) {
      times.add(TimeOfDay(hour: hour, minute: minute));
    } else if (timesPerDay == 2) {
      times.add(const TimeOfDay(hour: 8, minute: 0));
      times.add(const TimeOfDay(hour: 20, minute: 0));
    } else if (timesPerDay == 3) {
      times.add(const TimeOfDay(hour: 8, minute: 0));
      times.add(const TimeOfDay(hour: 14, minute: 0));
      times.add(const TimeOfDay(hour: 22, minute: 0));
    } else if (timesPerDay == 4) {
      times.add(const TimeOfDay(hour: 6, minute: 0));
      times.add(const TimeOfDay(hour: 12, minute: 0));
      times.add(const TimeOfDay(hour: 18, minute: 0));
      times.add(const TimeOfDay(hour: 0, minute: 0));
    } else {
      const startHour = 6;
      const endHour = 22;
      final interval = (endHour - startHour) / (timesPerDay - 1);

      for (int i = 0; i < timesPerDay; i++) {
        final timeHour = startHour + (interval * i).round();
        times.add(TimeOfDay(hour: timeHour, minute: 0));
      }
    }

    return times;
  }

  static Future<void> _scheduleRepeatingNotification(
    Medication medication,
    TimeOfDay time,
    int index,
  ) async {
    final baseId = int.parse(medication.id);
    final int notificationId = (baseId * 10) + index;
    final safeNotificationId = notificationId % 2147483647;

    final androidDetails = AndroidNotificationDetails(
      'medication_reminders',
      'Medication Reminders',
      channelDescription: 'Notifications for medication reminders',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
      color: const Color(0xFF2196F3),
      ledColor: const Color(0xFF2196F3),
      ledOnMs: 1000,
      ledOffMs: 500,
    );

    const iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    final now = DateTime.now();
    final scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    final finalDate = scheduledDate.isBefore(now)
        ? scheduledDate.add(const Duration(days: 1))
        : scheduledDate;

    final tz.TZDateTime scheduledTime = tz.TZDateTime.from(finalDate, tz.local);

    await _notifications.zonedSchedule(
      safeNotificationId,
      '💊 Time for your medication!',
      'Take your ${medication.name} ${medication.dosage} (${medication.type})',
      scheduledTime,
      notificationDetails,
      payload: medication.id,
      matchDateTimeComponents: DateTimeComponents.time,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    final timeString =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    print(
      '⏰ Scheduled notification for ${medication.name} at $timeString (ID: $safeNotificationId)',
    );
  }

  static Future<void> cancelMedicationNotifications(String medicationId) async {
    await _ensureInitialized();

    final baseId = int.parse(medicationId);
    for (int i = 0; i < 6; i++) {
      final notificationId = ((baseId * 10) + i) % 2147483647;
      await _notifications.cancel(notificationId);
    }

    print('❌ Cancelled notifications for medication: $medicationId');
  }

  static Future<void> showImmediateNotification(Medication medication) async {
    await _ensureInitialized();

    const androidDetails = AndroidNotificationDetails(
      'medication_reminders',
      'Medication Reminders',
      channelDescription: 'Notifications for medication reminders',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _notifications.show(
      999,
      '💊 Medication Reminder',
      'Take your ${medication.name} ${medication.dosage} now!',
      notificationDetails,
      payload: medication.id,
    );

    print('🔔 Test notification sent for ${medication.name}');
  }

  static Future<List<PendingNotificationRequest>>
  getPendingNotifications() async {
    await _ensureInitialized();
    return await _notifications.pendingNotificationRequests();
  }

  static Future<void> cancelAllNotifications() async {
    await _ensureInitialized();
    await _notifications.cancelAll();
    print('❌ All notifications cancelled');
  }

  static Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
  }
}

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}
