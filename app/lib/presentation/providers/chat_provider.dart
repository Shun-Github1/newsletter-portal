import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:newsletter_portal/domain/entities/chat_message.dart';
import 'package:newsletter_portal/domain/entities/article.dart';
import 'package:newsletter_portal/data/datasources/local/chat_local_datasource.dart';
import 'package:newsletter_portal/core/network/local_llm_service.dart';
import 'package:newsletter_portal/data/datasources/article_remote_datasource.dart';
import 'package:newsletter_portal/presentation/providers/feed_provider.dart';
import 'package:newsletter_portal/data/models/article_detail_model.dart';

class ChatState {
  final String? activeProjectId;
  final List<ChatMessage> messages;
  final Set<String> contextArticleIds;
  final Map<String, Article> fetchedArticles;
  final Set<String> fetchingArticleIds;
  final bool isLoading;
  final String streamingText;

  const ChatState({
    this.activeProjectId,
    this.messages = const [],
    this.contextArticleIds = const {},
    this.fetchedArticles = const {},
    this.fetchingArticleIds = const {},
    this.isLoading = false,
    this.streamingText = '',
  });

  ChatState copyWith({
    String? activeProjectId,
    List<ChatMessage>? messages,
    Set<String>? contextArticleIds,
    Map<String, Article>? fetchedArticles,
    Set<String>? fetchingArticleIds,
    bool? isLoading,
    String? streamingText,
  }) {
    return ChatState(
      activeProjectId: activeProjectId ?? this.activeProjectId,
      messages: messages ?? this.messages,
      contextArticleIds: contextArticleIds ?? this.contextArticleIds,
      fetchedArticles: fetchedArticles ?? this.fetchedArticles,
      fetchingArticleIds: fetchingArticleIds ?? this.fetchingArticleIds,
      isLoading: isLoading ?? this.isLoading,
      streamingText: streamingText ?? this.streamingText,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatLocalDatasource _datasource;
  final LocalLlmService _llmService;
  final ArticleRemoteDatasource _articleDatasource;
  final _uuid = const Uuid();

  ChatNotifier(this._datasource, this._llmService, this._articleDatasource) : super(const ChatState());

  Future<void> selectProject(String projectId) async {
    state = state.copyWith(
      activeProjectId: projectId,
      isLoading: false,
      streamingText: '',
      contextArticleIds: {},
    );
    final history = await _datasource.loadHistory(projectId);
    state = state.copyWith(messages: history);
  }

  Future<void> toggleArticleContext(String articleId) async {
    final updatedContextIds = Set<String>.from(state.contextArticleIds);
    if (updatedContextIds.contains(articleId)) {
      updatedContextIds.remove(articleId);
      state = state.copyWith(contextArticleIds: updatedContextIds);
      return;
    }

    // Mark as fetching
    final fetchingIds = Set<String>.from(state.fetchingArticleIds)..add(articleId);
    state = state.copyWith(fetchingArticleIds: fetchingIds);

    try {
      final detailModel = await _articleDatasource.getArticle(articleId);
      final fullArticle = _mapDetailModelToArticle(detailModel);

      final newContextIds = Set<String>.from(state.contextArticleIds)..add(articleId);
      final newFetched = Map<String, Article>.from(state.fetchedArticles)..[articleId] = fullArticle;
      final newFetchingIds = Set<String>.from(state.fetchingArticleIds)..remove(articleId);

      state = state.copyWith(
        contextArticleIds: newContextIds,
        fetchedArticles: newFetched,
        fetchingArticleIds: newFetchingIds,
      );
    } catch (e) {
      final newFetchingIds = Set<String>.from(state.fetchingArticleIds)..remove(articleId);
      state = state.copyWith(fetchingArticleIds: newFetchingIds);
    }
  }

  Article _mapDetailModelToArticle(ArticleDetailModel model) {
    return Article(
      id: model.articleID,
      title: model.title,
      imageUrl: model.pictureURL,
      date: DateTime.tryParse(model.date) ?? DateTime.now(),
      url: model.shareURL,
      sentimentScore: model.metrics?.sentiment,
      subjectivityScore: model.metrics?.subjectivity,
      centricScore: model.coverage?.percentage?.centric,
      progressiveScore: model.coverage?.percentage?.progressive,
      region: model.region,
      sector: model.sector,
      sourceCount: model.articles?.length,
      synopsis: model.description?.synopsis,
      summary: model.description?.summary,
      implications: model.description?.implications,
    );
  }

  void removeArticleContext(String articleId) {
    final updated = Set<String>.from(state.contextArticleIds);
    updated.remove(articleId);
    state = state.copyWith(contextArticleIds: updated);
  }

  void clearContextArticles() {
    state = state.copyWith(contextArticleIds: {});
  }

  Future<void> sendMessage(String text, List<Article> allArticles) async {
    final projectId = state.activeProjectId;
    if (projectId == null || text.trim().isEmpty || state.isLoading) return;

    final userMsgId = _uuid.v4();
    final attachedIds = List<String>.from(state.contextArticleIds);

    final userMsg = ChatMessage(
      id: userMsgId,
      role: 'user',
      content: text,
      timestamp: DateTime.now(),
      contextArticleIds: attachedIds,
    );

    // Save user message to history
    final updatedMessages = [...state.messages, userMsg];
    state = state.copyWith(
      messages: updatedMessages,
      isLoading: true,
      streamingText: '',
    );
    await _datasource.saveHistory(projectId, updatedMessages);

    // Format LLM messages context
    final chatMessages = <Map<String, String>>[];

    // 1. Build the system prompt if we have context articles
    final attachedArticles = attachedIds
        .map((id) => state.fetchedArticles[id])
        .whereType<Article>()
        .toList();
    
    String systemPrompt = 'You are an intelligent media monitor assistant in the Newsletter Portal. Assist the user with their queries about media monitoring, report generation, and news analysis.';
    chatMessages.add({'role': 'system', 'content': systemPrompt});

    // 2. Add history (limit to last 10 messages for context window budget)
    final historyCutoff = state.messages.length > 10 ? state.messages.length - 10 : 0;
    for (int i = historyCutoff; i < state.messages.length; i++) {
      final msg = state.messages[i];
      String content = msg.content;
      
      // If this is the latest user message and we have attached articles, append them to the prompt
      if (i == state.messages.length - 1 && msg.role == 'user' && attachedArticles.isNotEmpty) {
        content += '\n\nContext Articles:\n';
        for (final art in attachedArticles) {
          content += '---\n'
              'Title: ${art.title}\n'
              'Date: ${art.date.toIso8601String().split('T')[0]}\n'
              'URL: ${art.url ?? "N/A"}\n'
              'Region: ${art.region ?? "Global"}\n'
              'Sector: ${art.sector ?? "General"}\n'
              'Source Count: ${art.sourceCount ?? "N/A"}\n'
              'Sentiment: ${art.sentimentScore?.toStringAsFixed(2) ?? "N/A"}\n'
              'Subjectivity: ${art.subjectivityScore?.toStringAsFixed(2) ?? "N/A"}\n'
              'Centricity: ${art.centricScore?.toStringAsFixed(2) ?? "N/A"}\n'
              'Progressivity: ${art.progressiveScore?.toStringAsFixed(2) ?? "N/A"}\n'
              'Synopsis: ${art.synopsis ?? "N/A"}\n'
              'Summary: ${art.summary ?? "N/A"}\n'
              'Implications: ${art.implications ?? "N/A"}\n';
        }
        content += '---';
      }
      
      chatMessages.add({'role': msg.role, 'content': content});
    }

    // Clear context article selections after consuming them in the prompt
    state = state.copyWith(contextArticleIds: {});

    // 3. Call streaming API
    try {
      final stream = _llmService.chatStream(chatMessages);
      final buffer = StringBuffer();
      DateTime lastFlush = DateTime.now();
      const flushInterval = Duration(milliseconds: 50);

      await for (final chunk in stream) {
        if (!mounted || state.activeProjectId != projectId) return;
        buffer.write(chunk);

        // Throttle UI updates: only flush to state every ~30ms to avoid
        // scheduling more frames than the display can handle (fixes
        // "Reported frame time is older than the last one" errors).
        final now = DateTime.now();
        if (now.difference(lastFlush) >= flushInterval) {
          state = state.copyWith(
            streamingText: state.streamingText + buffer.toString(),
          );
          buffer.clear();
          lastFlush = now;
        }
      }

      // Flush any remaining buffered text
      if (buffer.isNotEmpty) {
        state = state.copyWith(
          streamingText: state.streamingText + buffer.toString(),
        );
      }

      // Save assistant message to history
      final assistantMsg = ChatMessage(
        id: _uuid.v4(),
        role: 'assistant',
        content: state.streamingText,
        timestamp: DateTime.now(),
        contextArticleIds: attachedIds,
      );

      final finalMessages = [...state.messages, assistantMsg];
      state = state.copyWith(
        messages: finalMessages,
        isLoading: false,
        streamingText: '',
      );
      await _datasource.saveHistory(projectId, finalMessages);
    } catch (e) {
      if (!mounted || state.activeProjectId != projectId) return;
      
      final errorMsg = ChatMessage(
        id: _uuid.v4(),
        role: 'assistant',
        content: 'Error generating response: ${e.toString()}',
        timestamp: DateTime.now(),
      );

      final finalMessages = [...state.messages, errorMsg];
      state = state.copyWith(
        messages: finalMessages,
        isLoading: false,
        streamingText: '',
      );
      await _datasource.saveHistory(projectId, finalMessages);
    }
  }

  Future<void> clearHistory() async {
    final projectId = state.activeProjectId;
    if (projectId == null) return;
    state = state.copyWith(messages: [], streamingText: '', isLoading: false);
    await _datasource.deleteHistory(projectId);
  }
}

final chatLocalDatasourceProvider = Provider<ChatLocalDatasource>((ref) {
  return ChatLocalDatasource();
});

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final datasource = ref.watch(chatLocalDatasourceProvider);
  final llmService = ref.watch(localLlmServiceProvider);
  final articleDatasource = ref.watch(articleRemoteDatasourceProvider);
  return ChatNotifier(datasource, llmService, articleDatasource);
});
