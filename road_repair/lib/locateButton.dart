import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nice_button/NiceButton.dart';
import 'package:road_repair/fireMap.dart';

class LocateButton extends StatefulWidget {
  @override
  _LocateButtonState createState() => _LocateButtonState();
}

class _LocateButtonState extends State<LocateButton> {
  var firstColor = Color(0xff5b86e5), secondColor = Color(0xff36d1dc);

  @override
  Widget build(BuildContext context) {
    return NiceButton(
      background: Colors.white,
      radius: 40,
      padding: const EdgeInsets.all(15),
      text: "Locate",
      icon: Icons.location_searching,
      gradientColors: [secondColor, firstColor],
      onPressed: () {
        Firestore.instance.collection('Reports').add({
          'userId': 'aab',
          'images': [
            'https://images.unsplash.com/photo-1503023345310-bd7c1de61c7d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80',
            'https://images.unsplash.com/photo-1535498730771-e735b998cd64?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80'
          ],
          'rating': 5,
          'status': 'ongoing',
          'category': 'pothole',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
        return;
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => Scaffold(body: FireMap())));
      },
    );
  }
}
