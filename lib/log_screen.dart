import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

String globalLog = "SeeLight Log.\n";

const int LOG_LENGTH = 10000;

class LogScreen extends StatefulWidget {
  @override
  _LogScreenState createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: Text("Log"),
      ),
      body: Column(
      // primary: false,
        children: [
          ButtonBar(
            mainAxisSize: MainAxisSize.min,
            children: [
              RaisedButton(
                  child: Text("Clear"),
                  onPressed: () {
                    setState(() {
                      globalLog = "";
                    });
                  }),
            ],
          ),
          Expanded(
              child: Container(
                  constraints: BoxConstraints.expand(),
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      primary: true,
                      scrollDirection: Axis.vertical,
                      reverse: true,
                      child: Text(globalLog,
                          textAlign: TextAlign.left,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ))),
        ]));

  }
}

