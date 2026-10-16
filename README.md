# SkySeaBooking

A responsive Flutter booking app for flights and sea trips around the Philippines. Routes, fares, and bookings use mock data; destination details fetch live weather from the public Open-Meteo API. The destination catalog remains available from local mock data if the API cannot be reached. Local user accounts and profile data are stored on the device; there is no account backend or live booking integration.

## Run locally

1. Install the Flutter SDK.
2. In this folder, run `flutter pub get`.
3. Run `flutter run`.

## App structure

- `lib/main.dart` and `lib/theme/`: app entry point and Material 3 styling.
- `lib/models/`, `lib/data/mock_data.dart`, `lib/services/`, and `lib/providers/`: models, mock travel data, local authentication, and app state.
- `lib/screens/`: splash, login, sign-up, Home, Search, My Bookings, Notifications, Profile, settings, and destination flows.
- `lib/widgets/`: reusable search, destination, route, booking, profile, and navigation widgets.

The five-tab bottom navigation uses an `IndexedStack` to preserve tab state. Accounts are saved with `shared_preferences` on mobile and browser `localStorage` on web; passwords are SHA-256 hashed and never stored as plain text. This is a local demo, not production authentication: neither storage mechanism is secure credential storage, and data remains on this device/browser.

## Live API and offline fallback

Open a destination from Home or the destination catalog to see current temperature, conditions, humidity, and wind from [Open-Meteo](https://open-meteo.com/). The API is keyless; the destination card/catalog is backed by bundled mock data, so the app remains browsable when a connection/API is unavailable. The details screen shows loading/error states and a retry action.

## Delete and undo bookings

In **My Bookings**, tap the delete icon on a booking and confirm the prompt. The booking is removed from the active list; tap **Undo** in the confirmation snackbar to restore it.

## Presentation walkthrough

1. Create a local account and show validation and the saved profile.
2. Open Home, select a destination, and show its current weather loading from Open-Meteo.
3. Turn off the internet or simulate an API failure to show the retry/error message while the mock destination catalog remains available.
4. Open **My Bookings**, delete a booking, cancel once to show the confirmation guard, then confirm deletion and demonstrate **Undo**.
5. Show the five-tab navigation, destination filters/search, and the demo checkout methods. Checkout is a simulation and does not charge money.

Bookings and booking deletions are mock in-memory data for this demo and reset when the app process restarts. User accounts are stored locally in browser storage or device preferences.

The UI uses Material 3 app bars, responsive layouts, reusable widgets, stateful forms/filters, `ListView.builder` for booking lists, Provider for shared booking/authentication state, and loading/error/empty states for data-dependent screens.

Booking checkout includes mock GCash, Maya, credit-card, and debit-card options. It records the selected method with the demo booking but does not collect account/card information or process real payments. A payment gateway and backend integration are required before accepting real payments.

## Image picker platform notes

- **iOS:** add `NSPhotoLibraryUsageDescription` and `NSCameraUsageDescription` string entries to `ios/Runner/Info.plist`, explaining that SkySeaBooking uses photos for the user's profile picture.
- **Android:** the system photo picker used by `image_picker` does not require broad media-storage permissions. If the app's camera flow is enabled on Android, add `<uses-permission android:name="android.permission.CAMERA" />` to `android/app/src/main/AndroidManifest.xml`. No Android/iOS platform folders are currently included in this workspace, so apply the settings after generating those platform projects.
- Handle canceled picker results and denied permissions in the UI; do not request photo access until the user taps the photo control.

## Validate

Run `flutter analyze` and `flutter test`. `test/destination_weather_service_test.dart` verifies API parsing, request location, and failure handling without requiring internet access.
