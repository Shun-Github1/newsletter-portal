import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newsletter_portal/core/constants/api_constants.dart';
import 'package:newsletter_portal/domain/entities/article.dart';
import 'package:newsletter_portal/domain/entities/report_preset.dart';
import 'package:newsletter_portal/domain/entities/report_section.dart';
import 'package:newsletter_portal/domain/repositories/feed_repository.dart';
import 'package:newsletter_portal/data/datasources/article_remote_datasource.dart';
import 'package:newsletter_portal/presentation/providers/feed_provider.dart';

enum ReportStep { customization, selection, preview }

class ReportState {
  final ReportStep currentStep;
  final ReportPreset? activePreset;
  final Map<String, List<Article>> previewArticles;
  final Map<String, Set<String>> selectedArticleIds;
  final bool isLoading;

  ReportState({
    this.currentStep = ReportStep.customization,
    this.activePreset,
    this.previewArticles = const {},
    this.selectedArticleIds = const {},
    this.isLoading = false,
  });

  ReportState copyWith({
    ReportStep? currentStep,
    ReportPreset? activePreset,
    Map<String, List<Article>>? previewArticles,
    Map<String, Set<String>>? selectedArticleIds,
    bool? isLoading,
  }) {
    return ReportState(
      currentStep: currentStep ?? this.currentStep,
      activePreset: activePreset ?? this.activePreset,
      previewArticles: previewArticles ?? this.previewArticles,
      selectedArticleIds: selectedArticleIds ?? this.selectedArticleIds,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ReportNotifier extends StateNotifier<ReportState> {
  final FeedRepository _feedRepository;
  final ArticleRemoteDatasource _articleRemoteDatasource;

  ReportNotifier(this._feedRepository, this._articleRemoteDatasource) : super(ReportState());

  void loadPreset(ReportPreset preset) {
    var effectivePreset = preset;
    if (effectivePreset.sections.isEmpty) {
      effectivePreset = effectivePreset.copyWith(
        sections: [
          ReportSection(
            id: 'section-1',
            title: 'New Section 1',
            sectorWeights: const {},
            regionWeights: const {},
            tags: const [],
            minItems: 1,
            maxItems: 10,
            sentimentThreshold: 0.0,
          ),
        ],
      );
    }
    state = state.copyWith(
      activePreset: effectivePreset,
      currentStep: ReportStep.customization,
      previewArticles: {},
      selectedArticleIds: {},
    );
    refreshPreview();
  }

  void updateSection(String sectionId, ReportSection updated) {
    if (state.activePreset == null) return;
    final sections = state.activePreset!.sections.map((s) => s.id == sectionId ? updated : s).toList();
    state = state.copyWith(
      activePreset: state.activePreset!.copyWith(sections: sections),
    );
    refreshPreview();
  }

  void addSection(ReportSection section) {
    if (state.activePreset == null) return;
    final sections = [...state.activePreset!.sections, section];
    state = state.copyWith(
      activePreset: state.activePreset!.copyWith(sections: sections),
    );
    refreshPreview();
  }

  void removeSection(String sectionId) {
    if (state.activePreset == null) return;
    var sections = state.activePreset!.sections.where((s) => s.id != sectionId).toList();
    if (sections.isEmpty) {
      sections = [
        ReportSection(
          id: 'section-${DateTime.now().millisecondsSinceEpoch}',
          title: 'New Section 1',
          sectorWeights: const {},
          regionWeights: const {},
          tags: const [],
          minItems: 1,
          maxItems: 10,
          sentimentThreshold: 0.0,
        ),
      ];
    }
    state = state.copyWith(
      activePreset: state.activePreset!.copyWith(sections: sections),
    );
    refreshPreview();
  }

  Future<void> refreshPreview() async {
    if (state.activePreset == null) return;
    state = state.copyWith(isLoading: true);
    
    try {
      final feedArticles = await _feedRepository.getPersonalFeed(limit: 60);
      Map<String, List<Article>> newPreview = {};
      
      for (final section in state.activePreset!.sections) {
        final List<Article> sectionArticles = [];

        // 1. Tag-Based Article Retrieval (if tags are configured)
        if (section.tags.isNotEmpty) {
          for (final tag in section.tags) {
            try {
              final tagArticles = await _feedRepository.getHomeFeed(tag: tag, limit: 30);
              for (final tArt in tagArticles) {
                if (!sectionArticles.any((a) => a.id == tArt.id)) {
                  sectionArticles.add(tArt);
                }
              }
            } catch (_) {}
          }
          // Also match local feed articles against tags
          for (final article in feedArticles) {
            final text = '${article.title} ${article.synopsis ?? ""} ${article.sector ?? ""} ${article.region ?? ""}'.toLowerCase();
            final matches = section.tags.any((t) => text.contains(t.toLowerCase()));
            if (matches && !sectionArticles.any((a) => a.id == article.id)) {
              sectionArticles.add(article);
            }
          }
        }

        // 2. Fallback if section has no tags or tag search yielded 0 items
        if (sectionArticles.isEmpty) {
          sectionArticles.addAll(feedArticles.take(15));
        }

        // Limit to section maxItems
        final maxCount = section.maxItems > 0 ? section.maxItems : 10;
        final candidates = sectionArticles.take(maxCount).toList();

        // Enrich candidates with real synopsis & implications from GET /article/{id}
        final List<Article> enriched = [];
        for (final art in candidates) {
          if (art.synopsis == null || art.synopsis!.trim().isEmpty || art.synopsis == art.title) {
            try {
              final detail = await _articleRemoteDatasource.getArticle(art.id);
              final syn = detail.description?.synopsis?.trim();
              final imp = detail.description?.implications?.trim();
              
              final parts = <String>[];
              if (syn != null && syn.isNotEmpty) parts.add(syn);
              if (imp != null && imp.isNotEmpty) parts.add('Implications: $imp');
              final combined = parts.isNotEmpty ? parts.join('\n\n') : null;

              enriched.add(art.copyWith(
                synopsis: combined ?? art.synopsis,
                implications: imp ?? art.implications,
                sentimentScore: detail.metrics?.sentiment ?? art.sentimentScore,
                subjectivityScore: detail.metrics?.subjectivity ?? art.subjectivityScore,
                sourceCount: detail.articles?.length ?? art.sourceCount,
              ));
            } catch (_) {
              enriched.add(art);
            }
          } else {
            enriched.add(art);
          }
        }

        newPreview[section.id] = enriched;
      }

      state = state.copyWith(
        previewArticles: newPreview,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void proceedToSelection() {
    if (state.activePreset == null) return;
    
    Map<String, Set<String>> preSelections = {};
    for (final section in state.activePreset!.sections) {
      final articles = state.previewArticles[section.id] ?? [];
      final topArticles = articles.take(10).map((a) => a.id).toSet();
      preSelections[section.id] = topArticles;
    }

    state = state.copyWith(
      currentStep: ReportStep.selection,
      selectedArticleIds: preSelections,
    );
  }

  void toggleArticle(String sectionId, String articleId) {
    final currentSelection = Set<String>.from(state.selectedArticleIds[sectionId] ?? {});
    if (currentSelection.contains(articleId)) {
      currentSelection.remove(articleId);
    } else {
      currentSelection.add(articleId);
    }
    
    final newSelections = Map<String, Set<String>>.from(state.selectedArticleIds);
    newSelections[sectionId] = currentSelection;
    
    state = state.copyWith(selectedArticleIds: newSelections);
  }

  Future<void> loadMoreArticles(String sectionId) async {
    // Dummy implementation. In real app, fetch with offset.
    // E.g., await _feedRepository.getPersonalFeed(...) and add to previewArticles[sectionId].
  }

  void proceedToPreview() {
    state = state.copyWith(currentStep: ReportStep.preview);
  }

  void goBack() {
    if (state.currentStep == ReportStep.preview) {
      state = state.copyWith(currentStep: ReportStep.selection);
    } else if (state.currentStep == ReportStep.selection) {
      state = state.copyWith(currentStep: ReportStep.customization);
    }
  }

  void updateGlobalSettings(SummaryMode? mode, String? language) {
    if (state.activePreset == null) return;
    state = state.copyWith(
      activePreset: state.activePreset!.copyWith(
        summaryMode: mode,
        language: language,
      ),
    );
  }

  void updateTemplates({
    String? tier1,
    String? tier2,
    String? tier3,
  }) {
    if (state.activePreset == null) return;
    state = state.copyWith(
      activePreset: state.activePreset!.copyWith(
        tier1Template: tier1,
        tier2Template: tier2,
        tier3Template: tier3,
      ),
    );
  }
}

final reportStateProvider = StateNotifierProvider<ReportNotifier, ReportState>((ref) {
  return ReportNotifier(
    ref.watch(feedRepositoryProvider),
    ref.watch(articleRemoteDatasourceProvider),
  );
});
