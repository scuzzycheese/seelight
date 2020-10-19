//I might be able to populate this with serialization rather.
import 'package:json_annotation/json_annotation.dart';

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
}