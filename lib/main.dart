import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/notification_services.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'staticVars.dart';

// ignore: non_constant_identifier_names
//final FlutterLocalNotificationsPlugin = flutterLocalNotificationsPlugin;

void main() => runApp(MyApp());

Future showNotification() async {
  int IndexNotification =
      Random().nextInt(StaticVars().listaEstatic.length - 1);

  AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    '$IndexNotification.0',
    'HELLO',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
  );
  var platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    IndexNotification,
    'Soy una notificacion',
    StaticVars().listaEstatic[IndexNotification],
    platformChannelSpecifics,
  );
}

const simpleTaskKey = "be.tramckrijte.workmanagerExample.simpleTask";
@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  var initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  var initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  WidgetsFlutterBinding.ensureInitialized();

  flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );

  Workmanager().executeTask((task, inputData) async {
    showNotification();
    return Future.value(true);
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

//Calcula el tiempo
int calculateRemainTimeInSeconds(String horaInicial) {
  DateTime _now = DateTime.now();
  int _nowInSeconds = _now.hour * 3600 + _now.minute * 60 + _now.second;
  //segundos sumados
  List<String> untilTime = horaInicial.split(":");

  int hour = int.parse(untilTime[0]);
  int minute = int.parse(untilTime[1]);

  print("**********************HORA/MINUTO*************************");
  print("THIS IS HOUR >> $hour");
  print("THIS IS MINUTES >> $minute");
  int _thenInSeconds = hour * 3600 + minute * 60;
  return _thenInSeconds - _nowInSeconds;
}

List list = [
  {
    "v_hora_inicial": "15:00",
    "v_hora_final": "16:00",
    "v_num_dia": 2,
    "v_dia": "Martes"
  },
  {
    "v_hora_inicial": "16:00",
    "v_hora_final": "17:00",
    "v_num_dia": 5,
    "v_dia": "Viernes"
  }
];

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final List<String> horaInicial =
        list.map((h) => h["v_hora_inicial"].toString()).toList();
//Take time local//

    DateTime dateNow = DateTime.now();
    String timer = "${dateNow.hour}:${dateNow.minute + 1}";
    print("timer >> $timer");
    int valor = calculateRemainTimeInSeconds(timer);
    print("valor >> $valor");

//Initialize Workmanager Default notification
    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );
    /*Workmanager().registerOneOffTask(
      "1",
      "notify_15_minutes_before_hour",
      initialDelay: Duration(seconds: valor),
    );*/

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Flutter WorkManager Example"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  "Plugin initialization",
                  style: Theme.of(context).textTheme.headline5,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                    child: Text("Register Delayed OneOff Task"),
                    onPressed: () {
                      Workmanager().registerOneOffTask(
                        "1",
                        "notify_15_minutes_before_hour",
                        initialDelay: Duration(seconds: valor),
                      );
                    }),
                SizedBox(height: 16),
                Text(
                  "Task cancellation",
                  style: Theme.of(context).textTheme.headline5,
                ),
                ElevatedButton(
                  child: Text("Cancel All"),
                  onPressed: () async {
                    await Workmanager().cancelAll();
                    print('Cancel all tasks completed');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
