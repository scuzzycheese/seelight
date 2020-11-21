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


  bool anyTrue() {
    if(this.inverter_fault) return true;
    if(this.bus_over_fault) return true;
    if(this.bus_under_fault) return true;
    if(this.bus_soft_fail_fault) return true;
    if(this.line_fail_warning) return true;
    if(this.opv_short_warning) return true;
    if(this.inverter_voltage_too_low_fault) return true;
    if(this.inverter_voltage_too_high_fault) return true;
    if(this.over_temperature) return true;
    if(this.fan_locked) return true;
    if(this.battery_voltage_high) return true;
    if(this.battery_low_alarm_warning) return true;
    if(this.battery_under_shutdown_warning) return true;
    if(this.overload) return true;
    if(this.eeprom_fault_warning) return true;
    if(this.inverter_over_current_fault) return true;
    if(this.inverter_soft_fail_fault) return true;
    if(this.self_test_fail_fault) return true;
    if(this.op_dc_voltage_over_fault) return true;
    if(this.bat_open_fault) return true;
    if(this.current_sensor_fail_fault) return true;
    if(this.battery_short_fault) return true;
    if(this.power_limit_warning) return true;
    if(this.pv_voltage_high_warning) return true;
    if(this.mppt_overload_fault_1) return true;
    if(this.mppt_overload_warning_1) return true;
    if(this.battery_too_low_to_charge ) return true;
    return false;
  }

  Map<String, bool> toMap() {
    return {
      "Overload": this.overload,
      "Bus Over Fault": this.bus_over_fault,
      "Power Limit Warning": this.power_limit_warning,
      "EEPROM Fault Warning": this.eeprom_fault_warning,
      "Inverter Over Current Fault": this.inverter_over_current_fault,
      "Batter Under Shutdown Warning": this.battery_under_shutdown_warning,
      "Battery Low Alarm Warning": this.battery_low_alarm_warning,
      "MPPT Overload Fault": this.mppt_overload_fault_1,
      "Battery Short Fault": this.battery_short_fault,
      "Over Termperature": this.over_temperature,
      "Line Fail Warning": this.line_fail_warning,
      "OPV Short Warning": this.opv_short_warning,
      "Fan Locked": this.fan_locked,
      "Battery Open Fault": this.bat_open_fault,
      "Bus Soft Fail Fault": this.bus_soft_fail_fault,
      "Self Test Fail Fault": this.self_test_fail_fault,
      "Battery Voltage High": this.battery_voltage_high,
      "MPPT Overload Warning": this.mppt_overload_warning_1,
      "Current Sensor Fail Fault": this.current_sensor_fail_fault,
      "PV Voltage High Warning": this.pv_voltage_high_warning,
      "OP DC Voltage Over Fault": this.op_dc_voltage_over_fault,
      "Inverter Voltage Too Low Fault": this.inverter_voltage_too_low_fault,
      "Inverter Votlage Too High Fault": this.inverter_voltage_too_high_fault,
      "Inverter Soft Fail Fault": this.inverter_soft_fail_fault,
      "Battery too low to charge": this.battery_too_low_to_charge,
      "Bus Under Fault": this.bus_under_fault,
      "Inverter Fault": this.inverter_fault,
    };
  }

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