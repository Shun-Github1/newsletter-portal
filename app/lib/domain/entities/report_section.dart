class ReportSection {
  final String id;
  final String title;
  final Map<int, int> sectorWeights;
  final Map<String, int> regionWeights;
  final List<String> tags;
  final int minItems;
  final int maxItems;
  final double sentimentThreshold;

  // Tier 3 News Item Datafield Display Flags
  final bool showDate;
  final bool showRegionSector;
  final bool showSentimentSubjectivity;
  final bool showSourceCount;
  final bool showSynopsis;

  const ReportSection({
    required this.id,
    required this.title,
    required this.sectorWeights,
    required this.regionWeights,
    required this.tags,
    required this.minItems,
    required this.maxItems,
    required this.sentimentThreshold,
    this.showDate = true,
    this.showRegionSector = true,
    this.showSentimentSubjectivity = true,
    this.showSourceCount = true,
    this.showSynopsis = true,
  });

  ReportSection copyWith({
    String? id,
    String? title,
    Map<int, int>? sectorWeights,
    Map<String, int>? regionWeights,
    List<String>? tags,
    int? minItems,
    int? maxItems,
    double? sentimentThreshold,
    bool? showDate,
    bool? showRegionSector,
    bool? showSentimentSubjectivity,
    bool? showSourceCount,
    bool? showSynopsis,
  }) {
    return ReportSection(
      id: id ?? this.id,
      title: title ?? this.title,
      sectorWeights: sectorWeights ?? this.sectorWeights,
      regionWeights: regionWeights ?? this.regionWeights,
      tags: tags ?? this.tags,
      minItems: minItems ?? this.minItems,
      maxItems: maxItems ?? this.maxItems,
      sentimentThreshold: sentimentThreshold ?? this.sentimentThreshold,
      showDate: showDate ?? this.showDate,
      showRegionSector: showRegionSector ?? this.showRegionSector,
      showSentimentSubjectivity: showSentimentSubjectivity ?? this.showSentimentSubjectivity,
      showSourceCount: showSourceCount ?? this.showSourceCount,
      showSynopsis: showSynopsis ?? this.showSynopsis,
    );
  }
}
