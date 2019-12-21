import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LeaderBoardUpdater extends StatefulWidget {
  @override
  _LeaderBoardUpdaterState createState() => _LeaderBoardUpdaterState();
}

class _LeaderBoardUpdaterState extends State<LeaderBoardUpdater> {
  void leaderboardAction() async {
    Firestore firestore = Firestore.instance;

    var userId = "aab"; ////////////////////////////////////// TEMP DO NOT USE

    List<DocumentSnapshot> allUserReports;
    await firestore
        .collection('Reports')
        .where("userId", isEqualTo: userId)
        .getDocuments()
        .then((qs) {
      var docs;
      print(qs);
      qs.documents.forEach((ds) {
        docs.add(ds.data);
        print(docs);
      });
      allUserReports = docs;
    });

    int approvedReportslength = 0;
    int rejectedReportslength = 0;
    int remarkedReportslength = 0;
    allUserReports.forEach((doc) {
      if (doc["status"] == "completed") {
        approvedReportslength += 1;
      } else if (doc["status"] == "rejected") {
        rejectedReportslength += 1;
      }
      if (doc["remark"] != null) {
        remarkedReportslength += 1;
      }
    });

    print(approvedReportslength);
    print(rejectedReportslength);
    print(remarkedReportslength);

    Map<String, int> multipliers;
    await firestore
        .document("Ranking System / Point Calculator")
        .get()
        .then((ds) {
      multipliers = ds.data;
    });

    int points = approvedReportslength * multipliers["AcceptedMult"] +
        rejectedReportslength * multipliers["RejectedMult"] +
        (allUserReports.length -
                rejectedReportslength -
                approvedReportslength) *
            multipliers["ContributionMult"] +
        remarkedReportslength * multipliers["RemarkMult"];

    await firestore.document("UserData/" + userId).setData({
      "points": points,
      "totalReportsNo": allUserReports.length,
      "approvedReportsNo": approvedReportslength,
      "rejectedReportsNo": rejectedReportslength,
      "remarkedReportsNo": remarkedReportslength,
    });
  }

  getKarmaPoints(reportData) async {
    Map<String, int> multipliers;
    int points = 0;
    await Firestore.instance
        .document("Ranking System / Point Calculator")
        .get()
        .then((ds) {
      multipliers = ds.data;
    });
    if (reportData["status"] == "completed") {
      points = points + multipliers["AcceptedMult"];
    } else if (reportData["status"] == "rejected") {
      points = points + multipliers["RejectedMult"];
    } else if (reportData["status"] == "ongoing") {
      points = points + multipliers["ContributionMult"];
    }
    if (reportData["remark"] != null) {
      points = points + multipliers["RemarkMult"];
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: FlatButton(
          onPressed: () {
            print("pressed");

            Firestore.instance.collection("UserData").add({
              "email": "dfgnsdhb",
              "password": "srhetjj",
              "phoneNo": 1234567890,
              "username": "erhsthu",
              "points": 745398,
              "totalReportsNo": 85,
              "approvedReportsNo": 85,
              "rejectedReportsNo": 57,
              "remarkedReportsNo": 86,
            });
          },
          color: Colors.red,
          child: Text("TAPPP"),
        ),
      ),
    );
  }
}
