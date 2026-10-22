# ============================================================
# PROGUARD / R8 RULES  (release build code chhota karta hai)
#
# Razorpay: inke bina release APK me checkout khulte hi crash / fail
# (debug me pata nahi chalta). Razorpay docs ke official rules.
# ============================================================

-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-keepattributes JavascriptInterface
-keepattributes *Annotation*

-dontwarn com.razorpay.**
-keep class com.razorpay.** { *; }

-optimizations !method/inlining/*

-keepclasseswithmembers class * {
    public void onPayment*(...);
}

# Razorpay ke andar Google Pay (UPI) ke liye
-dontwarn com.google.android.apps.nbu.paisa.inapp.client.api.**
-keep class com.google.android.apps.nbu.paisa.inapp.client.api.** { *; }
