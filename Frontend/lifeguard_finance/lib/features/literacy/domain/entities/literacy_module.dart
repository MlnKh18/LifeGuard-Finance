import 'package:equatable/equatable.dart';

class LiteracyModule extends Equatable {
  final String moduleId;
  final String title;
  final String topic;
  final String relatedIndicator;
  final String? relatedIndicatorLabel;
  final String summary;
  final String content;
  final List<String> keyTakeaways;
  final List<String> practicalTips;
  final int durationMinutes;
  final String? sourceName;
  final String? externalUrl;
  final String? headerImageUrl;
  final bool isRecommended;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const LiteracyModule({
    required this.moduleId,
    required this.title,
    required this.topic,
    required this.relatedIndicator,
    this.relatedIndicatorLabel,
    required this.summary,
    required this.content,
    required this.keyTakeaways,
    required this.practicalTips,
    required this.durationMinutes,
    this.sourceName,
    this.externalUrl,
    this.headerImageUrl,
    this.isRecommended = false,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        moduleId,
        title,
        topic,
        relatedIndicator,
        relatedIndicatorLabel,
        summary,
        content,
        keyTakeaways,
        practicalTips,
        durationMinutes,
        sourceName,
        externalUrl,
        headerImageUrl,
        isRecommended,
        createdAt,
        updatedAt,
      ];
}
