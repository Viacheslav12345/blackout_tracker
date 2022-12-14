import 'package:blackout_track/main.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.title});

  final String title;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late Future<List<List<String>>> _listFuture;

  @override
  void initState() {
    super.initState();
    _listFuture = _loadInfo();
    _startWorkManager();
  }

  void refreshList() {
    // reload
    setState(() {
      _listFuture = _loadInfo();
    });
  }

  _startWorkManager() async {
    await Workmanager().registerPeriodicTask(taskInfo.currentTime, task,
        frequency: const Duration(hours: 1),
        existingWorkPolicy: ExistingWorkPolicy.replace);
    await Future.delayed(const Duration(seconds: 2));
    refreshList();
  }

  _stopWorkManager() async {
    await Workmanager().cancelAll();
  }

  _clearHistoryInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await db.deleteAllInfo();
    await prefs.clear();
    refreshList();
  }

  Future<List<List<String>>> _loadInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final List<String> keys = prefs.getKeys().toList();
    keys.sort();
    final List<List<String>> prefsList = [];

    for (String key in keys.reversed) {
      prefsList.add(prefs.getStringList(key) as List<String>);
    }
    return prefsList;
  }

  @override
  Widget build(BuildContext context) {
    List<String> dataType = [
      'Дата та час',
      'Рівень заряду',
      'Статус зарядки',
      "Wi-Fi",
      'Інтернет',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: FutureBuilder<List<List<String>>>(
            future: _listFuture,
            builder: (context, future) {
              if (future.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (future.hasError) {
                return Text('Error: ${future.error}');
              } else {
                List<List<String>> list = future.data ?? [];
                return Scrollbar(
                    child: RefreshIndicator(
                  onRefresh: () async {
                    await Future.delayed(const Duration(seconds: 2));
                    refreshList();
                  },
                  child: ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          elevation: 20,
                          shadowColor: Colors.black,
                          color: Colors.blueGrey[200],
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                for (int i = 0;
                                    i < list.elementAt(index).length;
                                    i++)
                                  Row(
                                    children: [
                                      Text(
                                        dataType.elementAt(i),
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.green[900],
                                          fontWeight: FontWeight.w500,
                                        ), //Textstyle
                                      ),
                                      const SizedBox(
                                        width: 40,
                                      ), //Text
                                      Expanded(
                                        child: Text(
                                          ((list
                                                      .elementAt(index)
                                                      .elementAt(i) ==
                                                  'BatteryState.discharging')
                                              ? 'не заряджається'
                                              : list
                                                  .elementAt(index)
                                                  .elementAt(i)),
                                          textAlign: TextAlign.end,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: ((list
                                                            .elementAt(index)
                                                            .elementAt(i) ==
                                                        'BatteryState.discharging' ||
                                                    list
                                                            .elementAt(index)
                                                            .elementAt(i) ==
                                                        "з'єднання немає" ||
                                                    list
                                                            .elementAt(index)
                                                            .elementAt(i) ==
                                                        "не з'єднано" ||
                                                    (dataType.elementAt(i) ==
                                                            'Рівень заряду' &&
                                                        int.parse(list
                                                                .elementAt(
                                                                    index)
                                                                .elementAt(
                                                                    i)) <=
                                                            30)
                                                ? const Color.fromARGB(
                                                    255, 158, 27, 4)
                                                : const Color.fromARGB(
                                                    255, 24, 74, 26))),
                                          ), //Textstyle
                                        ),
                                      ), //Text
                                    ],
                                  ),
                              ],
                            ), //Column
                          ), //SizedBox
                        );
                      }),
                ));
              }
            }),
      ),
      persistentFooterButtons: <Widget>[
        FloatingActionButton(
          backgroundColor: const Color.fromARGB(255, 116, 154, 150),
          onPressed: () {
            _startWorkManager();
          },
          tooltip: 'Start tracker',
          child: const Icon(size: 40, Icons.play_arrow),
        ),
        FloatingActionButton(
          backgroundColor: const Color.fromARGB(255, 185, 143, 140),
          onPressed: () {
            _stopWorkManager();
          },
          tooltip: 'Stop tracker',
          child: const Icon(
            size: 40,
            Icons.stop,
          ),
        ),
        const SizedBox(width: 140),
        FloatingActionButton(
          backgroundColor: const Color.fromARGB(255, 230, 101, 97),
          onPressed: () {
            _clearHistoryInfo();
          },
          tooltip: 'Clear history',
          child: const Icon(size: 40, Icons.delete_forever),
        ),
        const SizedBox(width: 15),
      ],
    );
  }
}
