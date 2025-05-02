# AutoFarmer - Day 9: Firebase Integration and Actuator Control

A smart farming solution that helps monitor and control your farm automation system. This implementation focuses on Day 9's requirements: Firebase integration for actuator control and real-time device state management.

## Features

### Day 9: Firebase Integration & Actuator Control
- Real-time actuator control through Firebase Firestore
- Secure device state management
- Firestore security rules implementation
- User authentication and device ownership
- Real-time status synchronization

### Implemented Components
1. **Firebase Integration**
   - Cloud Firestore database setup
   - Real-time data synchronization
   - Security rules implementation
   - Device state management

2. **Actuator Control Interface**
   - Water Supply Control
   - Light Control
   - Motor Control
   - Auto Mode Toggle
   - Real-time status updates
   - Loading and error states
   - Visual feedback for state changes

3. **Database Structure**
```
/actuators/{deviceId}/
  - motor: boolean
  - light: boolean
  - waterSupply: boolean
  - autoMode: boolean
  - lastUpdated: timestamp

/users/{userId}/
  - email: string
  - name: string
  - phone: string
  - preferredLanguage: string
  - createdAt: timestamp
  - updatedAt: timestamp

/users/{userId}/devices/{deviceId}/
  - registeredAt: timestamp
```

## Setup Instructions

1. **Prerequisites**
   - Flutter SDK (3.0.0 or higher)
   - Firebase account
   - Android Studio / VS Code

2. **Firebase Setup**
   - Create a new Firebase project
   - Enable Authentication (Email/Password)
   - Create Cloud Firestore database
   - Add Android/iOS apps in Firebase Console
   - Download and add configuration files
     - `google-services.json` for Android
     - `GoogleService-Info.plist` for iOS

3. **Project Setup**
```bash
# Clone the repository
git clone [repository-url]

# Navigate to project directory
cd autofarmer

# Install dependencies
flutter pub get

# Run the app
flutter run
```

4. **Firebase Security Rules**
Copy and paste these rules in Firebase Console:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function ownsDevice(deviceId) {
      return exists(/databases/$(database)/documents/users/$(request.auth.uid)/devices/$(deviceId));
    }

    // User profile rules
    match /users/{userId} {
      allow read: if isAuthenticated() && request.auth.uid == userId;
      allow write: if isAuthenticated() && request.auth.uid == userId;
      
      // User's devices
      match /devices/{deviceId} {
        allow read, write: if isAuthenticated() && request.auth.uid == userId;
      }
    }
    
    // Actuator state rules
    match /actuators/{deviceId} {
      allow read: if isAuthenticated() && ownsDevice(deviceId);
      allow write: if isAuthenticated() && ownsDevice(deviceId);
    }
  }
}
```

## Key Files
- `lib/screens/actuator_control_screen.dart`: Main actuator control interface
- `lib/services/auth_service.dart`: Firebase authentication and device management
- `firestore.rules`: Firestore security rules
- `lib/main.dart`: App initialization and Firebase setup

## Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.2
  cloud_firestore: ^4.14.0
  firebase_auth: ^4.16.0
  provider: ^6.0.5
```

## Contributing
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License
This project is licensed under the MIT License - see the LICENSE file for details
