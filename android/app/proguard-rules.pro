########################################
# Flutter & Dart
########################################
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

########################################
# AndroidX
########################################
-dontwarn androidx.**
-keep class androidx.** { *; }

########################################
# Google Play Core (SplitInstall)
########################################
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task

########################################
# Google Play Billing (In-App Purchase)
########################################
-keep class com.android.billingclient.api.** { *; }
-dontwarn com.android.billingclient.**

########################################
# Firebase / Google Services (if used)
########################################
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

########################################
# Retrofit / Gson (if using API calls)
########################################
-keep class retrofit2.** { *; }
-dontwarn retrofit2.**
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**
-keepattributes Signature
-keepattributes *Annotation*

########################################
# Kotlin (common for Flutter plugins)
########################################
-keep class kotlin.** { *; }
-dontwarn kotlin.**
-dontnote kotlin.**

########################################
# General rules to keep models & prevent reflection issues
########################################
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

-keepclassmembers class **.R$* {
    public static <fields>;
}
-keep class **.R {
    <fields>;
}

########################################
# Suppress unused warnings
########################################
-dontwarn java.lang.invoke.*
-dontwarn sun.misc.Unsafe
-dontwarn org.codehaus.mojo.animal_sniffer.IgnoreJRERequirement

########################################
# Optimization
########################################
-optimizations !code/simplification/arithmetic,!field/*,!class/merging/*
-keepattributes SourceFile,LineNumberTable
