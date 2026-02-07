# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**AppPad** is a macOS Launchpad replacement application built with SwiftUI and AppKit. It provides a full-screen grid of application icons with search, pagination, drag-and-drop support, and extensive customization options.

**Key Technologies:**
- **UI Framework:** SwiftUI + AppKit (hybrid approach)
- **Data Persistence:** SwiftData
- **Global Hotkeys:** Carbon API
- **Animations:** NSAnimationContext + SwiftUI
- **Target:** macOS 14.0+ (Sonoma and later)

## Common Development Commands

### Building the Project

**Using Xcode (Recommended):**
```bash
open Package.swift  # Opens the project in Xcode
# Then press Cmd+R to build and run
```

**Using Swift CLI:**
```bash
swift build              # Build in Debug mode
swift build -c release   # Build in Release mode
.build/debug/AppPad      # Run Debug build
.build/release/AppPad    # Run Release build
```

**Clean build cache:**
```bash
rm -rf .build
```

### Interactive Script
A helper script `run.sh` provides a menu-driven interface for common tasks:
```bash
./run.sh
```

## Architecture & Design

### High-Level Structure

The application follows a **modular, layered architecture:**

```
AppPad/
├── AppPadApp.swift + AppDelegate
│   └── Manages app lifecycle, window creation, hotkey registration
│
├── Models/
│   ├── AppIcon.swift (in-memory model)
│   └── DataModels.swift (SwiftData entities: AppIconEntity, FolderEntity, UserPreferencesEntity)
│
├── Services/
│   ├── AppScanner.swift (discovers installed apps)
│   ├── GlobalHotkeyManager.swift (Carbon API for Option+Space hotkey)
│   └── WindowAnimationManager.swift (handles show/hide animations)
│
├── ViewModels/
│   └── AppListViewModel.swift (manages app list state, search, pagination)
│
└── Views/
    ├── ContentView.swift (main fullscreen interface)
    ├── IconGridView.swift (app icon grid layout)
    ├── SettingsView.swift (preferences window)
    ├── DraggableAppIcon.swift (draggable icon component)
    ├── SearchField.swift (search input)
    ├── PageGestureView.swift (gesture handling for pagination)
    ├── ClickableHostingView.swift (custom NSView wrapper for click detection)
    ├── MainWindow.swift (custom NSWindow)
    └── SettingsWindowController.swift (settings window management)
```

### Key Architectural Patterns

1. **Hybrid SwiftUI + AppKit**: SwiftUI provides the UI, AppKit handles system integration (window management, global hotkeys, animations).

2. **Actor-based Concurrency**: `AppScanner` uses Swift's actor model for thread-safe app discovery.

3. **State Management**:
   - `AppListViewModel` manages the app list, search, and pagination state
   - `@AppStorage` for preferences persistence (immediate fallback before SwiftData integration)
   - SwiftData entities for persistent data (partially integrated)

4. **Service Layer**: Dedicated services handle isolated concerns:
   - App scanning (filesystem access)
   - Hotkey registration (system-level)
   - Window animations (CoreAnimation)

5. **Responsive Gestures**: Custom gesture views (`PageGestureView`) handle swipe pagination and touch sensitivity.

### Data Flow

1. **App Launch**: `AppDelegate.applicationDidFinishLaunching()` creates `MainWindow` with `ContentView` and registers the global hotkey via `GlobalHotkeyManager`.

2. **App Discovery**: `AppListViewModel` scans for apps using `AppScanner.scanApplications()`, which recursively searches `/Applications`, `/System/Applications`, and `~/Applications`.

3. **Display**: `ContentView` displays the results through:
   - `SearchField` for filtering
   - `PageGestureView` for gesture-based pagination
   - `IconGridView` for the grid layout
   - `DraggableAppIcon` for individual app icons (with long-press edit mode)

4. **User Actions**:
   - Click/launch: Executes the app using NSWorkspace
   - Search: Filters apps by name or Pinyin
   - Drag: Reorders apps (partially implemented)
   - Long-press: Enters edit mode (UI ready)

5. **Window Control**:
   - Hotkey (Option+Space), Esc key, or background click triggers `AppDelegate.toggleWindow()`
   - `WindowAnimationManager` animates the show/hide with scale + fade effects

### Settings/Preferences

Three categories managed by `SettingsView`:

1. **Appearance** (stored in `@AppStorage`):
   - Icon size: 40-120px
   - Grid columns/rows
   - Background blur intensity

2. **Behavior**:
   - Gesture sensitivity
   - Animation speed
   - Global shortcut enable/disable

3. **General**:
   - Launch at login
   - Reset to defaults
   - Version info

### SwiftData Integration Status

- Models defined in `DataModels.swift` (ready to use)
- Partially integrated; `@AppStorage` still used as primary storage
- Next step: Initialize `ModelContainer` in `AppPadApp` and sync app list to SwiftData on first launch

## Important Development Notes

### Permissions Required

The app needs the following entitlements (defined in `AppPad.entitlements`):
- **Accessibility** (for global hotkey registration via Carbon API)
- **File Access** (to read app bundles and icons)

