import '../../../../core/error/result.dart';
import '../entities/notification.dart';

abstract interface class NotificationRepository {
  Future<Result<List<AppNotification>>> getInAppNotifications();
  Future<Result<void>> markRead(String notificationId);
  Future<Result<void>> initializePush();
  Stream<AppNotification> get pushNotifications;
  Future<Result<void>> dispose();
}
