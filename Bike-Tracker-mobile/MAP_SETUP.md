# Map Feature Setup Guide

## Overview

A map interface has been successfully integrated into the Bike Tracker app. After signing in, users will be directed to a map screen showing their current location.

## What Was Added

### 1. New Dependencies

- **google_maps_flutter**: For displaying Google Maps
- **location**: For accessing device location

### 2. New Map Screen (`lib/screens/map_screen.dart`)

Features include:

- Real-time location tracking
- User location marker on the map
- My Location button to center map on current position
- Zoom in/out controls
- Quick navigation to Profile, Bluetooth, and History via menu
- Permission handling for location access

### 3. Navigation Flow

- After successful login (test@bike.com / 123456), users are now directed to the Map screen instead of the Bluetooth screen
- Map screen is accessible via the `/map` route

### 4. Android Permissions

Added to `AndroidManifest.xml`:

- `INTERNET` - Required for map tiles
- `ACCESS_FINE_LOCATION` - For precise location
- `ACCESS_COARSE_LOCATION` - For approximate location
- `ACCESS_BACKGROUND_LOCATION` - For background tracking (if needed)

## Google Maps API Key Configuration

### Current Status

The AndroidManifest.xml already contains a Google Maps API key. If you need to use a different key:

### Get a Google Maps API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the following APIs:
   - Maps SDK for Android
   - Maps SDK for iOS (if building for iOS)
4. Go to "Credentials" and create an API Key
5. Restrict the API key to your app's package name for security

### Configure Android

The API key is already set in:
`android/app/src/main/AndroidManifest.xml`

```xml
<meta-data android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY_HERE"/>
```

### Configure iOS (if needed)

Add to `ios/Runner/AppDelegate.swift`:

```swift
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_IOS_API_KEY_HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

## Testing the Map

### Run the App

```bash
flutter run
```

### Test Credentials

- Email: test@bike.com
- Password: 123456

### Expected Behavior

1. Sign in with test credentials
2. Automatically navigate to Map screen
3. App requests location permissions (grant them)
4. Map loads with your current location marked
5. Use menu (three dots) to access other features

## Location Permissions

On first launch, the app will request:

- Location permission (Allow)
- Background location (optional, for tracking while app is in background)

## Troubleshooting

### Map shows blank/gray

- Check that Google Maps API key is valid
- Ensure Maps SDK for Android is enabled in Google Cloud Console
- Verify internet connection

### Location not showing

- Grant location permissions when prompted
- Check device location services are enabled
- Try tapping "My Location" button

### Build errors

- Run `flutter clean` then `flutter pub get`
- Ensure all dependencies are properly installed

## Features Available from Map Screen

Via the menu button (⋮):

- **Profile**: View and edit user profile
- **Bluetooth**: Connect to bike tracker device
- **History**: View tracking history

## Next Steps

- Customize the map marker icon for bike location
- Add route tracking and path history
- Implement geofencing for bike zones
- Add multiple markers for saved locations