### Key Files to Understand

- **AppPadApp.swift:712** - Main app entry, `AppDelegate`, window initialization
- **AppListViewModel.swift** - Central state container for app list, search, pagination
- **WindowAnimationManager.swift** - All show/hide animations
- **GlobalHotkeyManager.swift** - Carbon API hotkey registration
- **ClickableHostingView.swift** - Custom NSView for handling background clicks (prevents accidental dismissal)

### Common Customization Points

1. **Change hotkey**: Modify `GlobalHotkeyManager.swift` (currently hardcoded to Option+Space)
2. **Adjust icon cache**: Add caching in `AppScanner.swift`
3. **Tweak animations**: Modify timing in `WindowAnimationManager.swift`
4. **Add new preferences**: Add properties to `UserPreferencesEntity` and update `SettingsView.swift`

### Performance Considerations

- **Icon loading**: Currently synchronous; consider lazy loading for slow devices
- **Search**: Already optimized with Combine debouncing
- **Animation**: Uses Core Animation (GPU-accelerated); set to 60fps default, can target 120fps
- **Memory**: App list kept in memory; ~50MB baseline, scalable with app count

## Testing & Debugging

### Known Issues & Workarounds

- **SwiftData not yet fully integrated**: Use `@AppStorage` as fallback
- **Drag-and-drop**: UI ready but not fully implemented
- **File folders**: Data model ready but UI not complete
- **Edit mode**: Long-press detected but delete not wired

### Debug Logging

Add conditional compilation for debug output:
```swift
#if DEBUG
print("Debug info")
#endif
```

## Notes for Future Work

### High Priority
1. Complete SwiftData integration (initialize container, persist app layout)
2. Implement drag-and-drop reordering with persistence
3. Implement file folder creation (drag icon onto another)
4. Wire up delete button in edit mode

### Medium Priority
5. Search result highlighting and keyboard navigation
6. Hot corner support (corner detection + window show)
7. Launch at login (ServiceManagement framework)

### Low Priority
8. Metal rendering optimization (Liquid Glass effect)
9. Icon caching (NSImage caching layer)
10. 120fps animation targeting

## Project Metadata

- **Minimum macOS**: 14.0 (Sonoma)
- **Swift Version**: 6.0+
- **Main Branch**: main
- **Executable Name**: AppPad
- **Build Products**: `.build/debug/AppPad` or `.build/release/AppPad`

---

## Known Issues and Solutions

### ✅ RESOLVED: Text Input Not Working in Search and Folder Name Fields

**Date**: 2026-02-07  
**Severity**: Critical  
**Status**: Fixed

#### Problem
- Search field could not accept keyboard input
- Folder name editing did not work
- Text typed would appear in terminal instead of GUI
- Issue persisted across multiple attempted fixes

#### Root Cause
The `NSPanel` window was configured with `.fullSizeContentView` in its `styleMask`, which completely blocked text input in borderless panels.

**Problematic code**:
```swift
// AppPadApp.swift
let window = MainWindow(
    contentRect: screenRect,
    styleMask: [.borderless, .fullSizeContentView],  // ❌ This blocks text input!
    backing: .buffered,
    defer: false
)
```

#### Solution

**1. Remove `.fullSizeContentView` from styleMask** (AppPadApp.swift):
```swift
let window = MainWindow(
    contentRect: screenRect,
    styleMask: [.borderless],  // ✓ Just borderless
    backing: .buffered,
    defer: false
)
```

**2. Add critical NSPanel properties** (MainWindow.swift):
```swift
override init(...) {
    super.init(...)
    
    self.becomesKeyOnlyIfNeeded = false
    self.hidesOnDeactivate = false
    self.worksWhenModal = true          // ✓ CRITICAL for text input
    self.isFloatingPanel = true         // ✓ Proper panel behavior
    self.styleMask.insert(.nonactivatingPanel)  // ✓ But can become key
    
    // ... rest of configuration
}
```

**3. Use SwiftUI TextField instead of NSTextField wrapper**:
- Changed `SearchBarView` to use SwiftUI `TextField`
- Changed `FolderExpandedView` to use SwiftUI `TextField`
- Used `@FocusState` for focus management

#### Key Learnings
- `.fullSizeContentView` + `.borderless` + `NSPanel` = no text input
- `worksWhenModal = true` is essential for NSPanel text input
- SwiftUI `TextField` is more reliable than `NSViewRepresentable` wrappers in SwiftUI contexts
- When debugging text input issues, always check window-level configuration first

#### Files Modified
- `Sources/AppPad/AppPadApp.swift` - Removed `.fullSizeContentView`
- `Sources/AppPad/MainWindow.swift` - Added panel properties
- `Sources/AppPad/Views/SearchField.swift` - Switched to SwiftUI TextField
- `Sources/AppPad/Views/FolderExpandedView.swift` - Switched to SwiftUI TextField
- `Sources/AppPad/ContentView.swift` - Updated keyboard event handling
