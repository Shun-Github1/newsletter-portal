import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:newsletter_portal/core/theme/app_theme.dart';
import 'package:newsletter_portal/core/theme/app_typography.dart';
import 'package:newsletter_portal/core/theme/app_spacing.dart';
import 'package:newsletter_portal/presentation/widgets/compact_top_bar.dart';
import 'package:newsletter_portal/presentation/widgets/sidebar_resize_handle.dart';
import 'package:newsletter_portal/presentation/widgets/terminal_row.dart';
import 'package:newsletter_portal/presentation/widgets/sector_relevance_grid.dart';
import 'package:newsletter_portal/presentation/widgets/region_relevance_grid.dart';
import 'package:newsletter_portal/presentation/widgets/tag_picker.dart';
import 'package:newsletter_portal/presentation/widgets/app_icon_button.dart';
import 'package:newsletter_portal/presentation/providers/terminal_provider.dart';
import 'package:newsletter_portal/presentation/providers/preset_provider.dart';
import 'package:newsletter_portal/presentation/providers/auth_provider.dart';
import 'package:newsletter_portal/core/constants/api_constants.dart';
import 'package:newsletter_portal/domain/entities/report_preset.dart';

class TerminalPage extends ConsumerStatefulWidget {
  const TerminalPage({super.key});

  @override
  ConsumerState<TerminalPage> createState() => _TerminalPageState();
}

class _TerminalPageState extends ConsumerState<TerminalPage> {
  bool _isLeftOpen = true;
  bool _isRightOpen = true;
  double _leftWidth = 180.0;
  double _rightWidth = 300.0;

  final ScrollController _scrollController = ScrollController();

