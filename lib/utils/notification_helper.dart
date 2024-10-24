import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final onClickNotification = BehaviorSubject<String>();

  // Convertir el notificationId (string) en un hashCode entero
  static int generateNotificationId(String notificationId) {
    return notificationId.hashCode;
  }

  // Inicializar las notificaciones
  static Future<void> initializeNotifications() async {
    tz.initializeTimeZones(); // Inicializar las zonas horarias

    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: onNotificationTap,
    );
  }

  // Manejo de la respuesta cuando el usuario interactúa con la notificación
  static void onDidReceiveNotificationResponse(NotificationResponse response) {
    onClickNotification.add(response.payload!);
  }

  // Nueva función para calcular la siguiente hora de notificación
  static DateTime calculateNextNotificationTime(DateTime scheduledDate, int intervalInHours) {
    DateTime now = DateTime.now();
    DateTime nextNotification = scheduledDate;

    // Incrementar la hora de notificación hasta que sea mayor que la hora actual
    while (!nextNotification.isAfter(now)) {
      nextNotification = nextNotification.add(Duration(hours: intervalInHours));
    }

    return nextNotification;
  }

  // Notificación programada (primera notificación)
  static Future<void> scheduleNotification(String notificationId, DateTime scheduledDate,
      {required String title, required String body}) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'medication_reminder_channel',
      'Medication Reminder',
      channelDescription: 'Notification for medication reminders',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    // Calcular la fecha programada válida (en el futuro)
    DateTime validScheduledDate = calculateNextNotificationTime(scheduledDate, 0); // Si no es repetida, usamos 0 horas

    await flutterLocalNotificationsPlugin.zonedSchedule(
      generateNotificationId(notificationId), // Usar el hash como ID único
      title,
      body,
      tz.TZDateTime.from(validScheduledDate, tz.local), // Usar la fecha validada
      NotificationDetails(android: androidNotificationDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Notificación repetida basada en la fecha actual
  static Future<void> repeatNotification(String notificationId, DateTime firstDateTime, 
      {required int intervalInHours, required String title, required String body}) async {
    // Calcular el próximo tiempo de notificación basándose en la fecha actual
    DateTime nextNotificationTime = calculateNextNotificationTime(firstDateTime, intervalInHours);

    await scheduleNotification(notificationId, nextNotificationTime, title: title, body: body);
  }

  // Función combinada: Programar la primera notificación y luego repeticiones basadas en la fecha actual
  static Future<void> scheduleAndRepeatNotification(String notificationId, DateTime firstDateTime, 
      int intervalInHours, {required String title, required String body}) async {
    // Programar la primera notificación
    await scheduleNotification(notificationId, firstDateTime, title: title, body: body);

    // Después de la primera, programar repeticiones basadas en la fecha actual
    await repeatNotification(notificationId, firstDateTime, intervalInHours: intervalInHours, title: title, body: body);
  }

    // Notificación programada (para eventos del calendario)
  static Future<void> scheduleEventNotification(String eventId, DateTime scheduledDate,
      {required String title, required String body}) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'event_channel', // Canal específico para eventos
      'Event Notifications',
      channelDescription: 'Notification channel for calendar events',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    // Calcular la fecha programada válida (en el futuro)
    DateTime validScheduledDate = calculateNextNotificationTime(scheduledDate, 0);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      generateNotificationId(eventId), // Usar el hash como ID único
      title,
      body,
      tz.TZDateTime.from(validScheduledDate, tz.local), // Usar la fecha validada
      NotificationDetails(android: androidNotificationDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Función para alarmas (similar a notificación repetida)
  static Future<void> scheduleAlarm(String notificationId, DateTime alarmTime, int intervalInHours, 
      {required String title, required String body}) async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'medication_alarm_channel',
      'Medication Alarm',
      channelDescription: 'Alarma para recordatorio de medicamento',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alarm_sound'),
      enableVibration: true,
      ongoing: true,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction('stop_alarm', 'Apagar Alarma'),
      ],
    );

    // Calcular la fecha de alarma válida
    DateTime validAlarmTime = calculateNextNotificationTime(alarmTime, 0);

    // Programar la primera alarma
    await flutterLocalNotificationsPlugin.zonedSchedule(
      generateNotificationId(notificationId), // Usar el hash como ID único
      title,
      body,
      tz.TZDateTime.from(validAlarmTime, tz.local), // Usar la fecha validada
      NotificationDetails(android: androidNotificationDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    // Después de la primera, programar repeticiones
    await repeatNotification(notificationId, validAlarmTime, intervalInHours: intervalInHours, title: title, body: body);
  }

  // Cerrar notificaciones
  static Future<void> cancelNotification(String notificationId) async {
    await flutterLocalNotificationsPlugin.cancel(generateNotificationId(notificationId));
  }

  static Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  // al tocar cualquier notificación
  static void onNotificationTap(NotificationResponse notificationResponse) {
    onClickNotification.add(notificationResponse.payload!);
  }

}




















