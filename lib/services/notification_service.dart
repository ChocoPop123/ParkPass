import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

// Wraps flutter_local_notifications so the rest of the app just calls
// simple methods like showTicketGenerated() and scheduleDepartureReminder()
// without needing to know about channels, IDs, or timezone setup.
//
// These are LOCAL notifications — they're scheduled and fired by the phone
// itself, not sent from a server, which is why they work with no internet.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const String _ticketChannelId = 'ticket_updates';
  static const String _ticketChannelName = 'Ticket Updates';

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    // Android 13+ requires this permission to be requested explicitly.
    await _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  // Fired immediately once a booking is successfully created.
  Future<void> showTicketGenerated({
    required String origin,
    required String destination,
  }) async {
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // unique-enough id
      'Ticket Confirmed ✓',
      'Your ticket for $origin → $destination has been generated.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _ticketChannelId,
          _ticketChannelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // Scheduled once at booking time to fire 15 minutes before departure.
  // If departure is already less than 15 minutes away (or in the past),
  // nothing is scheduled.
  Future<void> scheduleDepartureReminder({
    required String bookingId,
    required String origin,
    required String destination,
    required DateTime departureTime,
  }) async {
    final reminderTime = departureTime.subtract(const Duration(minutes: 15));
    if (reminderTime.isBefore(DateTime.now())) return;

    // Derives a stable, unique-enough integer notification ID from the
    // booking ID's hash, so rescheduling the same booking overwrites
    // rather than duplicates.
    final notificationId = bookingId.hashCode & 0x7fffffff;

    await _plugin.zonedSchedule(
      notificationId,
      'Departure in 15 minutes',
      'Your bus from $origin to $destination departs soon. Head to boarding!',
      tz.TZDateTime.from(reminderTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _ticketChannelId,
          _ticketChannelName,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}