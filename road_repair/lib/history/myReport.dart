import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:road_repair/app_theme.dart';
import './myReportStats.dart';

void main() => runApp(new MediaQuery(
    data: new MediaQueryData(), child: new MaterialApp(home: new BookList())));

class BookList extends StatelessWidget {
  final databaseReference = Firestore.instance;

  getStatus(reportData) {
    if (reportData["status"] == "completed") {
      return "Completed";
    } else if (reportData["status"] == "rejected") {
      return "Rejected";
    } else if (reportData["status"] == "ongoing") {
      return "In Progress";
    } else if (reportData["status"] == "submitted") {
      return "Submitted";
    }
  }

  getDamage(reportData) {
    var finalrate = 1;

    if (reportData["status"] == "completed") {
      finalrate = 3;
    } else if (reportData["status"] == "rejected") {
      finalrate = 3;
    } else if (reportData["status"] == "ongoing") {
      finalrate = 2;
    }
    return (finalrate / 3);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<FirebaseUser>(
          future: FirebaseAuth.instance.currentUser(),
          builder: (context, query) {
            if (query.connectionState == ConnectionState.waiting)
              return Center(
                child: CircularProgressIndicator(),
              );
            return StreamBuilder<QuerySnapshot>(
              stream: databaseReference

                  ///////   Please enter Uid Here //////////////////
                  /////////// Please ...........................///
                  /////////// Please ...........................///
                  .collection("Reports")
                  .where("userId", isEqualTo: query.data.uid)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError)
                  return new Text('Error: ${snapshot.error}');
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return new Text('Loading...');
                  default:
                    return new ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: snapshot.data.documents
                          .map((DocumentSnapshot document) {
                        return new ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 10.0),
                          leading: Container(
                            padding: EdgeInsets.only(right: 12.0),
                            decoration: new BoxDecoration(
                                border: new Border(
                                    right: new BorderSide(
                                        width: 1.0, color: Colors.white24))),
                            child: Image.network(document["images"][0]),
                          ),
                          title: new Text(getStatus(document)),
                          subtitle: new Row(
                            children: <Widget>[
                              Expanded(
                                  flex: 1,
                                  child: Container(
                                    // tag: 'hero',
                                    child: LinearProgressIndicator(
                                        backgroundColor:
                                            Color.fromRGBO(209, 224, 224, 0.2),
                                        value: getDamage(document),
                                        valueColor: document["status"] ==
                                                "rejected"
                                            ? AlwaysStoppedAnimation(Colors.red)
                                            : AlwaysStoppedAnimation(
                                                Colors.green)),
                                  )),
                              Expanded(
                                flex: 1,
                                child: Padding(
                                    padding: EdgeInsets.only(left: 10.0),
                                    child: Padding(
                                        padding: EdgeInsets.only(left: 30),
                                        child: Text(
                                          "Category : " + document['category'],
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 11,
                                            letterSpacing: -0.05,
                                            color: Color(0xFF17262A),
                                          ),
                                        ))),
                              )
                            ],
                          ),
                          trailing: Icon(Icons.keyboard_arrow_right,
                              color: Colors.black, size: 30.0),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        DetailPage(docdata: document)));
                          },
                        );
                      }).toList(),
                    );
                }
              },
            );
          }),
      //center
    );
  }
}
