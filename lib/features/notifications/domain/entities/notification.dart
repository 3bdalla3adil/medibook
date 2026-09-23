import 'package:equatable/equatable.dart';

enum NotificationChannel { inApp, push }
enum NotificationType { appointment, consultation, prescription, billing, security, system }

class AppNotification extends Equatable {
  const AppNotification({required this.id, required this.type, required this.channel, required this.title, required this.createdAt, this.body, this.readAt, this.action});
  final String id; final NotificationType type; final NotificationChannel channel; final String title; final String? body; final DateTime createdAt; final DateTime? readAt; final String? action;
  bool get isRead => readAt != null;
  @override List<Object?> get props => [id, type, channel, title, body, createdAt, readAt, action];
}
