import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import '../features/medication/models/medication_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
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

  static Future<void> scheduleMedicationNotifications(Medication medication) async {
    await _ensureInitialized();

    await cancelMedicationNotifications(medication.id);

    final selectedTime = NotificationTimeUtil.parseTimeString(medication.time);

    print('📅 Scheduling notifications for ${medication.name} for ${medication.durationInDays} days');

    for (int day = 0; day < medication.durationInDays; day++) {
      final notificationDate = medication.startDate.add(Duration(days: day));

      for (int dose = 1; dose <= medication.timesPerDay; dose++) {
        await _scheduleSpecificNotification(
          medication,
          notificationDate,
          selectedTime,
          day,
          dose,
        );
      }
    }
  }

  static Future<void> _scheduleSpecificNotification(
      Medication medication,
      DateTime notificationDate,
      TimeOfDay selectedTime,
      int dayIndex,
      int doseNumber,
      ) async {
    final notificationId = int.parse(medication.id) * 1000 + dayIndex * 10 + doseNumber;
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

    final actualTime = NotificationTimeUtil.getDoseTime(selectedTime, doseNumber, medication.timesPerDay);

    final scheduledDateTime = DateTime(
      notificationDate.year,
      notificationDate.month,
      notificationDate.day,
      actualTime.hour,
      actualTime.minute,
    );

    if (scheduledDateTime.isAfter(DateTime.now())) {
      final tz.TZDateTime scheduledTime = tz.TZDateTime.from(scheduledDateTime, tz.local);
      final doseDesc = NotificationTimeUtil.getDoseDescription(doseNumber, medication.timesPerDay);

      await _notifications.zonedSchedule(
        safeNotificationId,
        '💊 Time for your medication!',
        'Take your ${medication.name} ${medication.dosage}${doseDesc.isNotEmpty ? ' ($doseDesc)' : ''}',
        scheduledTime,
        notificationDetails,
        payload: medication.id,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );

      print('⏰ Scheduled: ${medication.name} on ${scheduledDateTime.day}/${scheduledDateTime.month} at ${actualTime.hour}:${actualTime.minute.toString().padLeft(2, '0')}');
    }
  }

  static Future<void> cancelMedicationNotifications(String medicationId) async {
    await _ensureInitialized();

    final baseId = int.parse(medicationId) * 1000;
    for (int i = 0; i < 180; i++) {
      final notificationId = (baseId + i) % 2147483647;
      await _notifications.cancel(notificationId);
    }

    print('❌ Cancelled notifications for medication: $medicationId');
  }

  static Future<void> showImmediateNotification(Medication medication) async {
    await _ensureInitialized();

    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Test medication notifications',
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
      '💊 Test Medication Reminder',
      'This is a test for ${medication.name} ${medication.dosage}',
      notificationDetails,
      payload: medication.id,
    );

    print('🔔 Test notification sent for ${medication.name}');
  }

  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
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
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

// ✅ NEW: A dedicated utility class for time calculations to avoid privacy errors
class NotificationTimeUtil {
  static TimeOfDay parseTimeString(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length != 2) return const TimeOfDay(hour: 8, minute: 0);

      final hourPart = parts[0].trim();
      final minuteAndPeriod = parts[1].trim().split(' ');

      int hour = int.parse(hourPart);
      int minute = int.parse(minuteAndPeriod[0]);

      if (minuteAndPeriod.length > 1) {
        final period = minuteAndPeriod[1].toLowerCase();
        if (period == 'pm' && hour != 12) {
          hour += 12;
        } else if (period == 'am' && hour == 12) {
          hour = 0;
        }
      }
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      print('Error parsing time: $timeString, using default 8:00 AM');
      return const TimeOfDay(hour: 8, minute: 0);
    }
  }

  static TimeOfDay getDoseTime(TimeOfDay baseTime, int doseNumber, int totalDoses) {
    if (totalDoses == 1) {
      return baseTime;
    } else if (totalDoses == 2) {
      return (doseNumber == 1)
          ? baseTime
          : TimeOfDay(hour: (baseTime.hour + 12) % 24, minute: baseTime.minute);
    } else {
      final intervalInMinutes = (24 * 60) ~/ totalDoses;
      final baseMinutes = baseTime.hour * 60 + baseTime.minute;
      final newMinutes = baseMinutes + (intervalInMinutes * (doseNumber - 1));
      final newHour = (newMinutes ~/ 60) % 24;
      final newMinute = newMinutes % 60;
      return TimeOfDay(hour: newHour, minute: newMinute);
    }
  }

  static String getDoseDescription(int doseNumber, int totalDoses) {
    if (totalDoses == 1) return '';

    switch (doseNumber) {
      case 1:
        return 'Morning dose';
      case 2:
        return totalDoses == 2 ? 'Evening dose' : 'Afternoon dose';
      case 3:
        return 'Evening dose';
      case 4:
        return 'Night dose';
      default:
        return 'Dose $doseNumber';
    }
  }
}