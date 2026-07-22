# Newsletter Portal Typography Standards

This document outlines the consolidated typography design system for the **Newsletter Portal** application.

---

## 1. Core Principles

1. **Strict 2-Font Policy**:
   - **Primary UI & Document**: `Inter` (`GoogleFonts.inter()`) - All interface elements, navigation, buttons, forms, report previews, and dialogs.
   - **Terminal & Data Grid**: `JetBrains Mono` (`GoogleFonts.jetBrainsMono()`) - All terminal feed rows, ticker metrics, column headers, log lines, and data tags.
2. **Strict 4-Size Tier Scale**: All font sizes across the application are restricted to exactly four values: **24px**, **16px**, **13px**, and **11px**.
3. **No Inline Size Overrides**: Defining custom `fontSize: ...` values inside widget trees is strictly prohibited. All widgets must consume tokens from `AppTypography` (`lib/core/theme/app_typography.dart`) or `Theme.of(context).textTheme`.

---

## 2. The 4-Tier Type Scale Matrix

| Tier | Size | Primary UI (Inter) | Terminal / Code (JetBrains Mono) | Key Use Cases |
| :--- | :--- | :--- | :--- | :--- |
| **Tier 1: Hero / Headline** | **24px** | `displayLarge`, `headlineLarge`, `serifTitle` | `monoLarge` (Hero Metrics) | Main view headers, hero stats, report cover titles |
| **Tier 2: Title / Subhead** | **16px** | `titleLarge`, `titleMedium`, `headlineMedium`, `serifHeading` | `monoLarge` | Card headers, section titles, modal titles, primary buttons |
| **Tier 3: Body / Standard** | **13px** | `bodyMedium`, `labelLarge`, `titleSmall`, `serifBody` | `monoMedium`, `monoStandard` | Standard body text, list items, text field inputs, terminal output |
| **Tier 4: Small / Micro** | **11px** | `bodySmall`, `labelMedium`, `labelSmall`, `serifCaption` | `monoSmall`, `monoExtraSmall`, `monoTiny` | Column headers (`TIME`, `SECTOR`), metadata, status pills, tags |

---

## 3. Code Usage Reference

### Standard UI Components (Inter)
```dart
import 'package:newsletter_portal/core/theme/app_typography.dart';

// Page Title (24px)
Text('Report Configuration', style: AppTypography.headlineLarge);

// Section Title (16px)
Text('Sections', style: AppTypography.titleMedium);

// Standard Input / Body Text (13px)
Text('Username', style: AppTypography.bodyMedium);

// Caption / Secondary Info (11px)
Text('Password must be at least 8 characters', style: AppTypography.bodySmall);
```

### Terminal Components (JetBrains Mono)
```dart
import 'package:newsletter_portal/core/theme/app_typography.dart';

// Brand Heading (13px)
Text('NEWSLETTER', style: AppTypography.monoMedium);

// Table Column Header (11px)
Text('SECTOR', style: AppTypography.monoTiny);

// Log Row Timestamp (11px)
Text('12:45:00', style: AppTypography.monoExtraSmall);
```

---

## 4. Compliance Checklist

- [x] Font families strictly limited to `Inter` and `JetBrains Mono`.
- [x] All font sizes consolidated into the 4-tier scale (`24px`, `16px`, `13px`, `11px`).
- [x] All serif (`Newsreader`) font dependencies removed.
- [x] `flutter analyze` passes cleanly with 0 errors/warnings.
