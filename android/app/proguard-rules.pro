# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# TFLite
-keep class org.tensorflow.lite.interpreter.** { *; }
-keep class org.tensorflow.lite.gpu.** { *; }
-keep class org.tensorflow.lite.delegates.gpu.** { *; }
-keep class org.tensorflow.lite.support.** { *; }

# TFLite Flutter
-keep class com.tfliteflutter.tflite_flutter_plugin.** { *; }

# Prevent R8 from removing standard interfaces often used via reflection
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Don't warn about missing classes that are optional (often caused by TFLite partial deps)
-dontwarn org.tensorflow.lite.**
-dontwarn java.lang.invoke.*
-dontwarn javax.**
-dontwarn com.google.android.gms.**
-dontwarn androidx.**
-dontwarn com.google.android.play.core.**


