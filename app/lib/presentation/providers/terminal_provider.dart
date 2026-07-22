import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newsletter_portal/core/constants/api_constants.dart';
import 'package:newsletter_portal/domain/entities/article.dart';
import 'package:newsletter_portal/domain/repositories/feed_repository.dart';
import 'package:newsletter_portal/presentation/providers/feed_provider.dart';

class TerminalState {
  final List<Article> articles;
  final Map<int, int> sectorWeights;
  final Map<String, int> regionWeights;
  final Set<String> selectedTags;
  final FeedSortBy sortBy;
  final bool isLoading;
  final bool hasMore;

  TerminalState({
    this.articles = const [],
    this.sectorWeights = const {},
    this.regionWeights = const {},
    this.selectedTags = const {},
    this.sortBy = FeedSortBy.latest,
    this.isLoading = false,
    this.hasMore = true,
  });

  TerminalState copyWith({
    List<Article>? articles,
    Map<int, int>? sectorWeights,
    Map<String, int>? regionWeights,
    Set<String>? selectedTags,
    FeedSortBy? sortBy,
    bool? isLoading,
    bool? hasMore,
  }) {
    return TerminalState(
      articles: articles ?? this.articles,
      sectorWeights: sectorWeights ?? this.sectorWeights,
      regionWeights: regionWeights ?? this.regionWeights,
      selectedTags: selectedTags ?? this.selectedTags,
      sortBy: sortBy ?? this.sortBy,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class TerminalNotifier extends StateNotifier<TerminalState> {
  final FeedRepository _feedRepository;

  TerminalNotifier(this._feedRepository) : super(TerminalState());

  Future<void> loadFeed() async {
    state = state.copyWith(isLoading: true, hasMore: true);
    try {
      final articles = await _feedRepository.getPersonalFeed(
        sortby: state.sortBy.name,
        limit: 40,
      );
      state = state.copyWith(
        articles: articles,
        isLoading: false,
        hasMore: articles.length >= 40,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void applyFilters({
    Map<int, int>? sectorWeights,
    Map<String, int>? regionWeights,
    Set<String>? selectedTags,
  }) {
    state = state.copyWith(
      sectorWeights: sectorWeights,
      regionWeights: regionWeights,
      selectedTags: selectedTags,
    );
    loadFeed();
  }

  void changeSortBy(FeedSortBy sortBy) {
    state = state.copyWith(sortBy: sortBy);
    loadFeed();
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true);
    try {
      final newArticles = await _feedRepository.getPersonalFeed(
        offset: state.articles.length,
        sortby: state.sortBy.name,
        limit: 40,
      );
      state = state.copyWith(
        articles: [...state.articles, ...newArticles],
        isLoading: false,
        hasMore: newArticles.length >= 40,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> refresh() async {
    await loadFeed();
  }
}

final terminalFeedProvider = StateNotifierProvider<TerminalNotifier, TerminalState>((ref) {
  return TerminalNotifier(ref.watch(feedRepositoryProvider))..loadFeed();
});
