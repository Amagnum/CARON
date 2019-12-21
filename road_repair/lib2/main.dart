import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:road_repair/fireMap.dart';
import 'package:road_repair/govtside.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    void segmentGenerator() {
      var start = [29.86, 77.89];
      var end = [28.85, 78.86];
      var temp = [29.86, 77.89];
      var jump = 1;
      var x_old = 0;
      var geo = Geoflutterfire();
      for (var x = x_old; x < 20; x++) {
        var rand1 = Random().nextDouble();
        var rand2 = Random().nextDouble();
        var s = [
          start[0] + Random().nextDouble() * jump * (1 / (x + 1)),
          start[1] + Random().nextDouble() * jump * (1 / (x + 1))
        ];
        var e = [
          (start[0] + end[0] * rand1) / (1 + rand1),
          (start[1] + end[1] * rand2) / (1 + rand2)
        ];
        var loc = [(temp[0] + e[0]) / 2, (temp[1] + e[1]) / 2];
        Firestore.instance
            .collection('Segments')
            .document('Route10001_Seg' + x.toString())
            .setData({
          'start': temp,
          'end': e,
          'location': loc,
          'flags': 'none',
          'route_id': '10001',
          'geotag': geo.point(latitude: loc[0], longitude: loc[1]).data
        }).catchError((e) {
          print(e);
        });
        temp = e;
      }
    }

    return Scaffold(body: GovtSide());
  }
}
