# Newsletter Portal Typography Standards

This document outlines the consolidated typography design system for the **Newsletter Portal** application.

---

## 1. Core Principles

1. **Strict 2-Font Family Policy**:
   - **Primary Headers & Navigation**: `Open Sans` (`GoogleFonts.openSans()`) - All display headings, page titles, panel titles, and section headers.
   - **Body, Inputs & Terminal UI**: `IBM Plex Sans` (`GoogleFonts.ibmPlexSans()`) - All interface body text, list items, labels, buttons, data grids, and terminal feeds.
2. **Semantic Header Hierarchy**: Standardized size scale for headings (28px display, 24px headline, 20px subheadline, 18px page title, 16px panel title, 14px section title, 12px subsection title).
3. **Structured Body Tier Scale**: Body & UI font sizes are restricted to **16px** (large), **13px** (medium/standard), and **11px** (small/micro).
4. **No Inline Size Overrides**: Defining custom `fontSize: ...` values inside widget trees is strictly prohibited. All widgets must consume tokens from `AppTypography` (`lib/core/theme/app_typography.dart`) or `Theme.of(context).textTheme`.

---

## 2. Typography Scale Matrix & Semantic Hierarchy

| Category | Token / Alias | Font Family | Size | Weight | Key Use Cases |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Hero / Display** | `displayLarge` | Open Sans | **28px** | Bold (w700) | Hero titles, report cover titles |
| **Headline Large** | `headlineLarge` | Open Sans | **24px** | Bold (w700) | Main view titles, major section headers |
| **Headline Medium** | `headlineMedium` | Open Sans | **20px** | SemiBold (w600) | Secondary view titles, modal headers |
| **Page Title** | `pageTitle` / `titleLarge` | Open Sans | **18px** | SemiBold (w600) | Page titles, step titles, dialog headers |
| **Panel Title** | `panelTitle` / `titleMedium` | Open Sans | **16px** | SemiBold (w600) | Sidebar headers, panel cards, modal subheaders |
| **Section Title** | `sectionTitle` / `titleSmall` | Open Sans | **14px** | SemiBold (w600) | Group headers (Sectors, Regions, Tags) |
| **Subsection Title**| `subsectionTitle` | Open Sans | **12px** | SemiBold (w600) | Nested headers (Hard/Soft Sectors) |
| **Body Large** | `bodyLarge` | IBM Plex Sans | **16px** | Regular (w400) | Featured body text, article intro text |
| **Body / Label Standard** | `bodyMedium` / `labelLarge` / `monoMedium` | IBM Plex Sans | **13px** | Regular/Medium | Standard UI body, form inputs, list items, terminal output |
| **Body / Label Small** | `bodySmall` / `labelMedium` / `monoSmall` | IBM Plex Sans | **11px** | Regular/Medium | Table headers, metadata, timestamps, tags, status pills |

---

## 3. Code Usage Reference

### Headers & Section Titles (Open Sans)
```dart
import 'package:newsletter_portal/core/theme/app_typography.dart';

// Page Title (18px)
Text('Report Configuration', style: AppTypography.pageTitle);

// Panel Header (16px)
Text('Section Settings', style: AppTypography.panelTitle);

// Group Header (14px)
Text('Sectors', style: AppTypography.sectionTitle);

// Subsection Header (12px)
Text('Hard Sectors', style: AppTypography.subsectionTitle);
```

### Body & Terminal UI Components (IBM Plex Sans)
```dart
import 'package0:newsletter_portal/core/theme/app_typography.dart';

// Standard Body Text (13px)
Text('Username', style: AppTypography.bodyMedium);

// Caption / Secondary Info (11px)
Text('Password must be at least 8 characters', style: AppTypography.bodySmall);

// Log Row Timestamp / Data Tag (11px)
Text('12:45:00', style: AppTypography.monoExtraSmall);
```

---

## 4. Primary Brand Color Palette

The portal uses a serious, professional dark teal tone for all primary interactive accents, brand elements, and focus states.

| Token | Hex / Value | Description |
| :--- | :--- | :--- |
| `AppColors.accent` | `#3D776C` (`0xFF3D776C`) | Primary brand accent color (buttons, active sliders, selected chips, focus borders). |
| `AppColors.accentDim` | `#2E5B53` (`0xFF2E5B53`) | Secondary/hover accent shade. |
| `AppColors.accentSoft` | `#EAF1F0` (Light) / `#182F2B` (Dark) | Subtle background tint for selected items and active panels. |

---

## 5. Compliance Checklist

- [x] Font families strictly limited to `Open Sans` (Headers) and `IBM Plex Sans` (Body & UI).
- [x] Header hierarchy standardized from `displayLarge` (28px) down to `subsectionTitle` (12px).
- [x] Body and UI scale standardized across 16px, 13px, and 11px tiers.
- [x] Primary brand accent color updated to serious dark teal `#3D776C`.
- [x] `flutter analyze` passes cleanly with 0 errors/warnings.


