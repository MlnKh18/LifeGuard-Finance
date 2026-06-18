import 'package:equatable/equatable.dart';

class LiteracyModule extends Equatable {
  final String moduleId;
  final String title;
  final String topic;
  final String relatedIndicator;
  final String summary;
  final String content;
  final String tips;
  final int durationMinutes;
  final String? externalUrl;
  final String? headerImageUrl;
  final bool isRecommended;

  const LiteracyModule({
    required this.moduleId,
    required this.title,
    required this.topic,
    required this.relatedIndicator,
    required this.summary,
    required this.content,
    required this.tips,
    required this.durationMinutes,
    this.externalUrl,
    this.headerImageUrl,
    this.isRecommended = false,
  });

  @override
  List<Object?> get props => [
        moduleId,
        title,
        topic,
        relatedIndicator,
        summary,
        content,
        tips,
        durationMinutes,
        externalUrl,
        headerImageUrl,
        isRecommended,
      ];
}
