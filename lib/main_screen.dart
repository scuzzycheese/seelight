import 'dart:convert';

import 'package:SeeLight/status_screen.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'errors_and_warnings.dart';
import 'state.dart';
import 'package:logging/logging.dart';
import 'dart:async';
import 'dart:developer';
import 'package:SeeLight/watts_gauge.dart';
import 'package:SeeLight/cookie.dart';
import 'package:SeeLight/eightBall.dart';
import 'package:flutter/rendering.dart';

import 'package:charts_flutter/flutter.dart' as charts;

import 'package:percent_indicator/linear_percent_indicator.dart';

import 'package:SeeLight/log_screen.dart';

final _scaffoldKey = GlobalKey<ScaffoldState>();
final log = Logger("Main");
const int LOG_LENGTH = 10000;

class TimeSeriesWatts {
  final DateTime time;
  final int watts;

  TimeSeriesWatts(this.time, this.watts);
}

class MainScreenWidget extends StatefulWidget {
  @override
  _MainScreenWidgetState createState() => _MainScreenWidgetState();
}

class _MainScreenWidgetState extends State<MainScreenWidget> {
  Status _inverterStatus = Status.allZero();
  ErrorsAndWarnings _errorsAndWarnings = ErrorsAndWarnings.allFalse();


  void setStatus(Status status) {
    setState(() {
      _inverterStatus = status;
    });
  }

  void setErrorsAndWarnings(ErrorsAndWarnings errorsAndWarnings) {
    setState(() {
      _errorsAndWarnings = errorsAndWarnings;
      if (errorsAndWarnings.anyTrue()) {
        log.warning("Inverter returned an error: " + inspect(errorsAndWarnings));
      }
    });
  }

