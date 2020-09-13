import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:SeeLight/watts_gauge.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:charts_flutter/flutter.dart' as charts;

import 'package:flutter_gauge/flutter_gauge.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:bezier_chart/bezier_chart.dart';

void main() {

  String key = "APPLICATION KEY - http://theworst.zapto.org/key/230.pdf.gpg";
  print("Key location: " + key);

  runApp(SeeLightMainWidget());
}

class SeeLightMainWidget extends StatefulWidget {
  @override
  _SeeLightMainWidget createState() => _SeeLightMainWidget();
}


class TimeSeriesWatts {
  final DateTime time;
  final int watts;

  TimeSeriesWatts(this.time, this.watts);
}

class _SeeLightMainWidget extends State<SeeLightMainWidget> {
  Status _inverterStatus = Status.allZero();
  bool _darkMode = false;
  ThemeData _themeMode = ThemeData.light();

  List<TimeSeriesWatts> _timeseries_watts = [];

  List<charts.Series<TimeSeriesWatts, DateTime>> _watts_timeseries = [
    charts.Series(
      id: "watts",
      colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      domainFn: (TimeSeriesWatts watts, _) => watts.time,
      measureFn: (TimeSeriesWatts watts, _) => watts.watts,
      data: []
    ),
  ];

  void setStatus(Status status) {
    setState(() {
      _inverterStatus = status;
    });
  }

  void addWatts(Status status) {
    setState(() {
      _watts_timeseries.last.data.add(
        TimeSeriesWatts(DateTime.now(), status.ac_output_watts)
      );

      if(_timeseries_watts.length >= 1440) {
        //Remove the last minute data point older than a day
        _timeseries_watts.removeAt(0);
      }
      _timeseries_watts.add(TimeSeriesWatts(DateTime.now(), _inverterStatus.ac_output_watts));
    });
  }

  @override
  Future<void> initState() {
    super.initState();

    new Timer.periodic(
        new Duration(seconds: 2),
        (Timer t) => {
              fetchStatus().then((value) {
                setStatus(value);
              })
            });


    new Timer.periodic(
        new Duration(minutes: 1),
            (Timer t) => {
          fetchStatus().then((value) {
            addWatts(value);
          })
        });

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _themeMode,
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(75.0),
            child: Stack(children: [
              AppBar(
                bottom: TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.power_settings_new_outlined)),
                    Tab(icon: Image(image: AssetImage("images/metrics_white.png"))),
                    Tab(icon: Icon(Icons.security_outlined)),
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

Future<Status> fetchStatus() async {
  final response = await http.get('http://theworst.zapto.org/api/status');

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response, then parse the JSON.
    return Status.fromJson(json.decode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to power information from inverter');
  }
}
