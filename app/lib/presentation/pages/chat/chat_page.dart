import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:newsletter_portal/core/theme/app_theme.dart';
import 'package:newsletter_portal/core/theme/app_typography.dart';
import 'package:newsletter_portal/core/theme/app_spacing.dart';
import 'package:newsletter_portal/domain/entities/article.dart';
import 'package:newsletter_portal/domain/entities/chat_message.dart';
import 'package:newsletter_portal/domain/entities/report_preset.dart';
import 'package:newsletter_portal/presentation/providers/preset_provider.dart';
import 'package:newsletter_portal/presentation/providers/terminal_provider.dart';
import 'package:newsletter_portal/presentation/providers/chat_provider.dart';
import 'package:newsletter_portal/core/network/local_llm_service.dart';
import 'package:newsletter_portal/core/constants/api_constants.dart';

import 'package:newsletter_portal/presentation/widgets/compact_top_bar.dart';
import 'package:newsletter_portal/presentation/widgets/sidebar_resize_handle.dart';
import 'package:newsletter_portal/presentation/widgets/sidebar_preset_list.dart';
import 'package:newsletter_portal/presentation/widgets/app_icon_button.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  bool _isLeftOpen = true;
  bool _isRightOpen = true;
  double _leftWidth = 220.0;
  double _rightWidth = 320.0;

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ensure feed is loaded
      ref.read(terminalFeedProvider.notifier).loadFeed();
      // Auto start local LLM server
      ref.read(localLlmServiceProvider).startServer();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animate = false}) {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      if (animate) {
        _scrollController.animateTo(
          maxScroll,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(maxScroll);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final presetState = ref.watch(presetListProvider);
    final chatState = ref.watch(chatProvider);
    final feedState = ref.watch(terminalFeedProvider);
    final serverStatus = ref.watch(llmServerStatusProvider);
    final serverError = ref.watch(llmServerErrorProvider);

    // Auto-select first project if none is active
    if (chatState.activeProjectId == null && presetState.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && ref.read(chatProvider).activeProjectId == null) {
          ref.read(chatProvider.notifier).selectProject(presetState.first.id);
        }
      });
    }

    ref.listen<ChatState>(chatProvider, (previous, next) {
      bool shouldScroll = false;
      bool animate = false;

      if (previous != null && next.messages.length > previous.messages.length) {
        shouldScroll = true;
        animate = true;
      } else if (next.isLoading && previous?.isLoading == false) {
        shouldScroll = true;
        animate = true;
      } else if (next.streamingText.isNotEmpty) {
        if (_scrollController.hasClients) {
          final pos = _scrollController.position;
          if (pos.maxScrollExtent - pos.pixels <= 150) {
            shouldScroll = true;
          }
        } else {
          shouldScroll = true;
        }
      }

      if (shouldScroll) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom(animate: animate));
      }
    });

    final activePreset = presetState.where((p) => p.id == chatState.activeProjectId).firstOrNull;

    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: Column(
        children: [
          // Navigation Header
          CompactTopBar(
            activeRoute: '/chat',
            isLeftSidebarOpen: _isLeftOpen,
            isRightSidebarOpen: _isRightOpen,
            onToggleLeftSidebar: () => setState(() => _isLeftOpen = !_isLeftOpen),
            onToggleRightSidebar: () => setState(() => _isRightOpen = !_isRightOpen),
            onRefresh: () {
              ref.read(localLlmServiceProvider).startServer();
              ref.read(terminalFeedProvider.notifier).refresh();
            },
          ),

          // Main Workspace
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Left Presets / Chat Threads Sidebar
                if (_isLeftOpen) ...[
                  SizedBox(
                    width: _leftWidth,
                    child: _buildLeftSidebar(context, presetState, chatState),
                  ),
                  SidebarResizeHandle(
                    onDrag: (delta) {
                      setState(() {
                        _leftWidth = (_leftWidth + delta).clamp(150.0, 400.0);
                      });
                    },
                  ),
                ],

                // 2. Central Chat Workspace
                Expanded(
                  child: _buildChatWorkspace(
                    context, 
                    activePreset, 
                    chatState, 
                    feedState.articles,
                    serverStatus,
                    serverError,
                  ),
                ),

                // 3. Right News Feed Context Sidebar
                if (_isRightOpen) ...[
                  SidebarResizeHandle(
                    isRight: true,
                    onDrag: (delta) {
                      setState(() {
                        _rightWidth = (_rightWidth + delta).clamp(220.0, 500.0);
                      });
                    },
                  ),
                  SizedBox(
                    width: _rightWidth,
                    child: _buildRightSidebar(context, feedState.articles, chatState),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftSidebar(
    BuildContext context, 
    List<ReportPreset> presets, 
    ChatState chatState
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.of(context).sidebar,
      ),
      child: SidebarPresetList(
        presets: presets,
        activePresetId: chatState.activeProjectId,
        onSelect: (id) {
          ref.read(chatProvider.notifier).selectProject(id);
        },
        onAdd: () {
          final newPreset = ReportPreset(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: 'New Project',
            sections: [],
            summaryMode: SummaryMode.paragraph,
            language: 'en-UK',
            templateContent: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          ref.read(presetListProvider.notifier).create(newPreset);
          ref.read(chatProvider.notifier).selectProject(newPreset.id);
        },
        onDelete: (id) {
          ref.read(presetListProvider.notifier).delete(id);
          ref.read(chatProvider.notifier).clearHistory();
        },
        onRename: (id, newName) {
          final preset = presets.firstWhere((p) => p.id == id);
          final updated = preset.copyWith(name: newName, updatedAt: DateTime.now());
          ref.read(presetListProvider.notifier).update(updated);
        },
      ),
    );
  }

  Widget _buildChatWorkspace(
    BuildContext context, 
    ReportPreset? activePreset, 
    ChatState chatState,
    List<Article> allArticles,
    LlmServerStatus status,
    String? serverError,
  ) {
    final colors = AppColors.of(context);

    if (activePreset == null) {
      return Container(
        color: colors.background,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_bubble_outline, size: 48, color: colors.textTertiary),
              const SizedBox(height: AppSpacing.md),
              Text(
                'No Active Project',
                style: AppTypography.panelTitle.copyWith(color: colors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Create a project in the left sidebar to start chatting.',
                style: AppTypography.bodySmall.copyWith(color: colors.textTertiary),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: colors.background,
      child: Column(
        children: [
          // Chat Pane Header
          _buildChatHeader(context, activePreset, status, serverError),

          // Message List
          Expanded(
            child: chatState.messages.isEmpty && chatState.streamingText.isEmpty
                ? _buildEmptyState(context, activePreset)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                    itemCount: chatState.messages.length + (chatState.streamingText.isNotEmpty || chatState.isLoading ? 1 : 0),
                    itemBuilder: (context, idx) {
                      if (idx == chatState.messages.length) {
                        // Streaming response bubble
                        return ExcludeSemantics(
                          child: _buildMessageBubble(
                            context,
                            ChatMessage(
                              id: 'streaming',
                              role: 'assistant',
                              content: chatState.streamingText.isEmpty ? 'Thinking...' : chatState.streamingText,
                              timestamp: DateTime.now(),
                            ),
                            allArticles,
                            isStreaming: chatState.streamingText.isEmpty,
                          ),
                        );
                      }
                      return _buildMessageBubble(context, chatState.messages[idx], allArticles);
                    },
                  ),
          ),

          // Selected Context Chips
          if (chatState.contextArticleIds.isNotEmpty) ...[
            _buildContextArticlesBar(context, chatState.contextArticleIds, allArticles),
          ],
          _buildInputBar(context, chatState, allArticles, status),
        ],
      ),
    );
  }

  Widget _buildChatHeader(
    BuildContext context, 
    ReportPreset preset, 
    LlmServerStatus status,
    String? error
  ) {
    final colors = AppColors.of(context);
    
    // Status dot color
    final statusColor = switch (status) {
      LlmServerStatus.online => Colors.green,
      LlmServerStatus.starting => Colors.orange,
      LlmServerStatus.offline => Colors.grey,
      LlmServerStatus.error => AppColors.error,
    };

    final statusText = switch (status) {
      LlmServerStatus.online => 'Local Qwen 2.5 Active',
      LlmServerStatus.starting => 'Launching local model...',
      LlmServerStatus.offline => 'Model offline',
      LlmServerStatus.error => 'Server error',
    };

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(bottom: BorderSide(color: colors.borderLight, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(Icons.chat_outlined, size: 16, color: colors.accent),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  preset.name,
                  style: AppTypography.panelTitle.copyWith(color: colors.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(width: AppSpacing.md),
                // Server health indicator
                Tooltip(
                  message: error ?? statusText,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        statusText,
                        style: AppTypography.monoTiny.copyWith(color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          AppIconButton(
            icon: Icons.delete_sweep_outlined,
            size: 16,
            onPressed: () {
              ref.read(chatProvider.notifier).clearHistory();
            },
            tooltip: 'Clear history',
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ReportPreset preset) {
    final colors = AppColors.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.forum_outlined, size: 36, color: colors.accent),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Local Copilot for ${preset.name}',
              style: AppTypography.titleLarge.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.xs),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Text(
                'Ask questions, summarize findings, or build reports using your custom news feed as context. Add articles on the right to reference them directly in the chat.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(color: colors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(
    BuildContext context, 
    ChatMessage message, 
    List<Article> allArticles,
    {bool isStreaming = false}
  ) {
    final colors = AppColors.of(context);
    final isUser = message.role == 'user';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: colors.surfaceHover,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.auto_awesome, size: 14, color: colors.accent),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isUser 
                    ? colors.accent.withOpacity(0.08) 
                    : colors.surfaceVariant,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: isUser ? const Radius.circular(12) : const Radius.circular(2),
                  bottomRight: isUser ? const Radius.circular(2) : const Radius.circular(12),
                ),
                border: Border.all(
                  color: isUser 
                      ? colors.accent.withOpacity(0.2) 
                      : colors.borderLight, 
                  width: 1
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isStreaming)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2, 
                            color: colors.textSecondary
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Thinking...', 
                          style: AppTypography.monoTiny.copyWith(color: colors.textSecondary)
                        ),
                      ],
                    )
                  else
                    Text(
                      message.content,
                      style: AppTypography.bodyLarge.copyWith(
                        color: colors.textPrimary,
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                  
                  // Attached reference articles list
                  if (message.contextArticleIds.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Divider(color: colors.borderLight, height: 12),
                    Text(
                      'References:',
                      style: AppTypography.monoTiny.copyWith(color: colors.textTertiary, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: message.contextArticleIds.map((id) {
                        final article = allArticles.where((a) => a.id == id).firstOrNull;
                        final title = article?.title ?? 'Unknown Article';
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.background,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: colors.borderLight, width: 0.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.article_outlined, size: 10, color: colors.textSecondary),
                              const SizedBox(width: 4),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 160),
                                child: Text(
                                  title,
                                  style: AppTypography.monoTiny.copyWith(color: colors.textSecondary, fontSize: 9),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: AppSpacing.sm),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: colors.accent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.person, size: 14, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContextArticlesBar(
    BuildContext context, 
    Set<String> articleIds, 
    List<Article> allArticles
  ) {
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        border: Border(top: BorderSide(color: colors.borderLight, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Attached context articles:',
                style: AppTypography.monoTiny.copyWith(color: colors.textSecondary, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () => ref.read(chatProvider.notifier).clearContextArticles(),
                child: Text(
                  'Clear all',
                  style: AppTypography.monoTiny.copyWith(color: colors.accent, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 26,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: articleIds.map((id) {
                final article = allArticles.where((a) => a.id == id).firstOrNull;
                final title = article?.title ?? 'Loading...';
                return Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: colors.accent.withOpacity(0.3), width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.article_outlined, size: 12, color: colors.accent),
                      const SizedBox(width: 4),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 150),
                        child: Text(
                          title,
                          style: AppTypography.labelMedium.copyWith(color: colors.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => ref.read(chatProvider.notifier).removeArticleContext(id),
                        child: Icon(Icons.close, size: 12, color: colors.icon),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(BuildContext context, ChatState chatState, List<Article> allArticles, LlmServerStatus serverStatus) {
    final colors = AppColors.of(context);
    final canSend = !chatState.isLoading && chatState.activeProjectId != null && serverStatus == LlmServerStatus.online;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(top: BorderSide(color: colors.borderLight, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              enabled: canSend,
              enableIMEPersonalizedLearning: false,
              spellCheckConfiguration: const SpellCheckConfiguration.disabled(),
              style: AppTypography.bodyMedium.copyWith(color: colors.textPrimary),
              textInputAction: TextInputAction.send,
              onSubmitted: (val) {
                if (val.trim().isNotEmpty) {
                  ref.read(chatProvider.notifier).sendMessage(val, allArticles);
                  _messageController.clear();
                }
              },
              decoration: InputDecoration(
                hintText: canSend ? 'Ask Qwen 2.5 about this project...' : 'Select a project to start...',
                hintStyle: AppTypography.bodyMedium.copyWith(color: colors.textTertiary),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                filled: true,
                fillColor: colors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  borderSide: BorderSide(color: colors.accent, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            decoration: BoxDecoration(
              color: canSend && _messageController.text.trim().isNotEmpty ? colors.accent : colors.surfaceHover,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.send_rounded, size: 18, color: canSend && _messageController.text.trim().isNotEmpty ? Colors.white : colors.icon),
              onPressed: canSend ? () {
                final txt = _messageController.text.trim();
                if (txt.isNotEmpty) {
                  ref.read(chatProvider.notifier).sendMessage(txt, allArticles);
                  _messageController.clear();
                }
              } : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightSidebar(
    BuildContext context, 
    List<Article> articles, 
    ChatState chatState
  ) {
    final colors = AppColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: colors.sidebar,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Context Library',
                  style: AppTypography.panelTitle.copyWith(color: colors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  'Add feed articles to prompt context',
                  style: AppTypography.bodySmall.copyWith(color: colors.textTertiary),
                ),
              ],
            ),
          ),
          Expanded(
            child: articles.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Text(
                        'No news in feed. Go to Terminal tab to fetch articles.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySmall.copyWith(color: colors.textTertiary),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    itemCount: articles.length,
                    itemBuilder: (context, idx) {
                      final article = articles[idx];
                      final isSelected = chatState.contextArticleIds.contains(article.id);
                      final dateStr = DateFormat('MMM d').format(article.date);

                      return GestureDetector(
                        onTap: () {
                          ref.read(chatProvider.notifier).toggleArticleContext(article.id);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: isSelected ? colors.surfaceHover : colors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: isSelected ? colors.accent : Colors.transparent, 
                              width: 1
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      article.title,
                                      style: AppTypography.labelLarge.copyWith(
                                        color: colors.textPrimary,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  if (chatState.fetchingArticleIds.contains(article.id))
                                    SizedBox(
                                      width: 14, 
                                      height: 14, 
                                      child: CircularProgressIndicator(strokeWidth: 2, color: colors.accent)
                                    )
                                  else if (isSelected)
                                    Icon(Icons.check_circle, size: 14, color: colors.accent)
                                  else
                                    Icon(Icons.add_circle_outline, size: 14, color: colors.icon),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '$dateStr | ${article.region ?? "GLOBAL"} | ${article.sector ?? "GENERAL"}',
                                    style: AppTypography.monoTiny.copyWith(color: colors.textTertiary, fontSize: 9),
                                  ),
                                  if (article.sentimentScore != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: article.sentimentScore! >= 0 
                                            ? Colors.green.withOpacity(0.1) 
                                            : Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(AppRadius.sm),
                                      ),
                                      child: Text(
                                        '${article.sentimentScore! >= 0 ? "+" : ""}${article.sentimentScore!.toStringAsFixed(2)}',
                                        style: AppTypography.monoTiny.copyWith(
                                          color: article.sentimentScore! >= 0 ? Colors.green : Colors.red,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
