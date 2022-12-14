import 'dart:async';
import 'dart:io';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class TaskInfo {
  String _currentTime = '';
  int _batteryLevel = 0;
  BatteryState? _batteryState;
  String _wifi = '';
  String _internet = '';

  String get currentTime => _currentTime;
  int get batteryLevel => _batteryLevel;
  BatteryState? get batteryState => _batteryState;
  String get wifi => _wifi;
  String get internet => _internet;

  late List<String> info = [
    _currentTime,
    _batteryLevel.toString(),
    _batteryState.toString(),
    _wifi,
    _internet,
  ];

  getTime() {
    DateTime now = DateTime.now();
    String convertedDateTime =
        "${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year.toString()} ${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}-${now.second.toString().padLeft(2, '0')}";
    _currentTime = convertedDateTime;
  }

  batteryInfo() async {
    final Battery battery = Battery();
    StreamSubscription<BatteryState>? batteryStateSubscription;
    batteryStateSubscription =
        battery.onBatteryStateChanged.listen((BatteryState state) {
      _batteryState = state;
    });

    final level = await battery.batteryLevel;
    _batteryLevel = level;
  }

  checkConnect() async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.wifi) {
      _wifi = "Wi-Fi з'єднано";
    } else {
      _wifi = "не з'єднано";
    }
  }

  checkInternet() async {
    final client = http.Client();
    final uri = Uri.parse('https://www.facebook.com/');

    try {
      final response =
          await client.get(uri).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        _internet = "з'єднання є";
      }
    } on SocketException {
      _internet = "з'єднання немає";
    } on TimeoutException {
      _internet = "з'єднання немає";
    } on Error {
      _internet = "з'єднання немає";
    }
  }
}
