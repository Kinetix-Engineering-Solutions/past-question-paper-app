# Offline Connectivity System - Implementation Guide

## Overview
This document describes the offline/online connectivity detection and UX system implemented for the Past Question Papers app. The system provides real-time network status monitoring and user-friendly offline feedback.

## Architecture

### Components

#### 1. **ConnectivityService** (`lib/services/connectivity_service.dart`)
Core service that monitors network connectivity and internet reachability.

**Features:**
- OS-level connectivity detection via `connectivity_plus` package
- Actual internet reachability verification (DNS lookup to google.com)
- Debounced status changes (500ms) to avoid flicker during network transitions
- Periodic health checks every 30 seconds
- Three status levels: `online`, `degraded`, `offline`

**Status Definitions:**
- `online`: Network connected + internet verified
- `degraded`: Network connected but internet unverified/slow
- `offline`: No network connection

#### 2. **Connectivity Providers** (`lib/providers/connectivity_provider.dart`)
Riverpod providers for global state management.

**Providers:**
- `connectivityServiceProvider`: Singleton service instance
- `connectivityStatusProvider`: StreamProvider for reactive status updates
- `currentConnectivityStatusProvider`: Synchronous status access
- `recheckConnectivity()` extension method for manual retries

**Usage Example:**
```dart
// Watch status reactively
final connectivityStatus = ref.watch(connectivityStatusProvider);
connectivityStatus.when(
  data: (status) {
    if (status == ConnectivityStatus.offline) {
      // Show offline UI
    }
  },
  loading: () => CircularProgressIndicator(),
  error: (err, stack) => Text('Error: $err'),
);

// Read status synchronously
final status = ref.read(currentConnectivityStatusProvider);

// Trigger manual recheck
await ref.recheckConnectivity();
```

#### 3. **ConnectivityBanner** (`lib/widgets/connectivity_banner.dart`)
Global banner widget that displays when network is offline or degraded.

**Features:**
- Slide-in animation from top
- Themed styling (Paper & Ink palette)
- Different visual treatments for offline vs degraded
- "Retry" button for offline state with loading indicator
- Auto-dismisses when connection restored

**Styling:**
- **Offline**: Dark background (ink), white text, wifi-off icon
- **Degraded**: Accent soft background, accent icon, warning message

**Integration:**
Banner is inserted via `MaterialApp.builder` in `main.dart`, positioned above all screens using a `Stack`.

#### 4. **Enhanced EmptyState** (`lib/widgets/empty_state.dart`)
Updated with offline-specific factory constructors.

**New Factories:**
```dart
// Offline state
EmptyState.offline(onRetry: () => ref.recheckConnectivity())

// Network error state
EmptyState.networkError(
  customMessage: 'Unable to load data',
  onRetry: () => _retryLoad(),
)
```

**Theme Support:**
Now respects light/dark themes using `colorScheme` instead of hardcoded colors.

## Integration Points

### Global Banner (✅ Implemented)
The banner is automatically shown/hidden based on connectivity status. No additional code needed in individual screens.

### ViewModels (Future Enhancement)
ViewModels can check connectivity before making network calls:

```dart
final status = ref.read(currentConnectivityStatusProvider);
if (status == ConnectivityStatus.offline) {
  // Show cached data or offline message
  return;
}
// Proceed with network call
```

### Error Handling (Future Enhancement)
When Firebase/network calls fail, check if it's due to offline status:

```dart
try {
  await firestore.collection('questions').get();
} catch (e) {
  final status = ref.read(currentConnectivityStatusProvider);
  if (status == ConnectivityStatus.offline) {
    return EmptyState.offline(onRetry: _reload);
  }
  return EmptyState.networkError(onRetry: _reload);
}
```

## Testing Guidance

### Manual Testing
1. **Offline Detection:**
   - Enable airplane mode → Banner should appear within 1-2 seconds
   - Disable airplane mode → Banner should disappear
   
2. **Degraded Detection:**
   - Connect to WiFi without internet (captive portal) → "Limited connectivity" banner
   
3. **Retry Functionality:**
   - While offline, tap "Retry" → Loading spinner → Status rechecked
   
4. **Theme Consistency:**
   - Toggle dark/light mode → Banner and EmptyState should use correct theme colors

### Emulator Testing Commands
```bash
# Test offline mode
flutter run -d windows

# Then toggle airplane mode in Windows settings
# Or use network simulation in Android emulator
```

### Edge Cases Covered
- Rapid network switching (WiFi ↔ mobile data): Debounced to prevent flicker
- DNS failures without full offline: Detected as "degraded"
- App backgrounding/foregrounding: Periodic checks ensure status stays accurate
- Provider disposal: Service properly cleaned up when app closes

## Future Enhancements

### Phase 2: Local Caching
- Cache question data for offline practice
- Queue test submissions for later upload
- Implement Firestore offline persistence

### Phase 3: Smart Degradation
- Reduce image quality when connection is slow
- Show simplified UI in degraded mode
- Prefetch commonly used data

### Phase 4: Analytics
- Track offline session durations
- Monitor connectivity-related errors
- Measure retry success rates

## Dependencies

### New Package
```yaml
connectivity_plus: ^6.1.1
```

**Platform Support:**
- ✅ Android
- ✅ iOS
- ✅ Windows
- ✅ macOS
- ✅ Web
- ✅ Linux

### Permissions Required
**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

**iOS** (automatically handled by connectivity_plus)

## Performance Considerations

- **Lightweight Checks:** DNS lookup uses 5-second timeout
- **Debouncing:** 500ms delay prevents excessive status changes
- **Periodic Checks:** Only run every 30 seconds (configurable)
- **Stream Efficiency:** Broadcast stream allows multiple listeners without overhead

## Color Palette Compliance

All UI elements follow the Paper & Ink design system:
- `AppColors.ink` / `AppColorsDark.ink` for offline banner
- `AppColors.accentSoft` / `AppColorsDark.accentSoft` for degraded state
- `AppColors.accent` for CTAs and icons
- `AppColors.neutralCard` for text on dark backgrounds

## File Structure

```
lib/
├── services/
│   └── connectivity_service.dart       # Core monitoring service
├── providers/
│   └── connectivity_provider.dart      # Riverpod state management
├── widgets/
│   ├── connectivity_banner.dart        # Global banner UI
│   └── empty_state.dart                # Enhanced with offline factories
└── main.dart                           # Banner integration point
```

## Troubleshooting

### Banner Not Appearing
1. Ensure `flutter pub get` was run after adding dependency
2. Verify MaterialApp has `builder` property set
3. Check console for connectivity status logs

### False Offline Detection
- Google DNS (8.8.8.8) may be blocked in some networks
- Consider adding fallback DNS servers in future iteration

### Banner Overlapping Content
- Banner uses `SafeArea` to avoid notch/status bar
- Uses `Positioned` widget to overlay content
- Z-index handled by Stack ordering

---

**Implementation Date:** November 15, 2025  
**Author:** Kinetix Engineering Solutions  
**Version:** 1.0.0
