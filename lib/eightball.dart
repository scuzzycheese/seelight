import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

final theWorstAnswers = ['', '¯\\_(ツ)_/¯','Sure!', 'Sure.', 'Sure...\nSure', '"Sure"', 'Sure?',':)'];

class EightBallWidget extends StatefulWidget {
  @override
  _EightBallWidget createState() => _EightBallWidget();
}

class _EightBallWidget extends State<EightBallWidget> {
  String theWorstAnswer = theWorstAnswers[0];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child:
        Scaffold(
          body: Center(
            child: 
              Column(
                children: 
                  <Widget>[
                    Container(
                        margin: const EdgeInsets.only(top: 40.0),
                        alignment: Alignment.center,
                        child:
                        Text(
                          'Ask me anything!',
                          style: 
                            TextStyle(
                              color: Colors.grey[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 20)
                          )
                    ),
                    GestureDetector(
                      onTap: ()  {
                          setState(() {
                            theWorstAnswer = theWorstAnswers[Random().nextInt(7) + 1];
                          });
                          Timer(Duration(seconds: 3), () {
                            setState(() {
                              theWorstAnswer = theWorstAnswers[0];
                            });
                          });
                      },
                      child: 
                        Stack(
                          alignment: Alignment.center,
                          children: 
                          <Widget>[
                              theWorstAnswer.isEmpty ? Image.asset('images/8ball.png') : Image.asset('images/emptyBall.png'),
                              Container(
                                margin: const EdgeInsets.only(bottom: 40.0),
                                alignment: Alignment.center,
                                child: Text(
                                  theWorstAnswer,
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15))
                              )
                          ]
                        ),
                    )])
            ),
      )
    );
  }
}