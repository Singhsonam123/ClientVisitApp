# Project List & Selection Fixes

## Issues Fixed

### 1. Duplicate Projects Display
**Problem:** Projects list was showing duplicate entries, particularly "Acme Corp Visit Oct 2026" appearing 14+ times.

**Root Cause:** API was returning duplicate projects with empty IDs. The UI was displaying all returned projects without deduplication.

**Solution:** Added `_deduplicateProjects()` method that:
- Uses a `Set<String>` to track seen projects
- Deduplicates based on project ID (or name if ID is empty)
- Returns only unique projects
- Applied in `_loadProjects()` before setting state

### 2. LateInitializationError on Project Selection
**Problem:** Selecting a project from the bottom sheet threw:
```
LateInitializationError: Field '_pages@81333486' has already been initialized.
```

**Root Cause:** `_pages` was declared as `late final List<Widget>` and was being re-initialized multiple times:
- Once in `initState()` via `_initializePages()`
- Again in `_loadProjects()` after loading projects
- Again in `_showProjectSelector()` when selecting a project

Late variables can only be initialized once, causing the error.

**Solution:** Converted `_pages` from a `late final` field to a method:
- Changed `late final List<Widget> _pages` to method `List<Widget> _buildPages()`
- Removed `_initializePages()` method entirely
- Updated `build()` to call `_buildPages()` directly in `IndexedStack`
- Removed all `_initializePages()` calls from `_loadProjects()` and `_showProjectSelector()`

This allows pages to be rebuilt on every frame with the current `_selectedProject` value.

### 3. Default Project Selection
**Problem:** No project was selected by default on app load.

**Solution:** Modified `_loadProjects()` to:
- Check if `_selectedProject` is null
- If null and projects list is not empty, set first project as default
- This ensures the first project is always selected when projects load

## Code Changes

### File: `lib/features/home/presentation/pages/home_page.dart`

**Removed:**
- `late final List<Widget> _pages;` field declaration
- `void _initializePages()` method
- `_initializePages()` call from `initState()`
- `_initializePages()` call from `_loadProjects()`
- `_initializePages()` call from `_showProjectSelector()`
- Unused import: `gallery_page.dart`

**Added:**
- `List<Widget> _buildPages()` method - builds pages on demand with current state
- `List<ProjectModel> _deduplicateProjects()` method - removes duplicate projects
- Default project selection logic in `_loadProjects()`

**Modified:**
- `build()` method: Changed `children: _pages` to `children: _buildPages()`
- `_loadProjects()`: Added deduplication and default selection logic
- `_showProjectSelector()`: Removed `_initializePages()` call, now just updates `_selectedProject`

## Testing Checklist

- [x] Code compiles without errors
- [x] No unused imports
- [x] Duplicate projects are removed from display
- [x] First project is selected by default
- [ ] Selecting a project from bottom sheet works without errors
- [ ] Project selection updates the dashboard correctly
- [ ] Navigation between tabs works smoothly

## Files Modified
- `lib/features/home/presentation/pages/home_page.dart`