  Map<int, int> _tempSectorWeights = {};
  Map<String, int> _tempRegionWeights = {};
  Set<String> _tempSelectedTags = {};
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(terminalFeedProvider.notifier).loadFeed();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final state = ref.read(terminalFeedProvider);
      if (!state.isLoading && state.hasMore) {
        ref.read(terminalFeedProvider.notifier).loadMore();
      }
    }
  }

  void _syncFilters(TerminalState state) {
    if (!_isInit) {
      _tempSectorWeights = Map.from(state.sectorWeights);
      _tempRegionWeights = Map.from(state.regionWeights);
      _tempSelectedTags = Set.from(state.selectedTags);
      _isInit = true;
    }
  }

  void _showSavePresetDialog(BuildContext context) {
    final controller = TextEditingController(text: 'Custom Preset');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.of(context).surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          title: Text(
            'Save Filter Preset',
            style: AppTypography.pageTitle,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter a name for this preset filter configuration:',
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: controller,
                enableIMEPersonalizedLearning: false,
                spellCheckConfiguration: const SpellCheckConfiguration.disabled(),
                style: AppTypography.bodyMedium.copyWith(color: AppColors.of(context).textPrimary),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.of(context).surfaceVariant,
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.of(context).border), borderRadius: const BorderRadius.all(Radius.circular(AppRadius.md))),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.of(context).textPrimary, width: 1.5), borderRadius: const BorderRadius.all(Radius.circular(AppRadius.md))),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: AppTypography.labelMedium),
            ),
            ElevatedButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  final newPreset = ReportPreset(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    sections: [],
                    summaryMode: SummaryMode.paragraph,
                    language: 'en-UK',
                    templateContent: '',
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  ref.read(presetListProvider.notifier).create(newPreset);
                  // Apply active filters
                  ref.read(terminalFeedProvider.notifier).applyFilters(
                    sectorWeights: _tempSectorWeights,
                    regionWeights: _tempRegionWeights,
                    selectedTags: _tempSelectedTags,
                  );
                }
                Navigator.pop(context);
              },
              child: Text('Save', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600, color: AppColors.onAccent)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(terminalFeedProvider);
    final presets = ref.watch(presetListProvider);
    _syncFilters(state);

    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: Column(
        children: [
          // Unified Compact Top Bar
          CompactTopBar(
            activeRoute: '/terminal',
            isLeftSidebarOpen: _isLeftOpen,
            isRightSidebarOpen: _isRightOpen,
            onToggleLeftSidebar: () => setState(() => _isLeftOpen = !_isLeftOpen),
            onToggleRightSidebar: () => setState(() => _isRightOpen = !_isRightOpen),
            onRefresh: () => ref.read(terminalFeedProvider.notifier).refresh(),
          ),

          // Main Workspace Row
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Presets Sidebar
                if (_isLeftOpen) ...[
                  SizedBox(
                    width: _leftWidth,
                    child: _buildPresetsSidebar(presets),
                  ),
                  SidebarResizeHandle(
                    onDrag: (delta) {
                      setState(() {
                        _leftWidth = (_leftWidth + delta).clamp(140.0, 380.0);
                      });
                    },
                  ),
                ],

                // Central Feed List
                Expanded(
                  child: Column(
                    children: [
                      _buildFeedHeader(),
                      Expanded(
                        child: _buildFeedList(state),
                      ),
                      _buildStatusBar(state),
                    ],
                  ),
                ),

                // Right Filter Panel
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
                    child: _buildFilterPanel(state),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetsSidebar(List<ReportPreset> presets) {
    return Container(
      color: AppColors.of(context).sidebar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Presets',
                  style: AppTypography.panelTitle.copyWith(
                    color: AppColors.of(context).textSecondary,
                  ),
                ),
                AppIconButton(
                  icon: Icons.add,
                  size: 16,
                  onPressed: () => _showSavePresetDialog(context),
                  padding: const EdgeInsets.all(4),
                  tooltip: 'Add preset',
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: presets.length,
              itemBuilder: (context, index) {
                final preset = presets[index];
                return InkWell(
                  onTap: () {
                    // Apply preset filters if available
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.bookmark_outline, size: 14, color: AppColors.of(context).textTertiary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            preset.name,
                            style: AppTypography.bodySmall.copyWith(color: AppColors.of(context).textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
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

  Widget _buildFeedHeader() {
    return Container(
      height: 36,
      color: AppColors.of(context).sidebar,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          SizedBox(width: 52, child: Text('Time', style: AppTypography.labelSmall)),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(width: 80, child: Text('Region', style: AppTypography.labelSmall)),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(width: 100, child: Text('Sector', style: AppTypography.labelSmall)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text('Headline', style: AppTypography.labelSmall)),
          const SizedBox(width: AppSpacing.md),
          SizedBox(width: 36, child: Center(child: Text('Sent', style: AppTypography.labelSmall))),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(width: 36, child: Center(child: Text('Subj', style: AppTypography.labelSmall))),
          const SizedBox(width: AppSpacing.md),
          SizedBox(width: 40, child: Text('Src', style: AppTypography.labelSmall, textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildFeedList(TerminalState state) {
    if (state.articles.isEmpty && state.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.of(context).textSecondary),
      );
    }

    if (state.articles.isEmpty && !state.isLoading) {
      return Center(
        child: Text(
          'No articles match current filters',
          style: AppTypography.bodyMedium,
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: state.articles.length + (state.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.articles.length) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Center(
              child: state.isLoading
                  ? SizedBox(width: 24, height: 36, child: CircularProgressIndicator(color: AppColors.of(context).textSecondary, strokeWidth: 2))
                  : TextButton(
                      onPressed: () => ref.read(terminalFeedProvider.notifier).loadMore(),
                      child: Text('Load more', style: AppTypography.labelMedium.copyWith(color: AppColors.of(context).textSecondary)),
                    ),
            ),
          );
        }

        final article = state.articles[index];
        final isEven = index % 2 == 0;
        return Container(
          color: Colors.transparent,
          child: TerminalRow(article: article, isEven: isEven),
        );
      },
    );
  }

  Widget _buildStatusBar(TerminalState state) {
    // Dynamically compute rolling averages across all currently loaded articles in real time
    double avgSentiment = 0.0;
    double avgSubjectivity = 0.0;

    if (state.articles.isNotEmpty) {
      final sentiments = state.articles.map((a) => a.sentimentScore ?? 0.0).toList();
      avgSentiment = sentiments.reduce((a, b) => a + b) / sentiments.length;

      final subjectivities = state.articles.map((a) => a.subjectivityScore ?? 0.0).toList();
      avgSubjectivity = subjectivities.reduce((a, b) => a + b) / subjectivities.length;
    }

    Color sentColor;
    String sentText;
    if (avgSentiment > 0.15) {
      sentColor = AppColors.sentimentPositive;
      sentText = 'POS (${avgSentiment >= 0 ? '+' : ''}${avgSentiment.toStringAsFixed(2)})';
    } else if (avgSentiment < -0.15) {
      sentColor = AppColors.sentimentNegative;
      sentText = 'NEG (${avgSentiment.toStringAsFixed(2)})';
    } else {
      sentColor = AppColors.sentimentNeutral;
      sentText = 'NEUT (${avgSentiment >= 0 ? '+' : ''}${avgSentiment.toStringAsFixed(2)})';
    }

    Color subjColor;
    String subjText;
    if (avgSubjectivity > 0.15) {
      subjColor = AppColors.sentimentNegative;
      subjText = 'HIGH (${avgSubjectivity >= 0 ? '+' : ''}${avgSubjectivity.toStringAsFixed(2)})';
    } else if (avgSubjectivity < -0.15) {
      subjColor = AppColors.sentimentPositive;
      subjText = 'LOW (${avgSubjectivity >= 0 ? '+' : ''}${avgSubjectivity.toStringAsFixed(2)})';
    } else {
      subjColor = AppColors.sentimentNeutral;
      subjText = 'MOD (${avgSubjectivity >= 0 ? '+' : ''}${avgSubjectivity.toStringAsFixed(2)})';
    }

    return Container(
      height: 28,
      color: AppColors.of(context).sidebar,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Rolling Sentiment Average
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: sentColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Avg sentiment: $sentText',
                  style: AppTypography.labelSmall.copyWith(color: AppColors.of(context).textSecondary),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.lg),

            // Rolling Subjectivity Average
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: subjColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Avg subjectivity: $subjText',
                  style: AppTypography.labelSmall.copyWith(color: AppColors.of(context).textSecondary),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.xl),

            // Item Count
            Text(
              'Showing ${state.articles.length} items',
              style: AppTypography.monoTiny,
            ),
            const SizedBox(width: AppSpacing.xl),

            // Timestamp
            Text(
              'Last refresh: ${DateTime.now().toString().split('.').first}',
              style: AppTypography.monoTiny,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPanel(TerminalState state) {
    int activeFiltersCount = state.sectorWeights.length + state.regionWeights.length + state.selectedTags.length;

    return Container(
      color: AppColors.of(context).sidebar,
      child: Column(
        children: [
          // Filter Panel Header (Title + Active Count + Reset)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Text(
                  'Filters',
                  style: AppTypography.panelTitle.copyWith(
                    color: AppColors.of(context).textSecondary,
                  ),
                ),
                if (activeFiltersCount > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.of(context).surfaceHover,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      '$activeFiltersCount',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.of(context).textPrimary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _tempSectorWeights.clear();
                      _tempRegionWeights.clear();
                      _tempSelectedTags.clear();
                    });
                  },
                  child: Text('Reset', style: AppTypography.labelSmall.copyWith(color: AppColors.of(context).textSecondary)),
                ),
              ],
            ),
          ),

          // Filter Sections Body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                SectorRelevanceGrid(
                  values: _tempSectorWeights,
                  onChanged: (id, weight) => setState(() {
                    _tempSectorWeights[id] = weight;
                  }),
                ),
                const SizedBox(height: AppSpacing.lg),
                RegionRelevanceGrid(
                  values: _tempRegionWeights,
                  onChanged: (region, weight) => setState(() {
                    _tempRegionWeights[region] = weight;
                  }),
                ),
                const SizedBox(height: AppSpacing.lg),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tags',
                      style: AppTypography.sectionTitle.copyWith(
                        color: AppColors.of(context).textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TagPicker(
                      availableTags: ref.watch(allTopicsProvider).maybeWhen(
                        data: (topics) => topics.isNotEmpty ? topics : const [
                          (tag: 'politics', displayName: 'Politics'),
                          (tag: 'business', displayName: 'Business'),
                          (tag: 'tech', displayName: 'Tech'),
                          (tag: 'macro-economics', displayName: 'Macro Economics'),
                          (tag: 'markets', displayName: 'Markets'),
                        ],
                        orElse: () => const [
                          (tag: 'politics', displayName: 'Politics'),
                          (tag: 'business', displayName: 'Business'),
                          (tag: 'tech', displayName: 'Tech'),
                          (tag: 'macro-economics', displayName: 'Macro Economics'),
                          (tag: 'markets', displayName: 'Markets'),
                        ],
                      ),
                      selectedTags: _tempSelectedTags,
                      onChanged: (tags) => setState(() => _tempSelectedTags = tags),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filter Footer with APPLY FILTERS and SAVE AS buttons
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      ref.read(terminalFeedProvider.notifier).applyFilters(
                            sectorWeights: _tempSectorWeights,
                            regionWeights: _tempRegionWeights,
                            selectedTags: _tempSelectedTags,
                          );
                    },
                    child: Text(
                      'Apply filters',
                      style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600, color: AppColors.onAccent),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.of(context).textPrimary,
                    side: BorderSide(color: AppColors.of(context).border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                  ),
                  onPressed: () => _showSavePresetDialog(context),
                  child: Text(
                    'Save as',
                    style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600, color: AppColors.of(context).textPrimary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