  //TODO: keep a rolling average for like 10 minutes, 1 hour etc.
  List<charts.Series<TimeSeriesWatts, DateTime>> _watts_timeseries = [
    charts.Series(
        id: "watts",
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeriesWatts watts, _) => watts.time,
        measureFn: (TimeSeriesWatts watts, _) => watts.watts,
        data: []
    ),
  ];

  List<charts.Series<TimeSeriesWatts, DateTime>> _watts_pv_timeseries = [
    charts.Series(
        id: "watts",
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeriesWatts watts, _) => watts.time,
        measureFn: (TimeSeriesWatts watts, _) => watts.watts,
        data: []
    ),
  ];

  void addWatts(Status status) {
    setState(() {
      if(_watts_timeseries.last.data.length > 1440) {
        //Remove the last minute data point older than a day
        _watts_timeseries.last.data.removeRange(0, _watts_timeseries.last.data.length - 1440);
      }
      _watts_timeseries.last.data.add(TimeSeriesWatts(DateTime.now(), status.ac_output_watts));
    });
  }

  void addWattsPV(Status status) {
    setState(() {
      if(_watts_pv_timeseries.last.data.length > 1440) {
        //Remove the last minute data point older than a day
        _watts_pv_timeseries.last.data.removeRange(0, _watts_pv_timeseries.last.data.length - 1440);
      }
      _watts_pv_timeseries.last.data.add(TimeSeriesWatts(DateTime.now(), (status.pv_input_voltage * status.pv_input_current).toInt()));
    });
  }

  @override
  Future<void> initState() {
    super.initState();

    new Timer.periodic(
        new Duration(seconds: 2),
            (Timer t) {
          fetchStatus().then((value) {
            setStatus(value);
          });
          fetchErrorsAndWarnings().then((value) {
            setErrorsAndWarnings(value);
          });
        }
    );

    new Timer.periodic(
        new Duration(minutes: 1),
           (Timer t) {
              addWatts(_inverterStatus);
              addWattsPV(_inverterStatus);
           }
    );

    Logger.root.level = Level.WARNING;
    Logger.root.onRecord.listen((record) {
      print("${record.time} - [${record.level.name}]: ${record.message}\n");
      if(globalLog.length > LOG_LENGTH) {
        globalLog = globalLog.replaceRange(0, globalLog.length - LOG_LENGTH, "...\n");
      }
      globalLog += "${record.time} - [${record.level.name}]: ${record.message}\n";
    });

  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(75.0),
          child: AppBar(
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.power_settings_new_outlined)),
                // Tab(icon: Image(image: AssetImage("images/metrics_white.png"))),
                Tab(icon: Icon(Icons.assessment)),
                Tab(icon: Icon(Icons.security_outlined)),
                Tab(icon: Icon(Icons.icecream)),
              ],
            ),
            title: Text(
              'SeeLight',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        drawer: Drawer(
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                child: Text('Other Stuff'),
                decoration: BoxDecoration(
                  color: (Theme.of(context).brightness == Brightness.light) ? Colors.lightBlue : Colors.black38,
                ),
              ),
              ListTile(
                title: Text('Log'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LogScreen(),
                      ));
                },
              ),
              ListTile(
                title: Text('Toggle Dark Mode'),
                onTap: () {
                  setState(() {
                    DynamicTheme.of(context).setThemeData(Theme.of(context).brightness == Brightness.light ? ThemeData.dark() : ThemeData.light());
                  });
                  // Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text("Status"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        // builder: (context) => StatusScreen(_errorsAndWarnings.toMap()),
                        builder: (context) => StatusScreen(stateData: _errorsAndWarnings.toMap()),
                      ));
                }
              )
            ],
          ),
        ),
        body: TabBarView(
          children: [
            GridView.count(
              // Create a grid with 2 columns. If you change the scrollDirection to
              // horizontal, this produces 2 rows.
              crossAxisCount: 2,
              children: [
                GridView.count(crossAxisCount: 2, children: [
                  SeeLightGauge(
                    themeData: Theme.of(context),
                    gaugeValue: _inverterStatus.load_percent.toDouble(),
                    end: 100,
                    label: "Load %",
                  ),
                  SeeLightGauge(
                    themeData: Theme.of(context),
                    gaugeValue: _inverterStatus.inverter_heatsink_temp.toDouble(),
                    end: 100,
                    label: "Heatsink Temp",
                  ),
                  SeeLightGauge(
                    themeData: Theme.of(context),
                    gaugeValue: _inverterStatus.pv_input_current.toDouble(),
                    end: 100,
                    label: "Solar Current",
                  ),
                  SeeLightGauge(
                    themeData: Theme.of(context),
                    gaugeValue: _inverterStatus.pv_input_voltage.toDouble(),
                    end: 150,
                    label: "Solar Voltage",
                  ),
                  // Image(image: AssetImage('images/battery_black.png'), ),
                ]),
                Container(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        child: LinearPercentIndicator(
                          leading: Text("0  "),
                          trailing: Text("  100"),
                          center: Text("Battery " + _inverterStatus.battery_capacity_percent.toString() + " %"),
                          animation: false,
                          lineHeight: 20,
                          progressColor: Colors.green,
                          percent: (_inverterStatus.battery_capacity_percent / 100).toDouble(),
                        ),
                      ),
                      Container(
                          padding: const EdgeInsets.all(5),
                          alignment: Alignment.centerLeft,
                          child: Text("Battery Voltage: " + _inverterStatus.battery_voltage.toString() + "v",
                              textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                      Container(
                          padding: const EdgeInsets.all(5),
                          alignment: Alignment.centerLeft,
                          child: Text("Load: " + _inverterStatus.ac_output_watts.toString() + "W",
                              textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                      Container(
                          padding: const EdgeInsets.all(5),
                          alignment: Alignment.centerLeft,
                          child: Text("PV-Voltage: " + _inverterStatus.pv_input_voltage.toString() + "v",
                              textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                      Container(
                          padding: const EdgeInsets.all(5),
                          alignment: Alignment.centerLeft,
                          child: Text("PV-Current: " + _inverterStatus.pv_input_current.toString() + "A",
                              textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                      Container(
                          padding: const EdgeInsets.all(5),
                          alignment: Alignment.centerLeft,
                          child: Text("PV-Watts: " + (_inverterStatus.pv_input_current * _inverterStatus.pv_input_voltage).toString() + "W",
                              textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                      Container(
                          padding: const EdgeInsets.all(5),
                          alignment: Alignment.centerLeft,
                          child: Text(
                              "Battery Charge Current: " + _inverterStatus.battery_charging_current.toString() + "A",
                              textAlign: TextAlign.left,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                      Container(
                          padding: const EdgeInsets.all(5),
                          alignment: Alignment.centerLeft,
                          child: Text(
                              "Battery Discharge Current: " +
                                  _inverterStatus.battery_discharge_current.toString() +
                                  "A",
                              textAlign: TextAlign.left,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                    ],
                  ),
                ),
              ],
            ),
            GridView.count(crossAxisCount: 1, children: [
              Container(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Column(
                    children: [
                      Container(
                          padding: const EdgeInsets.all(5),
                          alignment: Alignment.center,
                          child: Text("Watt usage over 1 day.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                      Container(
                          padding: const EdgeInsets.all(10),
                          height: 200,
                          // width: 750,
                          child: charts.TimeSeriesChart(
                            _watts_timeseries,
                            //defaultRenderer: new charts.BarRendererConfig<DateTime>(),
                            animate: false,
                            customSeriesRenderers: [
                              charts.LineRendererConfig(customRendererId: "area", includeArea: true, stacked: true)
                            ],
                            defaultInteractions: false,
                            behaviors: [new charts.SelectNearest(), new charts.DomainHighlighter()],
                          )),
                      Container(
                          padding: const EdgeInsets.all(5),
                          alignment: Alignment.center,
                          child: Text("Watt produced (PV) over 1 day.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                      Container(
                          padding: const EdgeInsets.all(10),
                          height: 200,
                          // width: 750,
                          child: charts.TimeSeriesChart(
                            _watts_pv_timeseries,
                            //defaultRenderer: new charts.BarRendererConfig<DateTime>(),
                            animate: false,
                            customSeriesRenderers: [
                              charts.LineRendererConfig(customRendererId: "area", includeArea: true, stacked: true)
                            ],
                            defaultInteractions: false,
                            behaviors: [new charts.SelectNearest(), new charts.DomainHighlighter()],
                          )),
                    ],
                  ))
            ]),
            Icon(Icons.security_outlined),
            GridView.count(crossAxisCount: 2, children: [EightBallWidget(), CookieWidget()])
          ],
        ),
      ),
    );
  }
}




Future<Status> fetchStatus() async {
  try {
    final response = await http.get('http://192.168.0.122/api/status');

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, then parse the JSON.
      return Status.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          "Can't connect to inverter. HTTP Code: " + response.statusCode.toString() + " - " +
              response.body);
    }

  } on Exception catch(e) {
    showBottomSheetError("Something went wrong connecting to the inverter. Please check the log.");
    log.shout("Failed to fetch power information from inverter. " + e.toString());
    return Status.allZero();
  }
}

Future<ErrorsAndWarnings> fetchErrorsAndWarnings() async {
  try {
    final response = await http.get('http://192.168.0.122/api/errors_and_warnings');

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, then parse the JSON.
      return ErrorsAndWarnings.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          "Can't connect to inverter. HTTP Code: " + response.statusCode.toString() + " - " +
              response.body);
    }

  } on Exception catch(e) {
    showBottomSheetError("Something went wrong connecting to the inverter. Please check the log.");
    log.shout("Failed to fetch error and warning information from inverter. " + e.toString());
    return ErrorsAndWarnings.allFalse();
  }
}

void showBottomSheetError(String errorMessage) {
  showBottomSheet(errorMessage, Colors.red, "Acknowledge :( :(");
}
void showBottomSheetWarning(String errorMessage) {
  showBottomSheet(errorMessage, Colors.amber, "Acknowledge :(");
}

void showBottomSheet(String errorMessage, Color color, String dismissMessage) {
  //TODO: something so it doesn't keep showing the bottom sheet again and again
  _scaffoldKey.currentState.showBottomSheet<void>((BuildContext context) {
    return Container(
      height: 100,
      color: color,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(errorMessage),
            RaisedButton(
              child: Text(dismissMessage),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      ),
    );
  },
  );
}
