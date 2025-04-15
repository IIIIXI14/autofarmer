## ✅ Day 2: Firebase Authentication + Build Setup Fixes

### 🔐 Features Implemented:
- Firebase Email/Password Login & Signup
- Login/Signup UI screens with error handling
- Home screen routing after login

### 🛠️ Android Build Fixes:
- Migrated JVM toolchain to Java 17
- Fixed NDK version mismatch (NDK 27)
- Enabled core library desugaring for QR scanner support
- Replaced broken `qr_code_scanner` with stable `mobile_scanner` (recommended)

### 🔧 Configuration Done:
- Updated `build.gradle.kts` for:
  - `ndkVersion = "27.0.12077973"`
  - `kotlinOptions { jvmTarget = "17" }`
  - `compileOptions` to use `JavaVersion.VERSION_17`
- Added `gradle.properties` to use correct JDK path

### 🧪 Tested:
- Login → redirects to dashboard
- Register new account
