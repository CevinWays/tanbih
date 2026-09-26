# Keep rules for the release build.
#
# R8 already keeps every component named in AndroidManifest.xml — it treats
# the manifest as an entry point — so the adhan receiver, the boot receiver,
# and the playback service survive without help. Verified in
# build/app/outputs/mapping/release/mapping.txt: their names come through
# unchanged while purely internal classes get shortened.
#
# What follows covers the cases R8 cannot see.

# flutter_local_notifications stores its pending schedule as JSON, and Gson
# uses field names as the JSON keys. Renaming a field renames the key. Within
# one build that stays self-consistent and looks fine; the damage shows up
# across an app update, when JSON written by the old build is read back by a
# build that renamed things differently. Every pending prayer notification
# would disappear, with no error, until the user happened to open the app.
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.dexterous.flutterlocalnotifications.models.** { *; }

# Gson itself resolves generic types through reflection.
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-dontwarn com.google.gson.**

# Our own components are reached from the manifest and from AlarmManager
# PendingIntents, both by name. R8 handles the manifest side on its own; this
# states the requirement so a future manifest refactor cannot quietly break
# playback.
-keep class com.cevin.tanbih.alarm.AdhanAlarmReceiver { *; }
-keep class com.cevin.tanbih.alarm.BootReceiver { *; }
-keep class com.cevin.tanbih.audio.AdhanPlaybackService { *; }

# Referenced from the Android 12+ splash theme rather than from code.
-keep class com.cevin.tanbih.MainActivity { *; }
