import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:newsletter_portal/core/theme/app_theme.dart';
import 'package:newsletter_portal/core/theme/app_typography.dart';
import 'package:newsletter_portal/core/theme/app_spacing.dart';
import 'package:newsletter_portal/core/constants/api_constants.dart';
import 'package:newsletter_portal/presentation/providers/terminal_provider.dart';
import 'package:newsletter_portal/presentation/providers/auth_provider.dart';
import 'package:newsletter_portal/presentation/providers/theme_provider.dart';
import 'package:newsletter_portal/presentation/widgets/app_icon_button.dart';
import 'package:newsletter_portal/presentation/widgets/brand_logo.dart';
import 'package:newsletter_portal/core/network/local_llm_service.dart';

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

  /// Trigger icon: sun for light (or system→light), moon for dark (or system→dark).
  IconData _resolvedThemeIcon(BuildContext context, ThemeMode mode) {
    final isDark = switch (mode) {
      ThemeMode.light => false,
      ThemeMode.dark => true,
      ThemeMode.system => MediaQuery.platformBrightnessOf(context) == Brightness.dark,
    };
    return isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTerminal = activeRoute == '/terminal';
    final isReport = activeRoute == '/report';
    final isChat = activeRoute == '/chat';
    final colors = AppColors.of(context);
    final themeMode = ref.watch(themeModeProvider);

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(bottom: BorderSide(color: colors.borderLight, width: 1)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Side margins like modern web headers (scales with viewport).
          final horizontalMargin = (constraints.maxWidth * 0.06).clamp(40.0, 80.0);
          final contentWidth = constraints.maxWidth - (horizontalMargin * 2);
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: contentWidth),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const BrandLogo(size: 28),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Newsletter',
                            style: AppTypography.panelTitle.copyWith(
                              color: colors.textPrimary,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      _buildNavTab(
                        context: context,
                        colors: colors,
                        label: 'Terminal',
                        route: '/terminal',
                        isActive: isTerminal,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _buildNavTab(
                        context: context,
                        colors: colors,
                        label: 'Report',
                        route: '/report',
                        isActive: isReport,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      _buildNavTab(
                        context: context,
                        colors: colors,
                        label: 'Chat',
                        route: '/chat',
                        isActive: isChat,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isTerminal) ...[
                        Consumer(
                          builder: (context, ref, _) {
                            final state = ref.watch(terminalFeedProvider);
                            return _buildSortToggles(context, ref, state, colors);
                          },
                        ),
                        const SizedBox(width: AppSpacing.md),
                      ],
                      SizedBox(
                        width: 180,
                        height: 32,
                        child: TextField(
                          enableIMEPersonalizedLearning: false,
                          spellCheckConfiguration: const SpellCheckConfiguration.disabled(),
                          style: AppTypography.labelMedium.copyWith(color: colors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Search',
                            hintStyle: AppTypography.labelMedium.copyWith(color: colors.textTertiary),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                            filled: true,
                            fillColor: colors.surfaceVariant,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              borderSide: BorderSide(color: colors.accent, width: 1.5),
                            ),
                            prefixIcon: Icon(Icons.search, color: colors.icon, size: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Consumer(
                        builder: (context, ref, _) {
                          final status = ref.watch(llmServerStatusProvider);
                          final error = ref.watch(llmServerErrorProvider);
                          
                          final (dotColor, text, isStarting) = switch (status) {
                            LlmServerStatus.online => (Colors.green, 'LLM Online', false),
                            LlmServerStatus.starting => (Colors.orange, 'LLM Starting', true),
                            LlmServerStatus.offline => (Colors.grey, 'LLM Offline', false),
                            LlmServerStatus.error => (AppColors.of(context).textTertiary, 'LLM Error', false),
                          };
                          
                          return Tooltip(
                            message: error ?? text,
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  // Clicking manual trigger will restart the server
                                  ref.read(localLlmServiceProvider).startServer();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: colors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
                                    border: Border.all(color: colors.borderLight, width: 0.5),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isStarting)
                                        const Padding(
                                          padding: EdgeInsets.only(right: 6),
                                          child: SizedBox(
                                            width: 8,
                                            height: 8,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 1.5,
                                              color: Colors.orange,
                                            ),
                                          ),
                                        )
                                      else
                                        Container(
                                          width: 6,
                                          height: 6,
                                          margin: const EdgeInsets.only(right: 6),
                                          decoration: BoxDecoration(
                                            color: dotColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      Text(
                                        text,
                                        style: AppTypography.monoTiny.copyWith(
                                          color: colors.textSecondary,
                                          fontSize: 9,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      AppIconButton(
                        icon: Icons.view_sidebar_outlined,
                        flipX: true,
                        active: isLeftSidebarOpen,
                        onPressed: onToggleLeftSidebar,
                        tooltip: isLeftSidebarOpen ? 'Close left sidebar' : 'Open left sidebar',
                      ),
                      AppIconButton(
                        icon: Icons.view_sidebar_outlined,
                        active: isRightSidebarOpen,
                        onPressed: onToggleRightSidebar,
                        tooltip: isRightSidebarOpen ? 'Close right sidebar' : 'Open right sidebar',
                      ),
                      AppIconButton(
                        icon: Icons.refresh,
                        onPressed: onRefresh ?? () {},
                        tooltip: 'Refresh',
                      ),
                      _ThemeModeMenu(
                        mode: themeMode,
                        icon: _resolvedThemeIcon(context, themeMode),
                        onSelected: (mode) =>
                            ref.read(themeModeProvider.notifier).setMode(mode),
                      ),
                      _ProfileMenu(
                        username: switch (ref.watch(authStateProvider)) {
                          AuthAuthenticated(:final user) => user.username,
                          _ => null,
                        },
                        onLogout: () => ref.read(authStateProvider.notifier).logout(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavTab({
    required BuildContext context,
    required AppColors colors,
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
              color: isActive ? colors.textPrimary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelLarge.copyWith(
            color: isActive ? colors.textPrimary : colors.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSortToggles(BuildContext context, WidgetRef ref, TerminalState state, AppColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSortBtn(ref, 'Latest', FeedSortBy.latest, state, colors),
          _buildSortBtn(ref, 'Popular', FeedSortBy.popular, state, colors),
          _buildSortBtn(ref, 'Relevant', FeedSortBy.relevant, state, colors),
        ],
      ),
    );
  }

  Widget _buildSortBtn(WidgetRef ref, String label, FeedSortBy value, TerminalState state, AppColors colors) {
    final isActive = state.sortBy == value;
    return GestureDetector(
      onTap: () => ref.read(terminalFeedProvider.notifier).changeSortBy(value),
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? colors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isActive ? colors.textPrimary : colors.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _ProfileMenu extends StatefulWidget {
  final String? username;
  final VoidCallback onLogout;

  const _ProfileMenu({
    required this.username,
    required this.onLogout,
  });

  @override
  State<_ProfileMenu> createState() => _ProfileMenuState();
}

class _ProfileMenuState extends State<_ProfileMenu> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final triggerColor = _hovered ? colors.iconHover : colors.icon;

    return PopupMenuButton<String>(
      tooltip: 'Profile',
      offset: const Offset(0, 36),
      color: colors.surface,
      constraints: const BoxConstraints(minWidth: 176),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      onSelected: (value) {
        if (value == 'logout') widget.onLogout();
      },
      itemBuilder: (context) => [
        if (widget.username != null)
          PopupMenuItem<String>(
            enabled: false,
            height: 40,
            child: Text(
              widget.username!,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelLarge.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        if (widget.username != null) const PopupMenuDivider(height: 8),
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 16, color: colors.icon),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Log out',
                style: AppTypography.labelLarge.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(Icons.person_outline, size: 18, color: triggerColor),
        ),
      ),
    );
  }
}

class _ThemeModeMenu extends StatefulWidget {
  final ThemeMode mode;
  final IconData icon;
  final ValueChanged<ThemeMode> onSelected;

  const _ThemeModeMenu({
    required this.mode,
    required this.icon,
    required this.onSelected,
  });

  @override
  State<_ThemeModeMenu> createState() => _ThemeModeMenuState();
}

class _ThemeModeMenuState extends State<_ThemeModeMenu> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final triggerColor = _hovered ? colors.iconHover : colors.icon;

    return PopupMenuButton<ThemeMode>(
      tooltip: 'Theme',
      initialValue: widget.mode,
      offset: const Offset(0, 36),
      color: colors.surface,
      constraints: const BoxConstraints(minWidth: 176),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      onSelected: widget.onSelected,
      itemBuilder: (context) => [
        _item(
          context,
          value: ThemeMode.light,
          label: 'Light',
          leading: Icons.light_mode_outlined,
        ),
        _item(
          context,
          value: ThemeMode.dark,
          label: 'Dark',
          leading: Icons.dark_mode_outlined,
        ),
        _item(
          context,
          value: ThemeMode.system,
          label: 'System',
          leading: null, // sun + moon pair
        ),
      ],
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(widget.icon, size: 18, color: triggerColor),
        ),
      ),
    );
  }

  PopupMenuItem<ThemeMode> _item(
    BuildContext context, {
    required ThemeMode value,
    required String label,
    required IconData? leading,
  }) {
    final colors = AppColors.of(context);
    final selected = widget.mode == value;
    return PopupMenuItem<ThemeMode>(
      value: value,
      child: SizedBox(
        width: 152,
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: leading != null
                  ? Icon(leading, size: 16, color: colors.icon)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.light_mode_outlined, size: 12, color: colors.icon),
                        Icon(Icons.dark_mode_outlined, size: 12, color: colors.icon),
                      ],
                    ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelLarge.copyWith(
                  color: colors.textPrimary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 4),
              Icon(Icons.check, size: 14, color: colors.iconHover),
            ],
          ],
        ),
      ),
    );
  }
}
