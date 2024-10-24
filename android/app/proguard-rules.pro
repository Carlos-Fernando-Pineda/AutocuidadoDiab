# Mantén las clases necesarias para Firebase
-keep class com.google.firebase.** { *; }

# Mantén las clases de tu modelo de datos
-keepclassmembers class **.model.** { *; }

# Mantén los controladores de las actividades
-keep class * extends android.app.Activity
