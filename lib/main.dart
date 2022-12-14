import 'dart:async';
import 'package:blackout_track/database.dart';
import 'package:blackout_track/task_info.dart';
import 'package:blackout_track/ui.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'firebase_options.dart';

const task = 'blackoutTask';

TaskInfo taskInfo = TaskInfo();
DatabaseService db = DatabaseService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: const MainScreen(title: 'Blackout Tracker'),
    );
  }
}

Future _doTheWork() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  await taskInfo.getTime();
  await taskInfo.batteryInfo();
  await taskInfo.checkConnect();
  await taskInfo.checkInternet();

  prefs.setStringList(taskInfo.currentTime, taskInfo.info);

  if (taskInfo.internet == "з'єднання є") {
    await Firebase.initializeApp();
    await db.addOrUpdateInfo();
  }
}

void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    switch (taskName) {
      case 'blackoutTask':
        await _doTheWork();
        break;
      default:
    }
    return Future.value(true);
  });
}
