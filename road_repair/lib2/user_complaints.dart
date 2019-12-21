import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:road_repair/fireMap.dart';

import 'User Complaints Pages/Completed_page.dart';
import 'User Complaints Pages/new_reports_page.dart';
import 'User Complaints Pages/on_going_complaints_page.dart';

class UserComplaints extends StatefulWidget {
  @override
  _UserComplaintsState createState() => _UserComplaintsState();
}

class _UserComplaintsState extends State<UserComplaints> {
  Geolocator location = Geolocator();
  List<DocumentSnapshot> docSnap = [];
  List<DocumentSnapshot> compDocSnap = [];

  List<DocumentSnapshot> onDocSnap = [];
  List<DocumentSnapshot> newDocSnap = [];

  Firestore firestore = Firestore.instance;
  Geoflutterfire geo = Geoflutterfire();
  double radius = 100;
  Stream<dynamic> query;

  // Subscription
  StreamSubscription subscription;

  @override
  void initState() {
    super.initState();
    _startQuery();
  }

  void _updateMarkers(List<DocumentSnapshot> documentList) {
    print(documentList);
    setState(() {
      compDocSnap = [];
      docSnap = [];
      newDocSnap = [];
      onDocSnap = [];
    });
    documentList.forEach((ds) {
      if (ds.data['status'] == 'completed') {
        setState(() {
          compDocSnap.add(ds);
        });
      } else if (ds.data['status'] == 'submitted') {
        setState(() {
          newDocSnap.add(ds);
        });
      } else if (ds.data['status'] == 'ongoing') {
        setState(() {
          onDocSnap.add(ds);
        });
      }
    });
    setState(() {
      docSnap = documentList;
    });
  }

  _startQuery() async {
    // Get users location
    var pos = await location.getCurrentPosition();
    if (pos == null) {
      Fluttertoast.showToast(msg: 'Your posiotion is null');
      return;
    }
    double lat = pos.latitude;
    double lng = pos.longitude;

    // Make a referece to firestore
    var ref = firestore.collection('Segments');
    GeoFirePoint center = geo.point(latitude: lat, longitude: lng);

    // subscribe to query

    // geo
    //     .collection(collectionRef: ref)
    //     .within(center: center, radius: 100, field: 'geotag', strictMode: true)
    //     .listen(_updateMarkers);
    Firestore().collection('Reports').snapshots().listen((qs) {
      _updateMarkers(qs.documents);
    });
  }

  Widget swiperText(text) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Colors.purple, Colors.blue]),
          borderRadius: BorderRadius.circular(20)),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 32,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  bool uiVisible = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: <Widget>[
            Scaffold(
              body: FireMap(),
              floatingActionButton: !uiVisible
                  ? FloatingActionButton(
                      child: Icon(Icons.arrow_back),
                      onPressed: () {
                        setState(() {
                          uiVisible = !uiVisible;
                          print(uiVisible);
                        });
                      },
                    )
                  : null,
            ),
            uiVisible
                ? GestureDetector(
                    child: Container(
                      color: Colors.transparent,
                      constraints: BoxConstraints.expand(),
                    ),
                    onTap: () {
                      setState(() {
                        uiVisible = !uiVisible;
                        print(uiVisible);
                      });
                    },
                  )
                : Container(),
            Visibility(
              visible: uiVisible,
              child: Container(
                padding: EdgeInsets.only(top: 25, left: 0),
                child: FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                      size: 40,
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: uiVisible,
              child: Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                        Colors.grey[300].withAlpha(200),
                        Colors.white.withAlpha(200)
                      ])),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                  ),
                  height: 120,
                ),
              ),
            ),
            Visibility(
              visible: uiVisible,
              child: Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Container(
                  height: 100,
                  child: Swiper(
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        elevation: 0,
                        color: Colors.transparent,
                        child: InkWell(
                          child: index == 0
                              ? swiperText("New Reports")
                              : (index == 1
                                  ? swiperText("On-Going Complaints")
                                  : swiperText("Completed")),
                          splashColor: Colors.black,
                          onTap: () {
                            if (index == 0) {
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (BuildContext context) {
                                return NewReportsPage(newDocSnap: newDocSnap);
                              }));
                            }
                            if (index == 1) {
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (BuildContext context) {
                                return OnGoingComplaintsPage(
                                    onDocSnap: onDocSnap);
                              }));
                            }
                            if (index == 2) {
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (BuildContext context) {
                                return CompletedPage(compDocSnap: compDocSnap);
                              }));
                            }
                          },
                        ),
                      );
                    },
                    itemCount: 3,
                    viewportFraction: 0.75,
                    scale: 0.9,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  dispose() {
    subscription.cancel();
    super.dispose();
  }
}
