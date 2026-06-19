import 'package:equatable/equatable.dart';

class UserLiteracyProgress extends Equatable {
  final String progressId;
  final String userId;
  final String? userEmail;
  final String moduleId;
  final bool isRead;
  final DateTime? readAt;
  final double progressPercentage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserLiteracyProgress({
    required this.progressId,
    required this.userId,
    this.userEmail,
    required this.moduleId,
    this.isRead = false,
    this.readAt,
    this.progressPercentage = 0.0,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        progressId,
        userId,
        userEmail,
        moduleId,
        isRead,
        readAt,
        progressPercentage,
        createdAt,
        updatedAt,
      ];
}
