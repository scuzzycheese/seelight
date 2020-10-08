import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';

final theWorstLucks = [
  'If it\'s not happy it\'s not the end.',
  'You have brains in your head. You have feet in your shoes. \nYou can steer yourself any direction you choose.',
  'The more that you read, the more things you will know. \nThe more that you learn, the more places you\'ll go.',
  'You\'re off to Great Places! \nToday is your day! Your mountain is waiting, \nSo... get on your way!',
  'From there to here, and here to there, \nfunny things are everywhere.',
  'I like nonsense, \nit wakes up the brain cells.',
  'Congratulations! \nToday is your day!',
  'You do not like them. So you say. \nTry them! Try them! And you may!',
  'In my world, everyone\'s a pony \nand they all eat rainbows and poop butterflies!',
  'Just tell yourself, Duckie, \nyou’re really quite lucky!',
  'Why fit in when you were born to stand out?',
  'You’ll miss the best things \nif you keep your eyes shut.',
  'Things may happen and often do \nto people as brainy and footsy as you.',
  'Don\'t cry because it\'s over. \nSmile because it happened.',
  'Adults are just obsolete children \nand the hell with them.',
  'Unless someone like you cares a whole awful lot, \nnothing is going to get better. It\'s not.'
  'It\'s not about what it is, \nit\'s about what it can become.'
  ];

class CookieWidget extends StatefulWidget {
  @override
  _CookieWidget createState() => _CookieWidget();
}

class _CookieWidget extends State<CookieWidget> {
  String theWorstLuck = '';
  bool currentlyLucky = false;

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
                          'Eat me!',
                          style: 
                            TextStyle(
                              color: Colors.grey[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 20)
                          )
                    ),
                    GestureDetector(
                      onTap: ()  {
                          if(!currentlyLucky) {
                            setState(() {
                              theWorstLuck = theWorstLucks[Random().nextInt(theWorstLucks.length)];
                              currentlyLucky = true;
                            });
                            Timer(Duration(seconds: 10), () {
                              setState(() {
                                theWorstLuck = '';
                                currentlyLucky = false;
                              });
                            });
                          }
                      },
                      child: 
                        Stack(
                          alignment: Alignment.center,
                          children: 
                          <Widget>[
                              Image.asset('images/cookie.png')
                          ]
                        ),
                    ),
                    Container(
                        margin: const EdgeInsets.only(top: 40.0),
                        alignment: Alignment.center,
                        child:
                        Text(
                          theWorstLuck,
                          style: 
                            TextStyle(
                              color: Colors.grey[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 20)
                          )
                    )])
            ),
      )
    );
  }
}