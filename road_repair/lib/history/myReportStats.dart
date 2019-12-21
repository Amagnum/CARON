import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DetailPage extends StatelessWidget {
  getStat(reportData) {
    var rating = reportData['rating'];

    if (rating == 1) {
      return FontAwesomeIcons.laugh;
    } else if (rating == 2) {
      return FontAwesomeIcons.smile;
    } else if (rating == 3) {
      return FontAwesomeIcons.meh;
    } else if (rating == 4) {
      return FontAwesomeIcons.frown;
    } else if (rating == 5) {
      return FontAwesomeIcons.sadTear;
    }
  }

  getCol(reportData) {
    var rating = reportData['rating'];

    if (rating == 1) {
      return Color(0xffff520d);
    } else if (rating == 2) {
      return Colors.green;
    } else if (rating == 3) {
      return Colors.amber;
    } else if (rating == 4) {
      return Colors.yellow;
    } else if (rating == 5) {
      return Colors.red;
    }
  }

  getTag(reportData) {
    var rating = reportData['rating'];

    if (rating == 1) {
      return "GOOD TO GO !";
    } else if (rating == 2) {
      return "NEEDS REPAIR";
    } else if (rating == 3) {
      return "RISKY";
    } else if (rating == 4) {
      return "DANGEROUS";
    } else if (rating == 5) {
      return "URGENT";
    }
  }

  getDamage(reportData) {
    var finalrate = 1;

    if (reportData["status"] == "completed") {
      finalrate = 3;
    } else if (reportData["status"] == "rejected") {
      finalrate = 0;
    } else if (reportData["status"] == "ongoing") {
      finalrate = 2;
    }
    return (finalrate / 3);
  }

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

  getKarmaPoints(reportData) {
    Map<String, int> multipliers;
    int points = 0;

    multipliers = {
      "AcceptedMult": 20,
      "ProgressMult": 10,
      "RejectedMult": -10,
      "ContributionMult": 5,
      "RemarkMult": 5,
    };

    if (reportData["status"] == "completed") {
      points = points + multipliers["AcceptedMult"];
    } else if (reportData["status"] == "rejected") {
      points = points + multipliers["RejectedMult"];
    } else if (reportData["status"] == "ongoing") {
      points = points + multipliers["ProgressMult"];
    } else if (reportData["status"] == "submitted") {
      points = points + multipliers["ContributionMult"];
    }
    if (reportData["remark"] != null) {
      points = points + multipliers["RemarkMult"];
    }
    return points.toString();
  }

  final docdata;

  DetailPage({Key key, this.docdata}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    print(docdata);
    var sexy = getKarmaPoints(docdata);
    sexy = sexy.toString();
    final levelIndicator = Container(
      child: Container(
        child: LinearProgressIndicator(
            backgroundColor: Color.fromRGBO(209, 224, 224, 0.2),
            value: getDamage(docdata),
            valueColor: AlwaysStoppedAnimation(Colors.green)),
      ),
    );

    final coursePrice = Container(
      padding: const EdgeInsets.all(4.0),
      decoration: new BoxDecoration(
          border: new Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(5.0)),
      child: new Text(
        // "\$20",
        sexy,
        style: TextStyle(color: Colors.white),
      ),
    );

    final topContentText = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        SizedBox(height: 30.0),
        Text(
          getStatus(docdata),
          style: TextStyle(color: Colors.white, fontSize: 45.0),
        ),
        SizedBox(height: 30.0),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Expanded(
                  flex: 2,
                  child: Padding(
                      padding: EdgeInsets.only(left: 0.0),
                      child: Text(
                        "Report Progress :",
                        style: TextStyle(color: Colors.white),
                      ))),
              Expanded(flex: 1, child: levelIndicator)
            ]),
            SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Expanded(
                  flex: 2,
                  child: Padding(
                      padding: EdgeInsets.only(left: 0.0),
                      child: Text(
                        "Karma Points Recieved :",
                        style: TextStyle(color: Colors.white),
                      ))),
              Expanded(flex: 1, child: coursePrice)
            ]),
          ],
        ),
      ],
    );

    final topContent = Stack(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height * 0.5,
          padding: EdgeInsets.all(40.0),
          width: MediaQuery.of(context).size.width,
          decoration: new BoxDecoration(
            color: const Color(0xff7c94b6),
            image: new DecorationImage(
              fit: BoxFit.cover,
              colorFilter: new ColorFilter.mode(
                  Colors.black.withOpacity(0.1), BlendMode.dstATop),
              image: new NetworkImage(
                docdata["images"][0],
              ),
            ),
          ),
          child: Center(
            child: topContentText,
          ),
        ),
        Positioned(
          left: 8.0,
          top: 60.0,
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back, color: Colors.white),
          ),
        )
      ],
    );

    final bottomContentText = Text(
      "Submitted Road Status :",
      style: TextStyle(fontSize: 18.0),
    );
    final readButton = Container(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        width: MediaQuery.of(context).size.width,
        child: RaisedButton(
          onPressed: () => {},
          color: Color.fromRGBO(58, 66, 86, 1.0),
          child:
              Text("TAKE THIS LESSON", style: TextStyle(color: Colors.white)),
        ));
    final bottomContent = Container(
      // height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      // color: Theme.of(context).primaryColor,
      padding: EdgeInsets.all(40.0),
      child: Center(
        child: Column(
          children: <Widget>[
            bottomContentText,
            SizedBox(
              height: 20,
            ),
            Container(
                width: 350.0,
                height: 150.0,
                child: Column(children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                        child: Text(
                      getTag(docdata),
                      style: TextStyle(color: Colors.black, fontSize: 18.0),
                    )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        child: Icon(
                      getStat(docdata),
                      color: getCol(docdata),
                      size: 60.0,
                    )),
                  )
                ])),
            Container(
              child: Image.network(
                "https://maps.googleapis.com/maps/api/staticmap?center=&zoom=13&scale=1&size=300x300&maptype=roadmap&key=AIzaSyCI-cR5myD0t1dOKh81RXlhGP1zct4ICMU&format=jpg&visual_refresh=true&markers=size:tiny%7Ccolor:0xff0000%7Clabel:1%7C${docdata["location"] == null ? 29.863061 : docdata["location"]['geopoint'].latitude},${docdata["location"] == null ? 77.909338 : docdata["location"]['geopoint'].longitude}",
                fit: BoxFit.contain,
              ),
              width: MediaQuery.of(context).size.width,
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: BottomAppBar(
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(DateTime.fromMillisecondsSinceEpoch(docdata['timestamp'])
              .toString()),
        ),
      ),
      body: ListView(
        children: <Widget>[topContent, bottomContent],
      ),
    );
  }
}
