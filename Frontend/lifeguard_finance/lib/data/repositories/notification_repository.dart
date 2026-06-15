import '../database/database_helper.dart';

class NotificationRepository {
  final DatabaseHelper _dbHelper;

  NotificationRepository(this._dbHelper);

  Future<List<Map<String, dynamic>>> fetchNotifications() async {
    return await _dbHelper.getNotifications();
  }

  Future<void> addNotification(Map<String, dynamic> notificationMap) async {
    await _dbHelper.insertNotification(notificationMap);
  }

  Future<void> markAsRead(String id) async {
    await _dbHelper.markNotificationAsRead(id);
  }
}
