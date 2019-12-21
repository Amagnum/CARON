import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class OnGoingComplaintsPage extends StatefulWidget {
  final List<DocumentSnapshot> onDocSnap;

  OnGoingComplaintsPage({Key key, @required this.onDocSnap}) : super(key: key);

  @override
  _OnGoingComplaintsPageState createState() => _OnGoingComplaintsPageState();
}

class _OnGoingComplaintsPageState extends State<OnGoingComplaintsPage> {
  @override
  Widget build(BuildContext context) {
    final List<DocumentSnapshot> entries = widget.onDocSnap;
    entries.sort((a, b) {
      int ia = a.data['timestamp'];
      int ib = b.data['timestamp'];
      return ib.compareTo(ia);
    });
    print(entries[0].data);
    return Scaffold(
      appBar: AppBar(
        title: Text("On-Going Complaints"),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: entries.length,
        itemBuilder: (BuildContext context, int index) {
          return Slidable(
            actionPane: SlidableDrawerActionPane(),
            actionExtentRatio: 0.25,
            secondaryActions: <Widget>[
              IconSlideAction(
                caption: 'Approve',
                color: Colors.green,
                icon: Icons.check_box,
                onTap: () {Firestore.instance.document("Reports/${entries[index].documentID}").updateData({"status":"completed"});setState(() {entries.removeAt(index);});},
              ),
              IconSlideAction(
                caption: 'Reject',
                color: Colors.red,
                icon: Icons.delete,
                onTap: () {Firestore.instance.document("Reports/${entries[index].documentID}").updateData({"status":"rejected"});setState(() {entries.removeAt(index);});},
              ),
            ],
            child: Container(
              height: 100,
              //color: Colors.purple,
              child: Row(children: <Widget>[
                Container(
                  child: Image.network(
                    "https://maps.googleapis.com/maps/api/staticmap?center=&zoom=13&scale=1&size=200x200&maptype=roadmap&key=AIzaSyCI-cR5myD0t1dOKh81RXlhGP1zct4ICMU&format=jpg&visual_refresh=true&markers=size:tiny%7Ccolor:0xff0000%7Clabel:1%7C${entries[index]["location"]==null ? 29.863061:entries[index]["location"][0]},${entries[index]["location"]==null ? 77.909338:entries[index]["location"][1]}",
                    fit: BoxFit.contain,
                  ),
                  height: 100,
                  width: 100,
                ),
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text('Category: ${entries[index]["category"]}'),
                      Text('Time: ${entries[index]["timestamp"]}'),
                    ],
                  ),
                ),
                Spacer(),
                Container(
                  child: Center(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text("Rating"),
                      Text(entries[index]["rating"].toString()),
                    ],
                  ),),
                  height: 100,
                  width: 100,
                ),
              ],
              mainAxisSize: MainAxisSize.max,
              ),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      ),
    );
  }
}
