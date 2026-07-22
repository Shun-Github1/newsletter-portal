import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:newsletter_portal/core/theme/app_theme.dart';
import 'package:newsletter_portal/core/theme/app_typography.dart';
import 'package:newsletter_portal/core/theme/app_spacing.dart';
import 'package:newsletter_portal/core/constants/api_constants.dart';
import 'package:newsletter_portal/presentation/providers/terminal_provider.dart';
import 'package:newsletter_portal/presentation/providers/auth_provider.dart';

class CompactTopBar extends ConsumerWidget {
  final String activeRoute; // '/terminal' or '/report'
  final bool isLeftSidebarOpen;
  final bool isRightSidebarOpen;
  final VoidCallback onToggleLeftSidebar;
  final VoidCallback onToggleRightSidebar;
  final VoidCallback? onRefresh;

  const CompactTopBar({
    super.key,
    required this.activeRoute,
    required this.isLeftSidebarOpen,
    required this.isRightSidebarOpen,
    required this.onToggleLeftSidebar,
    required this.onToggleRightSidebar,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTerminal = activeRoute == '/terminal';

    return Container(
      height: 42,
      decoration: const BoxDecoration(
        color: Color(0xFF0A0A0A),
        border: Border(bottom: BorderSide(color: Color(0xFF1A1A1A), width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final contentWidth = constraints.maxWidth;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: contentWidth),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Far-Left Aligned Group
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'NEWSLETTER',
                        style: AppTypography.monoMedium.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      _buildNavTab(
                        context: context,
                        label: 'Terminal',
                        route: '/terminal',
                        isActive: isTerminal,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _buildNavTab(
                        context: context,
                        label: 'Report',
                        route: '/report',
                        isActive: !isTerminal,
                      ),
                    ],
                  ),

                  // Far-Right Aligned Group
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isTerminal) ...[
                        Consumer(
                          builder: (context, ref, _) {
                            final state = ref.watch(terminalFeedProvider);
                            return _buildSortToggles(ref, state);
                          },
                        ),
                        const SizedBox(width: AppSpacing.md),
                      ],
                      SizedBox(
                        width: 160,
                        height: 26,
                        child: TextField(
                          style: AppTypography.monoExtraSmall.copyWith(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            hintStyle: AppTypography.monoExtraSmall.copyWith(color: AppColors.textSecondary),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                            filled: true,
                            fillColor: const Color(0xFF141414),
                            border: const OutlineInputBorder(borderSide: BorderSide.none),
                            prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary, size: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      IconButton(
                        icon: Transform.flip(
                          flipX: true,
                          child: Icon(
                            Icons.view_sidebar_outlined,
                            color: isLeftSidebarOpen ? AppColors.accent : AppColors.textSecondary,
                            size: 18,
                          ),
                        ),
                        onPressed: onToggleLeftSidebar,
                        tooltip: isLeftSidebarOpen ? 'Close Left Sidebar' : 'Open Left Sidebar',
                        splashRadius: 18,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.view_sidebar_outlined,
                          color: isRightSidebarOpen ? AppColors.accent : AppColors.textSecondary,
                          size: 18,
                        ),
                        onPressed: onToggleRightSidebar,
                        tooltip: isRightSidebarOpen ? 'Close Right Sidebar' : 'Open Right Sidebar',
                        splashRadius: 18,
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: AppColors.textSecondary, size: 18),
                        onPressed: onRefresh ?? () {},
                        tooltip: 'Refresh',
                        splashRadius: 18,
                      ),
                      IconButton(
                        icon: const Icon(Icons.person_outline, color: AppColors.textSecondary, size: 18),
                        onPressed: () => ref.read(authStateProvider.notifier).logout(),
                        tooltip: 'Logout',
                        splashRadius: 18,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavTab({
    required BuildContext context,
    required String label,
    required String route,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () {
        if (!isActive) context.go(route);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? AppColors.accent : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.monoSmall.copyWith(
            color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildSortToggles(WidgetRef ref, TerminalState state) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSortBtn(ref, 'Latest', FeedSortBy.latest, state),
          _buildSortBtn(ref, 'Popular', FeedSortBy.popular, state),
          _buildSortBtn(ref, 'Relevant', FeedSortBy.relevant, state),
        ],
      ),
    );
  }

  Widget _buildSortBtn(WidgetRef ref, String label, FeedSortBy value, TerminalState state) {
    final isActive = state.sortBy == value;
    return GestureDetector(
      onTap: () => ref.read(terminalFeedProvider.notifier).changeSortBy(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accent.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(
          label.toUpperCase(),
          style: AppTypography.monoTiny.copyWith(
            color: isActive ? AppColors.accent : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

