import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class NewReportsPage extends StatefulWidget {
  final List<DocumentSnapshot> newDocSnap;

  NewReportsPage({Key key, @required this.newDocSnap}) : super(key: key);

  @override
  _NewReportsPageState createState() => _NewReportsPageState();
}

class _NewReportsPageState extends State<NewReportsPage> {
  @override
  Widget build(BuildContext context) {
    final List<DocumentSnapshot> entries = widget.newDocSnap;
    entries.sort((a, b) {
      int ia = a.data['timestamp'];
      int ib = b.data['timestamp'];
      return ib.compareTo(ia);
    });
    print(entries[0].data);
    return Scaffold(
      appBar: AppBar(
        title: Text("New Complaints"),
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
                caption: 'Mark On-Going',
                color: Colors.blue,
                icon: Icons.check_circle_outline,
                onTap: () {Firestore.instance.document("Reports/${entries[index].documentID}").updateData({"status":"ongoing"});setState(() {entries.removeAt(index);});},
              ),
              IconSlideAction(
                caption: 'Reject',
                color: Colors.red,
                icon: Icons.delete,
                onTap: () {Firestore.instance.document("Reports/${entries[index].documentID}").updateData({"status":"rejected"});setState(() {entries.removeAt(index);});},
              ),
            ],
            child: GestureDetector(
              onTap: (){Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => ImageView(imglink:entries[index]["images"][0])));},
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
                    padding: EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      //crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text('Category: ${entries[index]["category"]}\n',style: TextStyle(fontSize: 18),),

                        Text('Date: ${DateTime.fromMillisecondsSinceEpoch(entries[index]["timestamp"]).toIso8601String().split("T")[0]}',style: TextStyle(fontSize: 18),),
                      ],
                    ),
                  ),
                  Spacer(),
                  Container(
                    child: Center(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text("Rating", style: TextStyle(fontSize: 16),),
                        Text(entries[index]["rating"].toString() + "★", style: TextStyle(fontSize: 16),),
                      ],
                    ),),
                    height: 100,
                    width: 100,
                  ),
                ],
                mainAxisSize: MainAxisSize.max,
                ),
              ),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      ),
    );
  }
}

class ImageView extends StatelessWidget {
  const ImageView({ Key key, this.imglink }) : super(key: key);
  final String imglink;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Image.network(imglink),
    );
  }
}