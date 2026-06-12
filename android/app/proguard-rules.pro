# Protéger Supabase
-keep class com.supabase.** { *; }
-keep class io.** { *; }
-keep class com.google.** { *; }
-keep class androidx.** { *; }
-keep class kotlin.** { *; }

# Protéger Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Désactiver l'obfuscation complète
-dontobfuscate

# Ne pas optimiser
-dontoptimize

# Warnings
-dontwarn com.supabase.**
-dontwarn io.**
-dontwarn com.google.**