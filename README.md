# EcoGuardian - Flutter Environmental Reporting App

EcoGuardian is a community-powered environmental reporting app built with Flutter, designed to protect public health and promote cleaner, greener cities. With a focus on issues like ragweed outbreaks, water pollution, and more, EcoGuardian allows users to report environmental hazards and visualize them on an interactive map.

## 🌱 Features

- **Report Environmental Issues**: Users can report various environmental hazards including:
  - Ragweed outbreaks
  - Water pollution
  - Air pollution
  - Illegal dumping
  - Noise pollution
  - Other environmental concerns

- **Interactive Map**: View all reports on a Google Maps interface with filtering capabilities

- **Photo Documentation**: Capture and attach photos to reports using camera or gallery

- **GPS Location**: Automatic location detection for accurate reporting

- **Statistics Dashboard**: View analytics and insights about environmental reports

- **Local Storage**: Offline support with SQLite database

- **Modern UI**: Beautiful and intuitive Material Design interface

## 🛠️ Setup Instructions

### Prerequisites

- Flutter SDK (>=3.5.0)
- Android Studio or VS Code with Flutter extensions
- Android device/emulator or iOS device/simulator
- Google Maps API key

### Installation Steps

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd ecoguardian-3
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Google Maps API:**
   - Get a Google Maps API key from [Google Cloud Console](https://console.cloud.google.com/)
   - Enable the following APIs:
     - Maps SDK for Android
     - Maps SDK for iOS
     - Geocoding API
     - Places API (optional)
   
   - For Android: Update `android/app/src/main/AndroidManifest.xml`
     ```xml
     <meta-data
         android:name="com.google.android.geo.API_KEY"
         android:value="YOUR_ACTUAL_API_KEY_HERE" />
     ```
   
   - For iOS: Add to `ios/Runner/AppDelegate.swift`
     ```swift
     import GoogleMaps
     
     @UIApplicationMain
     @objc class AppDelegate: FlutterAppDelegate {
       override func application(
         _ application: UIApplication,
         didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
       ) -> Bool {
         GMSServices.provideAPIKey("YOUR_ACTUAL_API_KEY_HERE")
         GeneratedPluginRegistrant.register(with: self)
         return super.application(application, didFinishLaunchingWithOptions: launchOptions)
       }
     }
     ```

4. **Run the app:**
   ```bash
   flutter run
   ```

### Opening in Android Studio

1. Open Android Studio
2. Click "Open an Existing Project"
3. Navigate to the `ecoguardian-3` folder and select it
4. Wait for the project to sync and index
5. Click the "Run" button or use `Shift + F10`

## 📱 App Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── report.dart          # Report data model
├── services/
│   ├── database_service.dart # SQLite database operations
│   ├── location_service.dart # GPS and geocoding
│   └── report_provider.dart  # State management
├── screens/
│   ├── home_screen.dart     # Main dashboard
│   ├── add_report_screen.dart # Create new reports
│   ├── map_screen.dart      # Interactive map view
│   ├── reports_list_screen.dart # List all reports
│   └── statistics_screen.dart # Analytics dashboard
└── widgets/
    └── (shared UI components)
```

## 🔧 Key Dependencies

- **google_maps_flutter**: Interactive maps
- **geolocator**: GPS location services
- **camera/image_picker**: Photo capture
- **sqflite**: Local database storage
- **provider**: State management
- **permission_handler**: Runtime permissions

## 🔐 Permissions

The app requires the following permissions:

### Android
- `ACCESS_FINE_LOCATION` - GPS location access
- `ACCESS_COARSE_LOCATION` - Network location access
- `CAMERA` - Camera access for photos
- `WRITE_EXTERNAL_STORAGE` - Save photos and data
- `READ_EXTERNAL_STORAGE` - Read saved photos
- `INTERNET` - Network access for maps and APIs

### iOS
Add to `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to report environmental issues at specific locations.</string>
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to take photos of environmental issues.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to attach existing photos to reports.</string>
```

## 🎯 Usage

1. **Creating Reports**: 
   - Tap the "+" floating action button
   - Select category, add title and description
   - Optionally add a photo
   - Location is automatically detected
   - Submit the report

2. **Viewing Reports**:
   - Use the map tab to see reports geographically
   - Use the reports tab for a list view with search/filter
   - Tap any report for detailed information

3. **Statistics**:
   - View analytics in the statistics tab
   - See trends, category breakdowns, and impact metrics

## 🌍 Environmental Impact

EcoGuardian helps communities by:
- Enabling rapid reporting of environmental hazards
- Creating awareness through data visualization
- Facilitating communication with local authorities
- Building a collaborative approach to environmental protection

## 🤝 Contributing

This app demonstrates modern Flutter development practices including:
- Clean architecture with separated concerns
- State management with Provider
- Local data persistence with SQLite
- Integration with native device features
- Material Design UI/UX principles

## 📄 License

This project is created for educational and community purposes.

---

**Ready to protect your environment? Build and run EcoGuardian today!** 🌱
