# ===========================================================================
# LifeGuard Finance — ProGuard / R8 Rules
# ===========================================================================

# ---------- Flutter / Dart --------------------------------------------------
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.**

# ---------- Hive (hive_ce / hive_ce_flutter) --------------------------------
# Hive stores data via reflection on TypeAdapters and Box internals.
# Keep all Hive model classes so R8 does not strip or rename them.
-keep class com.hive.** { *; }
-keep class dev.hivedb.** { *; }
-dontwarn com.hive.**
-dontwarn dev.hivedb.**

# Keep any class annotated with @HiveType / @HiveField
-keep @com.hive.annotations.HiveType class * { *; }
-keepclassmembers class * {
    @com.hive.annotations.HiveField *;
}

# ---------- Firebase --------------------------------------------------------
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# ---------- Flutter Local Notifications -------------------------------------
-keep class com.dexterous.** { *; }
-dontwarn com.dexterous.**

# ---------- url_launcher ----------------------------------------------------
-keep class io.flutter.plugins.urllauncher.** { *; }

# ---------- Kotlin & Coroutines ---------------------------------------------
-keep class kotlin.** { *; }
-keepclassmembernames class kotlinx.** {
    volatile <fields>;
}
-dontwarn kotlin.**

# ---------- Path Provider ---------------------------------------------------
-keep class io.flutter.plugins.pathprovider.** { *; }

# ---------- Google Fonts (loaded at runtime) --------------------------------
-dontwarn com.google.android.gms.ads.**

# ---------- General Dart/Flutter interop ------------------------------------
# Keep native method bindings
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelable implementations
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Suppress common R8 warnings that don't affect runtime
-dontwarn org.bouncycastle.**
-dontwarn org.conscrypt.**
-dontwarn org.openjsse.**
-dontwarn java.lang.invoke.**
