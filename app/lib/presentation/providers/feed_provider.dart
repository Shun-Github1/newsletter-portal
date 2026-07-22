import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newsletter_portal/domain/entities/article.dart';
import 'package:newsletter_portal/domain/repositories/feed_repository.dart';
import 'package:newsletter_portal/core/network/dio_client.dart';
import 'package:newsletter_portal/data/datasources/feed_remote_datasource.dart';
import 'package:newsletter_portal/data/datasources/search_remote_datasource.dart';
import 'package:newsletter_portal/data/datasources/article_remote_datasource.dart';
import 'package:newsletter_portal/data/repositories/feed_repository_impl.dart';

class FeedState {
  final List<Article> articles;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final String? error;
  final String? sortBy;

  FeedState({
    this.articles = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 0,
    this.error,
    this.sortBy,
  });

  FeedState copyWith({
    List<Article>? articles,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    String? error,
    String? sortBy,
  }) {
    return FeedState(
      articles: articles ?? this.articles,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error ?? this.error,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

class FeedNotifier extends StateNotifier<FeedState> {
  final FeedRepository _repository;
  final bool _isPersonal;

  FeedNotifier(this._repository, {bool isPersonal = true}) 
    : _isPersonal = isPersonal, 
      super(FeedState());

  Future<void> loadInitial({String? lang}) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null, currentPage: 0);

    try {
      final articles = _isPersonal 
        ? await _repository.getPersonalFeed(offset: 0, sortby: state.sortBy, lang: lang)
        : await _repository.getHomeFeed(offset: 0, lang: lang);
      
      state = state.copyWith(
        articles: articles,
        isLoading: false,
        hasMore: articles.isNotEmpty,
        currentPage: 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore({String? lang}) async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final offset = state.currentPage * 20;
      final newArticles = _isPersonal
        ? await _repository.getPersonalFeed(offset: offset, sortby: state.sortBy, lang: lang)
        : await _repository.getHomeFeed(offset: offset, lang: lang);
      
      state = state.copyWith(
        articles: [...state.articles, ...newArticles],
        isLoading: false,
        hasMore: newArticles.isNotEmpty,
        currentPage: state.currentPage + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh({String? lang}) async {
    await loadInitial(lang: lang);
  }

  void changeSortBy(String sortBy, {String? lang}) {
    state = state.copyWith(sortBy: sortBy);
    loadInitial(lang: lang);
  }
}


final feedRemoteDatasourceProvider = Provider<FeedRemoteDatasource>((ref) {
  final dio = ref.watch(dioClientProvider).dio;
  return FeedRemoteDatasource(dio);
});

final searchRemoteDatasourceProvider = Provider<SearchRemoteDatasource>((ref) {
  final dio = ref.watch(dioClientProvider).dio;
  return SearchRemoteDatasource(dio);
});

final articleRemoteDatasourceProvider = Provider<ArticleRemoteDatasource>((ref) {
  final dio = ref.watch(dioClientProvider).dio;
  return ArticleRemoteDatasource(dio);
});

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  final feedDs = ref.watch(feedRemoteDatasourceProvider);
  final searchDs = ref.watch(searchRemoteDatasourceProvider);
  return FeedRepositoryImpl(feedDatasource: feedDs, searchDatasource: searchDs);
});

final personalFeedProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  return FeedNotifier(ref.watch(feedRepositoryProvider), isPersonal: true)..loadInitial();
});

final homeFeedProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  return FeedNotifier(ref.watch(feedRepositoryProvider), isPersonal: false)..loadInitial();
});
