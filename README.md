# AutoFarmer

AutoFarmer is a Flutter application for managing and monitoring smart farming devices. The app provides real-time monitoring of sensors, device management, and automated control of farming equipment.

## Features

- **Authentication**
  - Secure user login and registration
  - Firebase Authentication integration
  - Persistent login state

- **Home Dashboard**
  - Welcome screen with user information
  - Quick access to key features
  - Modern Material Design 3 UI

- **Device Management**
  - Add new devices via QR code scanning
  - Real-time device status monitoring
  - Edit device names and locations
  - Remove devices from the system

- **Sensor Monitoring**
  - Real-time temperature readings
  - Humidity monitoring
  - Soil moisture tracking
  - Historical data visualization

- **Actuator Control**
  - Remote control of water supply
  - Lighting system management
  - Motor control for automation

## Technical Details

### Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.32.0
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.17.5
  provider: ^6.0.5
  barcode_scan2: ^4.3.0
  fl_chart: ^0.66.2
```

### Requirements

- Flutter SDK: >=3.0.6 <4.0.0
- Android SDK: API 21 or higher
- iOS: 11.0 or higher

### Firebase Setup

1. Create a new Firebase project
2. Add Android and iOS apps to your Firebase project
3. Download and add the configuration files:
   - Android: `google-services.json`
   - iOS: `GoogleService-Info.plist`

## Getting Started

1. Clone the repository:
```bash
git clone https://github.com/yourusername/autofarmer.git
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart
├── firebase_options.dart
├── models/
│   ├── device.dart
│   ├── sensor_data_model.dart
│   ├── sensor_history_model.dart
│   └── actuator_state_model.dart
├── screens/
│   ├── home_screen.dart
│   ├── login_screen.dart
│   ├── device_manager_screen.dart
│   ├── sensor_data_screen.dart
│   └── sensor_history_screen.dart
└── services/
    └── device_service.dart
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Firebase for the backend services
- All contributors who participate in this project
