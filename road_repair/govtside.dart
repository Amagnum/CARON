import 'package:flutter/material.dart';
import 'package:road_repair/contractor_workprogress.dart';
import 'package:road_repair/user_complaints.dart';

class GovtSide extends StatefulWidget {
  @override
  _GovtSideState createState() => _GovtSideState();
}

class _GovtSideState extends State<GovtSide> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome!"),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Card(
              elevation: 10,
              color: Colors.purple,
              child: InkWell(
                splashColor: Colors.black.withAlpha(30),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return ContractorWorkProgress();
                  }));
                },
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 175,
                      padding: EdgeInsets.all(10),
                      child: Center(
                        child: Text(
                          "Contractor's\nWork Progress",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                          ),
                          textAlign: TextAlign.center,
                          softWrap: true,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 5),
            ),
            Card(
              elevation: 10,
              color: Colors.deepPurple,
              child: InkWell(
                splashColor: Colors.black.withAlpha(30),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                    return UserComplaints();
                  }));
                },
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 175,
                      padding: EdgeInsets.all(10),
                      child: Center(
                        child: Text(
                          "User's\nComplaints",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                          ),
                          textAlign: TextAlign.center,
                          softWrap: true,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
