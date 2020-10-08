import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

final theWorstAnswers = [
  '¯\\_(ツ)_/¯',
  'Sure!',
  'Sure.',
  'Sure...\nSure',
  '"Sure"',
  'Sure?',
  'As \nI see it, \nyes!',
  'Don\'t \ncount \non it...',
  'I\'m not \nhere to \njudge...',
  'Better \nnot \ntell you \nnow...',
  'Ask \nyour \nsister!',
  ':)'];

class EightBallWidget extends StatefulWidget {
  @override
  _EightBallWidget createState() => _EightBallWidget();
}

class _EightBallWidget extends State<EightBallWidget> {
  String theWorstAnswer = '';
  bool alreadyAnswered = false;

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
                          if(!alreadyAnswered) {
                              setState(() {
                                theWorstAnswer = theWorstAnswers[Random().nextInt(theWorstAnswers.length)];
                                alreadyAnswered = true;
                              });
                              Timer(Duration(seconds: 3), () {
                                setState(() {
                                  theWorstAnswer = '';
                                  alreadyAnswered = false;
                                });
                              });
                          }
                      },
                      child: 
                        Stack(
                          alignment: Alignment.center,
                          children: 
                          <Widget>[
                              alreadyAnswered ? Image.asset('images/emptyBall.png') : Image.asset('images/8ball.png'),
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