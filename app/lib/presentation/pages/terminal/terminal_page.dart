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
          backgroundColor: const Color(0xFF141414),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Color(0xFF2A2A2A)),
          ),
          title: Text(
            'Save Filter Preset',
            style: AppTypography.monoLarge,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter a name for this preset filter configuration:',
                style: AppTypography.monoSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: controller,
                style: AppTypography.monoStandard,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Color(0xFF0E0E0E),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF2A2A2A))),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.accent)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CANCEL', style: AppTypography.monoSmall.copyWith(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: const Color(0xFF0D0D0D),
              ),
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
              child: Text('SAVE', style: AppTypography.monoSmall.copyWith(fontWeight: FontWeight.bold)),
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
      backgroundColor: const Color(0xFF0D0D0D),
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
      color: const Color(0xFF0A0A0A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PRESETS',
                  style: AppTypography.monoExtraSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                InkWell(
                  onTap: () => _showSavePresetDialog(context),
                  borderRadius: BorderRadius.circular(4),
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.add, size: 14, color: AppColors.accent),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF1A1A1A), height: 1),
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
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0xFF141414))),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bookmark_outline, size: 12, color: AppColors.accent),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            preset.name,
                            style: AppTypography.monoExtraSmall.copyWith(color: AppColors.textPrimary),
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
      height: 24,
      decoration: const BoxDecoration(
        color: Color(0xFF141414),
        border: Border(bottom: BorderSide(color: Color(0xFF2A2A2A))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          SizedBox(width: 70, child: Text('TIME', style: AppTypography.monoTiny)),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(width: 80, child: Text('REGION', style: AppTypography.monoTiny)),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(width: 100, child: Text('SECTOR', style: AppTypography.monoTiny)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text('HEADLINE', style: AppTypography.monoTiny)),
          const SizedBox(width: AppSpacing.md),
          SizedBox(width: 36, child: Center(child: Text('SENT', style: AppTypography.monoTiny))),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(width: 36, child: Center(child: Text('SUBJ', style: AppTypography.monoTiny))),
          const SizedBox(width: AppSpacing.md),
          SizedBox(width: 45, child: Text('SRC', style: AppTypography.monoTiny, textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildFeedList(TerminalState state) {
    if (state.articles.isEmpty && state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }

    if (state.articles.isEmpty && !state.isLoading) {
      return Center(
        child: Text(
          '> No articles match current filters',
          style: AppTypography.monoMedium.copyWith(color: AppColors.textSecondary),
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
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: AppColors.accent, strokeWidth: 2))
                  : TextButton(
                      onPressed: () => ref.read(terminalFeedProvider.notifier).loadMore(),
                      child: Text('LOAD MORE', style: AppTypography.monoSmall.copyWith(color: AppColors.accent)),
                    ),
            ),
          );
        }

        final article = state.articles[index];
        final isEven = index % 2 == 0;
        return Container(
          color: isEven ? Colors.transparent : const Color(0xFF141414).withValues(alpha: 0.5),
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
      sentColor = const Color(0xFF00D4AA); // Green (Positive)
      sentText = 'POS (${avgSentiment >= 0 ? '+' : ''}${avgSentiment.toStringAsFixed(2)})';
    } else if (avgSentiment < -0.15) {
      sentColor = const Color(0xFFFF4757); // Red (Negative)
      sentText = 'NEG (${avgSentiment.toStringAsFixed(2)})';
    } else {
      sentColor = const Color(0xFFF5A623); // Amber (Neutral)
      sentText = 'NEUT (${avgSentiment >= 0 ? '+' : ''}${avgSentiment.toStringAsFixed(2)})';
    }

    Color subjColor;
    String subjText;
    if (avgSubjectivity > 0.15) {
      subjColor = const Color(0xFFFF4757); // Red (High Subjectivity / Opinionated)
      subjText = 'HIGH (${avgSubjectivity >= 0 ? '+' : ''}${avgSubjectivity.toStringAsFixed(2)})';
    } else if (avgSubjectivity < -0.15) {
      subjColor = const Color(0xFF00D4AA); // Green (Low Subjectivity / Factual)
      subjText = 'LOW (${avgSubjectivity >= 0 ? '+' : ''}${avgSubjectivity.toStringAsFixed(2)})';
    } else {
      subjColor = const Color(0xFFF5A623); // Amber (Moderate)
      subjText = 'MOD (${avgSubjectivity >= 0 ? '+' : ''}${avgSubjectivity.toStringAsFixed(2)})';
    }

    return Container(
      height: 20,
      decoration: const BoxDecoration(
        color: Color(0xFF0A0A0A),
        border: Border(top: BorderSide(color: Color(0xFF1A1A1A))),
      ),
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
                  'AVG SENTIMENT: $sentText',
                  style: AppTypography.monoTiny.copyWith(color: AppColors.textPrimary, letterSpacing: 0.5),
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
                  'AVG SUBJECTIVITY: $subjText',
                  style: AppTypography.monoTiny.copyWith(color: AppColors.textPrimary, letterSpacing: 0.5),
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
              'LAST REFRESH: ${DateTime.now().toString().split('.').first}',
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
      color: const Color(0xFF0E0E0E),
      child: Column(
        children: [
          // Filter Panel Header (Title + Active Count + Reset)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Text(
                  'FILTERS',
                  style: AppTypography.monoSmall.copyWith(
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (activeFiltersCount > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.5)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$activeFiltersCount',
                      style: AppTypography.monoTiny.copyWith(color: AppColors.accent, fontWeight: FontWeight.bold),
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
                  child: Text('RESET', style: AppTypography.monoTiny.copyWith(color: AppColors.accent)),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF1A1A1A), height: 1),

          // Filter Sections Body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                _buildFilterSection(
                  'SECTORS',
                  SectorRelevanceGrid(
                    values: _tempSectorWeights,
                    onChanged: (id, weight) => setState(() {
                      _tempSectorWeights[id] = weight;
                    }),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildFilterSection(
                  'REGIONS',
                  RegionRelevanceGrid(
                    values: _tempRegionWeights,
                    onChanged: (region, weight) => setState(() {
                      _tempRegionWeights[region] = weight;
                    }),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildFilterSection(
                  'TAGS',
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
                ),
              ],
            ),
          ),

          // Filter Footer with APPLY FILTERS and SAVE AS buttons
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFF1A1A1A))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: const Color(0xFF0D0D0D),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () {
                      ref.read(terminalFeedProvider.notifier).applyFilters(
                            sectorWeights: _tempSectorWeights,
                            regionWeights: _tempRegionWeights,
                            selectedTags: _tempSelectedTags,
                          );
                    },
                    child: Text(
                      'APPLY FILTERS',
                      style: AppTypography.monoExtraSmall.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: const BorderSide(color: AppColors.accent),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  ),
                  onPressed: () => _showSavePresetDialog(context),
                  child: Text(
                    'SAVE AS',
                    style: AppTypography.monoExtraSmall.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '> $title',
          style: AppTypography.monoExtraSmall,
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }
}

