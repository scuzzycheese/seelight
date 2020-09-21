import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:SeeLight/watts_gauge.dart';
import 'package:SeeLight/eightBall.dart';
import 'package:flutter/rendering.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:logging/logging.dart';

import 'package:percent_indicator/linear_percent_indicator.dart';


final log = Logger("Main");
const int LOG_LENGTH = 10000;
final _scaffoldKey = GlobalKey<ScaffoldState>();

class TimeSeriesWatts {
  final DateTime time;
  final int watts;

  TimeSeriesWatts(this.time, this.watts);
}

void main() {
  runApp(SeeLightMainWidget());
}

class SeeLightMainWidget extends StatefulWidget {
  @override
  _SeeLightMainWidget createState() => _SeeLightMainWidget();
}

class _SeeLightMainWidget extends State<SeeLightMainWidget> {
  Status _inverterStatus = Status.allZero();
  bool _darkMode = false;
  ThemeData _themeMode = ThemeData.light();
  String _log = "SeeLight Log.\n";


  void setStatus(Status status) {
    setState(() {
      _inverterStatus = status;
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

  void addWatts(Status status) {
    setState(() {
      if(_watts_timeseries.length >= 1440) {
        //Remove the last minute data point older than a day
        _watts_timeseries.removeAt(0);
      }
      _watts_timeseries.last.data.add(TimeSeriesWatts(DateTime.now(), status.ac_output_watts));
    });
  }

  @override
  Future<void> initState() {
    super.initState();

    new Timer.periodic(
        new Duration(seconds: 2), (Timer t) =>
        {
          fetchStatus().then((value) {
            setStatus(value);
          })
        });

    new Timer.periodic(
        new Duration(minutes: 1),
            (Timer t) =>
            addWatts(_inverterStatus)
    );

    Logger.root.level = Level.WARNING;
    Logger.root.onRecord.listen((record) {
      if(_log.length > LOG_LENGTH) {
        _log = _log.replaceRange(0, _log.length - LOG_LENGTH, "...\n");
      }
      _log += "${record.time} - [${record.level.name}]: ${record.message}\n";
    });

  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _themeMode,
      home: DefaultTabController(
        length: 5,
        child: Scaffold(
          key: _scaffoldKey,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(75.0),
            child: Stack(children: [
              AppBar(
                bottom: TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.power_settings_new_outlined)),
                    // Tab(icon: Image(image: AssetImage("images/metrics_white.png"))),
                    Tab(icon: Icon(Icons.assessment)),
                    Tab(icon: Icon(Icons.security_outlined)),
                    Tab(icon: Icon(Icons.subject)),
                    Tab(icon: Icon(Icons.icecream)),
                  ],
                ),
                title: Text(
                  'SeeLight',
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                alignment: Alignment.centerRight,
                child: Switch(
                    value: _darkMode,
                    onChanged: (bool newValue) {
                      setState(
                        () {
                          _themeMode = (_themeMode == ThemeData.dark()) ? ThemeData.light() : ThemeData.dark();
                          _darkMode = newValue;
                        },
                      );
                    }),
              ),
            ]),
          ),
          body: TabBarView(
            children: [
              GridView.count(
                // Create a grid with 2 columns. If you change the scrollDirection to
                // horizontal, this produces 2 rows.
                crossAxisCount: 2,
                children: [
                  GridView.count(crossAxisCount: 2, children: [
                    SeeLightGauge( themeMode: _themeMode, gaugeValue: _inverterStatus.load_percent.toDouble(), end: 100, label: "Load %", ),
                    SeeLightGauge( themeMode: _themeMode, gaugeValue: _inverterStatus.pv_input_current.toDouble(), end: 100, label: "Solar Current", ),
                    SeeLightGauge( themeMode: _themeMode, gaugeValue: _inverterStatus.pv_input_voltage.toDouble(), end: 100, label: "Solar Voltage", ),
                    SeeLightGauge( themeMode: _themeMode, gaugeValue: _inverterStatus.inverter_heatsink_temp.toDouble(), end: 100, label: "Heatsink Temp", ),
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
                            percent: (_inverterStatus.battery_capacity_percent / 100 ).toDouble(),
                          ),
                        ),
                        Container(
                            padding: const EdgeInsets.all(5),
                            alignment: Alignment.centerLeft,
                            child: Text("Battery Voltage: " + _inverterStatus.battery_voltage.toString() + "v",
                                textAlign: TextAlign.left,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                        Container(
                            padding: const EdgeInsets.all(5),
                            alignment: Alignment.centerLeft,
                            child: Text("Load: " + _inverterStatus.ac_output_watts.toString() + "W",
                                textAlign: TextAlign.left,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                        Container(
                            padding: const EdgeInsets.all(5),
                            alignment: Alignment.centerLeft,
                            child: Text("Battery Charge Current: " + _inverterStatus.battery_charging_current.toString() + "A",
                                textAlign: TextAlign.left,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                        Container(
                            padding: const EdgeInsets.all(5),
                            alignment: Alignment.centerLeft,
                            child: Text("Battery Discharge Current: " + _inverterStatus.battery_discharge_current.toString() + "A",
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
                          child: Text("Watts over 1 day.",
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
                              charts.LineRendererConfig(
                                customRendererId: "area",
                                includeArea: true,
                                stacked: true
                              )
                            ],
                            defaultInteractions: false,
                            behaviors: [new charts.SelectNearest(), new charts.DomainHighlighter()],
                          )
                      ),

                    ],
                  )
                )
              ]),
              Icon(Icons.security_outlined),
              Column(
                  // primary: false,
                  children: [
                    ButtonBar(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RaisedButton(child: Text("Clear"), onPressed: () {
                          setState(() {
                            _log = "";
                          });
                        }),
                      ],
                    ),
                    Expanded(child:
                    Container(
                        constraints: BoxConstraints.expand(),
                        child: Scrollbar(
                          child: SingleChildScrollView(
                            primary: true,
                            scrollDirection: Axis.vertical,
                            reverse: true,
                            child: Text(_log,
                                textAlign: TextAlign.left, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          ),
                        ))),
                  ]),
              EightBallWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

//I might be able to populate this with serialization rather.
@JsonSerializable()
class Status {

  final double ac_input_voltage;
  final double ac_input_frequency;
  final double ac_output_voltage;
  final double ac_output_frequency;
  final int ac_output_va;
  final int ac_output_watts;
  final int load_percent;
  final int bus_voltage;
  final double battery_voltage;
  final int battery_charging_current;
  final int battery_capacity_percent;
  final int inverter_heatsink_temp;
  final int pv_input_current;
  final double pv_input_voltage;
  final double battery_voltage_from_scc;
  final int battery_discharge_current;

  Status(
      this.ac_input_voltage,
      this.ac_input_frequency,
      this.ac_output_voltage,
      this.ac_output_frequency,
      this.ac_output_va,
      this.ac_output_watts,
      this.load_percent,
      this.bus_voltage,
      this.battery_voltage,
      this.battery_charging_current,
      this.battery_capacity_percent,
      this.inverter_heatsink_temp,
      this.pv_input_current,
      this.pv_input_voltage,
      this.battery_voltage_from_scc,
      this.battery_discharge_current);

  factory Status.allZero() {
    return Status(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
  }

  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(
        json['ac_input_voltage'],
        json['ac_input_frequency'],
        json['ac_output_voltage'],
        json['ac_output_frequency'],
        json['ac_output_va'],
        json['ac_output_watts'],
        json['load_percent'],
        json['bus_voltage'],
        json['battery_voltage'],
        json['battery_charging_current'],
        json['battery_capacity_percent'],
        json['inverter_heatsink_temp'],
        json['pv_input_current'],
        json['pv_input_voltage'],
        json['battery_voltage_from_scc'],
        json['battery_discharge_current']);
  }

//  factory Status.fromJson(Map<String, dynamic> json) => _$StatusFromJson(json);
//  Map<String, dynamic> toJson() => _$StatusFromnJson(this);

}


//TODO: fetchErrorStatus

Future<Status> fetchStatus() async {
    try {
      final response = await http.get('http://theworst.zapto.org/api/status');

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
