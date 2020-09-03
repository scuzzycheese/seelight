import 'dart:async';
import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:charts_flutter/flutter.dart' as charts;

import 'package:flutter_gauge/flutter_gauge.dart';

void main() {
  runApp(SeeLightMainWidget());
}

class SeeLightMainWidget extends StatefulWidget {
  @override
  _SeeLightMainWidget createState() => _SeeLightMainWidget();
}

class _SeeLightMainWidget extends State<SeeLightMainWidget> {
  Status _inverterStatus;

  void setStatus(Status status) {
    setState(() {
      _inverterStatus = status;
    });
  }

  @override
  Future<void> initState() {
    super.initState();

    new Timer.periodic(
        new Duration(seconds: 2),
        (Timer t) => {
              fetchStatus().then((value) {
//        print("watts: " + value.ac_output_watts.toString());
                setStatus(value);
              })
            });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(75.0),
            child: AppBar(
              bottom: TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.power_settings_new_outlined)),
                  Tab(icon: Icon(Icons.security_outlined)),
                ],
              ),
              title: Text('SeeLight'),
            ),
          ),
          body: TabBarView(
            children: [
              GridView.count(
                // Create a grid with 2 columns. If you change the scrollDirection to
                // horizontal, this produces 2 rows.
                crossAxisCount: 2,
                children: [
                  Text("hello"),
                  Stack(
                    children: [
                      Positioned(
                          child: FlutterGauge(
                              handSize: 10,
                              circleColor: Colors.blueAccent,
                              index: _inverterStatus.load_percent.toDouble(),
                              fontFamily: "Iran",
                              end: 100,
                              number: Number.endAndCenterAndStart,
                              numberInAndOut: NumberInAndOut.inside,
                              counterAlign: CounterAlign.center,
                              secondsMarker: SecondsMarker.secondsAndMinute,
                              isCircle: false,
                              hand: Hand.short,
                              counterStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 25,
                              )),
                      ),
                      Center(
                        child: Container(

                            alignment: Alignment(0.0, 0.3),
                            child: Text(
                              "Load %",
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                            )
                        ),


                      ),
                    ],
                  )
                ],
              ),
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

  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(
        json['ac_input_voltage'],
        json['ac_input_frequency'],
        json['ac_output_voltage'],
        json['ac_output_frequency'],
        json['ac_output_va'],
        json['ac_output_watts'],
        json['load_percent'],
        json['bus_voltage§'],
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
  final response = await http.get('http://192.168.0.122/status');

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response, then parse the JSON.
    return Status.fromJson(json.decode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to power information from inverter');
  }
}
