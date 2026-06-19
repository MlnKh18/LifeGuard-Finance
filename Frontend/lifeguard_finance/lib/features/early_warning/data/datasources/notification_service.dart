import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../domain/entities/early_warning.dart';

/// Thin wrapper around flutter_local_notifications for prototype-grade local
/// (not push/remote) notifications, per project spec Step 14.
class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings, macOS: iosSettings);
    await _plugin.initialize(settings);
    _initialized = true;
  }

  /// Requests notification permission on Android 13+ and iOS/macOS. Returns
  /// true if granted (or if the platform doesn't require an explicit prompt).
  Future<bool> requestPermission() async {
    final androidGranted = await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    final iosGranted = await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    return (androidGranted ?? true) && (iosGranted ?? true);
  }

  Future<void> showWarning(EarlyWarning warning) async {
    if (!_initialized) await init();
    const androidDetails = AndroidNotificationDetails(
      'early_warning_channel',
      'Peringatan Dini Finansial',
      channelDescription: 'Notifikasi peringatan dini kondisi keuangan keluarga',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails, macOS: iosDetails);
    await _plugin.show(warning.warningId.hashCode, warning.title, warning.message, details);
  }
}
