import 'package:flutter/material.dart';

class StatusScreen extends StatefulWidget {

 Map<String, bool> stateData;


 StatusScreen({this.stateData});

  @override
  _StatusScreenState createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Status"),
        ),
        // body: RoundGraph());
      body: CustomPaint(painter: StatusPainter(context, widget.stateData), child: Container()));
  }
}


class StatusPainter extends CustomPainter {

  BuildContext context;
  Map<String, bool> _state_data;
  StatusPainter(this.context, this._state_data);

  final _textPainter = TextPainter(textDirection: TextDirection.ltr);

  @override
  void paint(Canvas canvas, Size size) {

    final center = Offset(size.width / 2, size.height / 2);


    //Just to test what it looks like with an error
    // _state_data["Power Limit Warning"] = true;

    double rotation = degreesToRadians(295);
    final double _rotation_step = degreesToRadians(325 / _state_data.length);
    final double unit = size.height / 8;

    Rect rect = Rect.fromCenter(center: center, width: unit * 3, height: unit * 3);

    canvas.save();
    canvas.drawArc(rect, degreesToRadians(285), degreesToRadians(330), false, Paint()..color = Colors.black.withOpacity(0.5)..style = PaintingStyle.stroke..strokeWidth = unit..maskFilter = MaskFilter.blur(BlurStyle.normal, 10.0));
    canvas.drawArc(rect, degreesToRadians(285), degreesToRadians(330), false, Paint()..color = (Theme.of(context).brightness == Brightness.light ? ThemeData.light().canvasColor : ThemeData.dark().canvasColor)..style = PaintingStyle.stroke..strokeWidth = unit);

    canvas.drawArc( Rect.fromCenter(center: center, width: unit * 2.4, height: unit * 2.4), degreesToRadians(285), degreesToRadians(330), false, Paint()..color = Colors.grey.withOpacity(0.2) .. strokeWidth = 1 .. style = PaintingStyle.stroke);
    canvas.drawArc( Rect.fromCenter(center: center, width: unit * 3.6, height: unit * 3.6), degreesToRadians(285), degreesToRadians(330), false, Paint()..color = Colors.grey.withOpacity(0.2) .. strokeWidth = 1 .. style = PaintingStyle.stroke);
    canvas.restore();

    //Pant the Error tag
    TextPainter textPainterError = buildTextPainter("Error", size);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(degreesToRadians(270));
    canvas.translate(unit * 1.85, 0);
    canvas.rotate(degreesToRadians(90));
    textPainterError.paint(canvas, Offset(-(textPainterError.width / 2), 0));
    canvas.restore();

    //Pant the Error tag
    TextPainter textPainterOk = buildTextPainter("Ok", size);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(degreesToRadians(270));
    canvas.translate(unit * 1.25, 0);
    canvas.rotate(degreesToRadians(90));
    textPainterOk.paint(canvas, Offset(-(textPainterOk.width / 2), 0));
    canvas.restore();

    _state_data.forEach((stname, stvalue) {
    // for(var stname in _status_names) {
      TextPainter textPainter = buildTextPainter(stname, size);

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rotation);
      canvas.translate(unit * 2.1, 0);

      canvas.drawLine(Offset(-unit * 0.2, 0), Offset(-unit, 0), Paint()..color = Colors.grey.withOpacity(0.2) .. strokeWidth = 1 .. style = PaintingStyle.stroke);
      if(stvalue) {
        canvas.drawCircle(Offset(-unit * 0.3, 0), 6, Paint()
          ..color = Colors.red.shade200);
      } else {
        canvas.drawCircle(Offset(-unit * 0.9, 0), 6, Paint()
          ..color = Colors.green.shade200);
      }
      if(rotation > degreesToRadians(450)) {
        canvas.rotate(degreesToRadians(180));
        canvas.translate(-textPainter.width, 0);
        textPainter.paint(canvas, Offset(0, -(textPainter.height / 2)));
      } else {
        textPainter.paint(canvas, Offset(0, -(textPainter.height / 2)));
      }

      canvas.restore();
      rotation += _rotation_step;
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  TextPainter buildTextPainter(String text, Size size) {
    final textStyle = TextStyle(
      color: (Theme.of(context).brightness == Brightness.light ? Colors.black87 : Colors.white70),
      fontSize: 10,
    );

    final textSpan = TextSpan(
      text: text,
      style: textStyle,
    );
    final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    return textPainter;
  }


  double radianToDegrees(double radians) {
    return radians * 57.295779513082321;
  }

  double degreesToRadians(double degrees) {
    return degrees * 0.017453292519943;
  }

}
