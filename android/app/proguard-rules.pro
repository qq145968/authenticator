# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Flutter Play Core split application (referenced by FlutterPlayStoreSplitApplication
# but Play Core dependency is not always present; suppress R8 missing-class error)
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.splitcompat.SplitCompatApplication { *; }

# Keep model classes
-keep class com.authenticator.app.** { *; }
