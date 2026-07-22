# Newsletter Portal — macOS Developer Handover & Architecture Guide

Welcome to the **Newsletter Portal** project! This document contains complete instructions for cloning, setting up, running, debugging, and maintaining the project on macOS. It is designed to be fully readable by both human developers and LLM coding assistants.

---

## 1. Executive Summary & Project Overview

**Newsletter Portal** is an intelligence newsletter & report generation web/desktop application built with **Flutter** (Dart). It allows users to build customizable report presets, configure section filters (tags, item bounds, sentiment thresholds), select candidate articles fetched from the **ZoneNews API**, and render continuous, high-contrast **Plain Text Document Reports** ready for export and copy-pasting.

### Core Architecture & Tech Stack
- **Framework**: Flutter Web / Desktop (Dart SDK >= 3.0)
- **State Management**: Riverpod (`flutter_riverpod` with `StateNotifierProvider`)
- **Networking**: `dio` (configured with base URL `https://api.zonenews.io/dev/`)
- **Design System**: Glassmorphism aesthetic with custom dark mode design system (`AppTheme`, `AppColors`, `AppTypography`, `AppSpacing`).
- **Architecture Pattern**: Clean Architecture (Separation of `Presentation`, `Domain`, and `Data` layers).

---

## 2. 3-Step Report Workflow Architecture

The report creation portal is structured into a streamlined 3-step workflow managed by `ReportPage` (`app/lib/presentation/pages/report/report_page.dart`) and `reportStateProvider`:

1. **Step 1: Report Configuration (`ReportCustomizationView`)**:
   - Inline Title Input inside document header chips.
   - **Template Editor**: Structured sequence builder for Tier 1 (Document Header), Tier 2 (Section Headers), and Tier 3 (Article Format items). Uses fixed elements (`[DOCUMENT_TITLE]`, `[DATE]`, `[LANGUAGE]`, `[SUMMARY_MODE]`, `[SECTION_NUMBER]`, `[SECTION_TITLE]`, `[SECTION_TAGS]`, `[ARTICLE_TITLE]`, `[SRC_COUNT]`, `[REGION]`, `[SECTOR]`, `[SENTIMENT]`, `[SUBJECTIVITY]`, `[SYNOPSIS]`) and explicit `⏎ LINE BREAK` blocks.
   - **Section Cards**: Configurable section title, tags, cutoff limits, min/max items, with explicit `SAVE SECTION` and `RESET SECTION` buttons.
   - Primary action button: **`Select Articles →`**.

2. **Step 2: Article Selection (`ArticleSelectionView`)**:
   - Grouped section panels displaying candidate articles matching configured section tags.
   - **`ArticleCard`**: Displays sentiment dot, source count, date, title, tags, and full `synopsis` text.
   - Checkbox selection allowing users to select/deselect specific items per section.
   - Primary action button: **`Preview Report →`**.

3. **Step 3: Plain Text Report Preview (`ReportPreviewView`)**:
   - Renders compiled 3-tier report into a unified, continuous **Plain Text Paper Document Canvas** (no UI cards).
   - Top action bar featuring **`COPY PLAIN TEXT`** and Font Toggle (Monospace vs Proportional font).

4. **Live Section Preview & Preset Sidebar**:
   - **Left Sidebar**: Preset manager allowing users to load, save, create, duplicate, and delete presets (`sidebar_preset_list.dart`).
   - **Right Sidebar**: Live Section-by-Section preview panel (`_buildRightPanel`) displaying matched article count badges and live interpolated item previews. Open by default on Config page and togglable via top bar across all steps.

---

## 3. Step-by-Step macOS Setup & Running Guide

Follow these steps to set up and run the codebase on macOS:

### Prerequisites
Ensure the following tools are installed on your Mac:
1. **macOS**: Sonoma (14.x) or Sequoia (15.x) recommended.
2. **Flutter SDK**: `>= 3.19.0` (Verify via `flutter --version`).
3. **Xcode** (Optional for macOS desktop build): Install via Mac App Store or Xcode Command Line Tools (`xcode-select --install`).
4. **CocoaPods** (Optional for desktop plugins): `sudo gem install cocoapods` or `brew install cocoapods`.
5. **Google Chrome** (Recommended for web testing): `brew install --cask google-chrome`.

