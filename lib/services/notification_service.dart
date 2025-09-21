import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import '../features/medication/models/medication_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static const String _lastNotificationIdKey = 'last_notification_id';

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
      final alarmStatus = await Permission.scheduleExactAlarm.request();
      print('Alarm permission: ${alarmStatus.isGranted}');
    }

    return status.isGranted;
  }

  static Future<int> _getNextNotificationId() async {
    final prefs = await SharedPreferences.getInstance();
    int lastId = prefs.getInt(_lastNotificationIdKey) ?? 0;
    lastId++;
    await prefs.setInt(_lastNotificationIdKey, lastId);
    return lastId;
  }

  static Future<void> scheduleMedicationNotifications(Medication medication) async {
    await _ensureInitialized();

    await cancelMedicationNotifications(medication.id);

    final baseTime = NotificationTimeUtil.parseTimeString(medication.time);

    print('📅 Scheduling notifications for ${medication.name} for ${medication.durationInDays} days');

    for (int day = 0; day < medication.durationInDays; day++) {
      final notificationDate = medication.startDate.add(Duration(days: day));
      if (!medication.isActiveOnDate(notificationDate)) {
        continue;
      }

      for (int dose = 1; dose <= medication.timesPerDay; dose++) {
        final notificationId = await _getNextNotificationId();
        await _scheduleSpecificNotification(
          notificationId,
          medication,
          notificationDate,
          baseTime,
          dose,
        );
      }
    }
  }

  static Future<void> _scheduleSpecificNotification(
      int notificationId,
      Medication medication,
      DateTime notificationDate,
      TimeOfDay baseTime,
      int doseNumber,
      ) async {

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

    final actualTime = NotificationTimeUtil.getDoseTime(baseTime, doseNumber, medication.timesPerDay);

    DateTime scheduledDateTime = DateTime(
      notificationDate.year,
      notificationDate.month,
      notificationDate.day,
      actualTime.hour,
      actualTime.minute,
    );

    if (scheduledDateTime.isBefore(DateTime.now())) {
      scheduledDateTime = scheduledDateTime.add(const Duration(days: 1));
    }

    final tz.TZDateTime scheduledTime = tz.TZDateTime.from(scheduledDateTime, tz.local);
    final doseDesc = NotificationTimeUtil.getDoseDescription(doseNumber, medication.timesPerDay);

    await _notifications.zonedSchedule(
      notificationId,
      '💊 Time for your medication!',
      'Take your ${medication.name} ${medication.dosage}${doseDesc.isNotEmpty ? ' ($doseDesc)' : ''}',
      scheduledTime,
      notificationDetails,
      payload: medication.id,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );

    print('⏰ Scheduled: ${medication.name} on ${scheduledDateTime.day}/${scheduledDateTime.month} at ${actualTime.hour}:${actualTime.minute.toString().padLeft(2, '0')}');
  }

  static Future<void> cancelMedicationNotifications(String medicationId) async {
    await _ensureInitialized();

    final pendingNotifications = await _notifications.pendingNotificationRequests();
    final notificationsToCancel = pendingNotifications.where((p) => p.payload == medicationId);

    for (var notification in notificationsToCancel) {
      await _notifications.cancel(notification.id);
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

  static Future<void> showMissedDoseNotification(Medication medication, int missedDoses) async {
    await _ensureInitialized();

    final androidDetails = AndroidNotificationDetails(
      'missed_dose_alerts',
      'Missed Dose Alerts',
      channelDescription: 'Alerts for when you miss multiple medication doses',
      importance: Importance.max,
      priority: Priority.max,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
      color: Colors.red,
      ledColor: Colors.red,
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

    final notificationId = await _getNextNotificationId();

    await _notifications.show(
      notificationId,
      '🚨 Missed Medication Alert!',
      'You have missed $missedDoses consecutive doses of ${medication.name}. Please take your medication as soon as possible.',
      notificationDetails,
      payload: medication.id,
    );

    print('🔔 Missed dose alert sent for ${medication.name}');
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

class NotificationTimeUtil {
  static TimeOfDay parseTimeString(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length != 2) return const TimeOfDay(hour: 8, minute: 0);

      final hourPart = parts[0].trim();
      final minutePart = parts[1].trim();

      int hour = int.parse(hourPart);
      int minute = int.parse(minutePart);

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
      final interval = 12; // 12 hours between doses
      final newHour = (baseTime.hour + interval) % 24;
      return (doseNumber == 1)
          ? baseTime
          : TimeOfDay(hour: newHour, minute: baseTime.minute);
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