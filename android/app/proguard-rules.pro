# Suppress OpenGL ES errors
-keep class javax.microedition.khronos.** { *; }
-dontwarn javax.microedition.khronos.**
-keep class android.opengl.** { *; }
-dontwarn android.opengl.**

# Suppress EGL warnings
-keep class javax.microedition.khronos.egl.** { *; }
-dontwarn javax.microedition.khronos.egl.**

# Suppress specific OpenGL error messages
-keepclasseswithmembers class * {
    native <methods>;
}

# Keep native methods
-keepclassmembers class * {
    native <methods>;
}

# Additional rules for Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; } 