### Step 1: Initial Folder Retrieval & Cloning
Open Terminal (`Cmd + Space` -> `Terminal`) and execute:
```bash
# Clone the repository from GitHub
git clone https://github.com/Shun-Github1/newsletter-portal.git

# Navigate into the project directory
cd newsletter-portal
```

### Step 2: Install Flutter Dependencies
Navigate to the Flutter application subdirectory (`app`) and retrieve dependencies:
```bash
cd app
flutter pub get
```

### Step 3: Run the Application Locally
To launch the application on Chrome (Web):
```bash
flutter run -d chrome
```

To launch as a native macOS Desktop app (if macOS desktop support is enabled in Flutter):
```bash
flutter config --enable-macos-desktop
flutter run -d macos
```

---

## 4. Reading Logs & Debugging Guide

### A. Terminal / Console Logs
When running via `flutter run -d chrome`:
- Application console messages and Dio HTTP requests are logged directly to your terminal.
- To enable verbose output (including full Dart compiler logs and HTTP headers):
  ```bash
  flutter run -d chrome -v
  ```

### B. Chrome Developer Tools Logs
1. Open Chrome DevTools (`Cmd + Option + I` or Right-Click -> Inspect -> Console).
2. Network traffic (Dio requests to `https://api.zonenews.io/dev/`) can be viewed under the **Network** tab.
3. Errors or unhandled assertions will appear in red in the **Console** tab.

### C. Antigravity / IDE Conversation Logs
If developing using Gemini Antigravity IDE or Cursor:
- System transcripts and task execution logs are stored locally under:
  `<user_home>/.gemini/antigravity-ide/brain/<conversation-id>/.system_generated/logs/transcript.jsonl`
- You can inspect recent tool executions via grep:
  ```bash
  grep "flutter analyze" ~/.gemini/antigravity-ide/brain/*/.system_generated/logs/transcript.jsonl
  ```

---

## 5. Repository Documentation & References Index

| Document Path | Description | Key Reference Details |
|---|---|---|
| **[docs/api_documentation.md](file:///c:/Users/ShunKwok/OneDrive%20-%20Searcher/Desktop/newsletter-portal/docs/api_documentation.md)** | Full ZoneNews Backend API Specification | Base URL `https://api.zonenews.io/dev/`<br>• `GET /feed` (Home Feed list)<br>• `GET /feed/personal` (Personalized feed)<br>• `GET /article/{id}` (Returns full `description: { synopsis: "...", implications: "..." }`) |
| **[app/lib/presentation/providers/report_provider.dart](file:///c:/Users/ShunKwok/OneDrive%20-%20Searcher/Desktop/newsletter-portal/app/lib/presentation/providers/report_provider.dart)** | Report Workflow State Management | Controls `ReportStep`, candidate article tag filtering, and `GET /article/{id}` synopsis enrichment. |
| **[app/lib/data/models/article_model.dart](file:///c:/Users/ShunKwok/OneDrive%20-%20Searcher/Desktop/newsletter-portal/app/lib/data/models/article_model.dart)** | Backend JSON Parsing Model | Parses `description` string, `synopsis`, `implications`, `summary`, `content`, or `text`. |
| **[app/lib/data/datasources/article_remote_datasource.dart](file:///c:/Users/ShunKwok/OneDrive%20-%20Searcher/Desktop/newsletter-portal/app/lib/data/datasources/article_remote_datasource.dart)** | Article Detail Datasource | Calls `GET /article/$idOrTitle` (uses un-escaped `$idOrTitle` string interpolation). |
| **[app/lib/presentation/pages/report/preview/report_preview_view.dart](file:///c:/Users/ShunKwok/OneDrive%20-%20Searcher/Desktop/newsletter-portal/app/lib/presentation/pages/report/preview/report_preview_view.dart)** | Plain Text Report Document View | Compiles 3-tier rules into a continuous plain-text paper canvas with font toggle & copy action. |

---

## 6. Maintenance & Development Commands Checklist

```bash
# 1. Run Flutter static analysis (Ensure 0 errors before committing)
cd app
flutter analyze

# 2. Format Dart code according to official guidelines
flutter format lib/

# 3. Clean build cache
flutter clean
flutter pub get
```
