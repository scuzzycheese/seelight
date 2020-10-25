
import 'package:flutter/material.dart';
import 'package:flutter_gauge/flutter_gauge.dart';




class SeeLightGauge extends StatelessWidget {

  ThemeData themeData = ThemeData.light();
  double gaugeValue;
  int start;
  int end;
  String label;


  SeeLightGauge({this.themeData, this.gaugeValue, this.start = 0, this.end, this.label});

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        FlutterGauge(
            handSize: 10,
            index: gaugeValue,
            fontFamily: "Iran",
            start: start,
            end: end,
            number: Number.endAndCenterAndStart,
            numberInAndOut: NumberInAndOut.inside,
            counterAlign: CounterAlign.center,
            secondsMarker: SecondsMarker.all,
            isCircle: false,
            hand: Hand.short,
            handColor: (themeData == ThemeData.dark()) ? Colors.white : Colors.black,
            circleColor: (themeData == ThemeData.dark()) ? Colors.white : Colors.black,
            inactiveColor: (themeData == ThemeData.dark()) ? Colors.white : Colors.black,
            counterStyle: TextStyle(
              color: (themeData == ThemeData.dark()) ? Colors.white : Colors.black,
              fontSize: 25,
            )),
        Center(
          child: Container(
              alignment: Alignment(0.0, 0.60),
              child: Text(
                label,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              )),
        ),
      ],
    );
  }
}
