import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import '../features/medication/models/medication_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  // Initialize notification service
  static Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combined initialization settings
    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize the plugin
    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
    print('✅ Notification Service Initialized');
  }

  // Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    final medicationId = response.payload;
    print('Notification tapped for medication: $medicationId');

    // Here you can navigate to medication detail screen
    // You'll need to use a global navigator key for this
  }

  // Request notification permissions
  static Future<bool> requestPermissions() async {
    // Request notification permission
    final status = await Permission.notification.request();

    // For Android 13+ (API 33+), also request POST_NOTIFICATIONS
    if (status.isGranted) {
      // Request exact alarm permission for precise timing
      final alarmStatus = await Permission.systemAlertWindow.request();
      print('Alarm permission: ${alarmStatus.isGranted}');
    }

    return status.isGranted;
  }

  // Schedule medication notifications
  static Future<void> scheduleMedicationNotifications(Medication medication) async {
    await _ensureInitialized();

    // Cancel existing notifications for this medication
    await cancelMedicationNotifications(medication.id);

    // Calculate notification times based on frequency
    final notificationTimes = _calculateNotificationTimes(
        medication.time,
        medication.timesPerDay
    );

    print('📅 Scheduling ${notificationTimes.length} notifications for ${medication.name}');

    // Schedule each notification
    for (int i = 0; i < notificationTimes.length; i++) {
      await _scheduleRepeatingNotification(
        medication,
        notificationTimes[i],
        i,
      );
    }
  }

  // Calculate notification times throughout the day
  static List<TimeOfDay> _calculateNotificationTimes(String baseTime, int timesPerDay) {
    final List<TimeOfDay> times = [];

    // Parse the base time (e.g., "9:00 PM")
    final parts = baseTime.split(':');
    int hour = int.parse(parts[0]);
    final minutePart = parts[1].split(' ');
    int minute = int.parse(minutePart[0]);

    // Handle AM/PM
    if (minutePart.length > 1) {
      final ampm = minutePart[1].toLowerCase();
      if (ampm == 'pm' && hour != 12) {
        hour += 12;
      } else if (ampm == 'am' && hour == 12) {
        hour = 0;
      }
    }

    if (timesPerDay == 1) {
      // Once daily - use exact time
      times.add(TimeOfDay(hour: hour, minute: minute));
    } else if (timesPerDay == 2) {
      // Twice daily - morning and evening
      times.add(const TimeOfDay(hour: 8, minute: 0));   // 8:00 AM
      times.add(const TimeOfDay(hour: 20, minute: 0));  // 8:00 PM
    } else if (timesPerDay == 3) {
      // Three times daily
      times.add(const TimeOfDay(hour: 8, minute: 0));   // 8:00 AM
      times.add(const TimeOfDay(hour: 14, minute: 0));  // 2:00 PM
      times.add(const TimeOfDay(hour: 22, minute: 0));  // 10:00 PM
    } else if (timesPerDay == 4) {
      // Four times daily (every 6 hours)
      times.add(const TimeOfDay(hour: 6, minute: 0));   // 6:00 AM
      times.add(const TimeOfDay(hour: 12, minute: 0));  // 12:00 PM
      times.add(const TimeOfDay(hour: 18, minute: 0));  // 6:00 PM
      times.add(const TimeOfDay(hour: 0, minute: 0));   // 12:00 AM (fixed from hour: 24)
    } else {
      // For 5-6 times, distribute evenly throughout waking hours
      const startHour = 6;  // 6 AM
      const endHour = 22;   // 10 PM
      final interval = (endHour - startHour) / (timesPerDay - 1);

      for (int i = 0; i < timesPerDay; i++) {
        final timeHour = startHour + (interval * i).round();
        times.add(TimeOfDay(hour: timeHour, minute: 0));
      }
    }

    return times;
  }

  // Schedule a single repeating notification
  static Future<void> _scheduleRepeatingNotification(
      Medication medication,
      TimeOfDay time,
      int index,
      ) async {
    final int notificationId = int.parse(medication.id) + index;

    // Create notification details
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

    // Calculate next notification time
    final now = DateTime.now();
    final scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If the time has passed today, schedule for tomorrow
    final finalDate = scheduledDate.isBefore(now)
        ? scheduledDate.add(const Duration(days: 1))
        : scheduledDate;

    final tz.TZDateTime scheduledTime = tz.TZDateTime.from(finalDate, tz.local);

    // Schedule the notification
    await _notifications.zonedSchedule(
      notificationId,
      '💊 Time for your medication!',
      'Take your ${medication.name} ${medication.dosage} (${medication.type})',
      scheduledTime,
      notificationDetails,
      payload: medication.id,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );

    // ✅ FIXED: Better time formatting without context dependency
    final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    print('⏰ Scheduled notification for ${medication.name} at $timeString');
  }

  // Cancel all notifications for a medication
  static Future<void> cancelMedicationNotifications(String medicationId) async {
    await _ensureInitialized();

    // Cancel notifications with IDs based on medication ID
    final baseId = int.parse(medicationId);
    for (int i = 0; i < 6; i++) { // Max 6 notifications per day
      await _notifications.cancel(baseId + i);
    }

    print('❌ Cancelled notifications for medication: $medicationId');
  }

  // Show immediate notification (for testing)
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
      999, // Test notification ID
      '💊 Test Medication Reminder',
      'Take your ${medication.name} ${medication.dosage} now!',
      notificationDetails,
      payload: medication.id,
    );

    print('🔔 Test notification sent for ${medication.name}');
  }

  // Get pending notifications (for debugging)
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    await _ensureInitialized();
    return await _notifications.pendingNotificationRequests();
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _ensureInitialized();
    await _notifications.cancelAll();
    print('❌ All notifications cancelled');
  }

  // Private helper methods
  static Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
  }

  // ✅ NEW: Helper method to format time without context
  static String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}

// Global navigator key for navigation from notifications
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}
