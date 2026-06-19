import '../entities/early_warning.dart';

abstract class EarlyWarningRepository {
  Future<List<EarlyWarning>> getWarnings();
  Future<void> createWarning(EarlyWarning warning);
  Future<void> markAsRead(String warningId);
  Future<List<EarlyWarning>> getUnreadWarnings();
}
