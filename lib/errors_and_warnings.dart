import 'package:flutter/animation.dart';

class ErrorsAndWarnings {

  final bool inverter_fault;
  final bool bus_over_fault;
  final bool bus_under_fault;
  final bool bus_soft_fail_fault;
  final bool line_fail_warning;
  final bool opv_short_warning;
  final bool inverter_voltage_too_low_fault;
  final bool inverter_voltage_too_high_fault;
  final bool over_temperature;
  final bool fan_locked;
  final bool battery_voltage_high;
  final bool battery_low_alarm_warning;
  final bool battery_under_shutdown_warning;
  final bool overload;
  final bool eeprom_fault_warning;
  final bool inverter_over_current_fault;
  final bool inverter_soft_fail_fault;
  final bool self_test_fail_fault;
  final bool op_dc_voltage_over_fault;
  final bool bat_open_fault;
  final bool current_sensor_fail_fault;
  final bool battery_short_fault;
  final bool power_limit_warning;
  final bool pv_voltage_high_warning;
  final bool mppt_overload_fault_1;
  final bool mppt_overload_warning_1;
  final bool battery_too_low_to_charge;



  ErrorsAndWarnings(
      this.inverter_fault,
      this.bus_over_fault,
      this.bus_under_fault,
      this.bus_soft_fail_fault,
      this.line_fail_warning,
      this.opv_short_warning,
      this.inverter_voltage_too_low_fault,
      this.inverter_voltage_too_high_fault,
      this.over_temperature,
      this.fan_locked,
      this.battery_voltage_high,
      this.battery_low_alarm_warning,
      this.battery_under_shutdown_warning,
      this.overload,
      this.eeprom_fault_warning,
      this.inverter_over_current_fault,
      this.inverter_soft_fail_fault,
      this.self_test_fail_fault,
      this.op_dc_voltage_over_fault,
      this.bat_open_fault,
      this.current_sensor_fail_fault,
      this.battery_short_fault,
      this.power_limit_warning,
      this.pv_voltage_high_warning,
      this.mppt_overload_fault_1,
      this.mppt_overload_warning_1,
      this.battery_too_low_to_charge);


  factory ErrorsAndWarnings.allFalse() {
    return ErrorsAndWarnings(
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
      false,
    );
  }

  factory ErrorsAndWarnings.fromJson(Map<String, dynamic> json) {
    return ErrorsAndWarnings(
        json['inverter_fault'],
        json['bus_over_fault'],
        json['bus_under_fault'],
        json['bus_soft_fail_fault'],
        json['line_fail_warning'],
        json['opv_short_warning'],
        json['inverter_voltage_too_low_fault'],
        json['inverter_voltage_too_high_fault'],
        json['over_temperature'],
        json['fan_locked'],
        json['battery_voltage_high'],
        json['battery_low_alarm_warning'],
        json['battery_under_shutdown_warning'],
        json['overload'],
        json['eeprom_fault_warning'],
        json['inverter_over_current_fault'],
        json['inverter_soft_fail_fault'],
        json['self_test_fail_fault'],
        json['op_dc_voltage_over_fault'],
        json['bat_open_fault'],
        json['current_sensor_fail_fault'],
        json['battery_short_fault'],
        json['power_limit_warning'],
        json['pv_voltage_high_warning'],
        json['mppt_overload_fault_1'],
        json['mppt_overload_warning_1'],
        json['battery_too_low_to_charge'],
    );
  }

}