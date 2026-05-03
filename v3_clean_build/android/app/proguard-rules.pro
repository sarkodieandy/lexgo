# Flutter ProGuard Rules

# Keep essential networking classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep HTTP and Networking logic
-keep class java.net.** { *; }
-keep class javax.net.** { *; }
-keep class okhttp3.** { *; }
-keep class okio.** { *; }
-keep class com.google.gson.** { *; }
-keep class org.json.** { *; }

# Prevent shrinking of model classes
-keep class com.example.lexgo.models.** { *; }

# Keep all classes that are accessed via reflection
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod

# Standard libraries missing warnings
-dontwarn com.google.android.play.**
-dontwarn com.google.android.gms.**
-dontwarn javax.annotation.**
-dontwarn org.checkerframework.**
-dontwarn sun.misc.Unsafe
-dontwarn okio.**
-dontwarn okhttp3.**

# Keep Play Store Core if it exists
-keep class com.google.android.play.core.** { *; }
