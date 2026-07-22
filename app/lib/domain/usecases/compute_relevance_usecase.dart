import 'package:newsletter_portal/domain/entities/article.dart';
import 'package:newsletter_portal/domain/entities/report_section.dart';

class ComputeRelevanceUseCase {
  double computeScore(Article article, ReportSection sectionConfig) {
    double sectorRelevanceScore = 1.0;
    double regionRelevanceScore = 1.0;
    double tagRelevanceScore = 1.0;

    // Calculate tag relevance matching
    if (sectionConfig.tags.isNotEmpty) {
      bool matchesTag = false;
      final textToSearch = '${article.title} ${article.synopsis ?? ""} ${article.sector ?? ""} ${article.region ?? ""}'.toLowerCase();
      for (final tag in sectionConfig.tags) {
        if (textToSearch.contains(tag.toLowerCase())) {
          matchesTag = true;
          break;
        }
      }
      tagRelevanceScore = matchesTag ? 1.0 : 0.3;
    }

    // Calculate sector relevance
    if (sectionConfig.sectorWeights.isNotEmpty) {
      double totalSectorWeight = sectionConfig.sectorWeights.values.fold(0, (sum, weight) => sum + weight);
      
      double matchedWeight = 0;
      int? articleSectorId = int.tryParse(article.sector ?? '');
      if (articleSectorId != null && sectionConfig.sectorWeights.containsKey(articleSectorId)) {
        matchedWeight = sectionConfig.sectorWeights[articleSectorId]!.toDouble();
      }
      
      sectorRelevanceScore = totalSectorWeight > 0 ? (matchedWeight / totalSectorWeight) : 1.0;
    }

    // Calculate region relevance
    if (sectionConfig.regionWeights.isNotEmpty) {
      double totalRegionWeight = sectionConfig.regionWeights.values.fold(0, (sum, weight) => sum + weight);
      
      double matchedWeight = 0;
      if (article.region != null && sectionConfig.regionWeights.containsKey(article.region)) {
        matchedWeight = sectionConfig.regionWeights[article.region]!.toDouble();
      }
      
      regionRelevanceScore = totalRegionWeight > 0 ? (matchedWeight / totalRegionWeight) : 1.0;
    }

    return sectorRelevanceScore * regionRelevanceScore * tagRelevanceScore;
  }
}
