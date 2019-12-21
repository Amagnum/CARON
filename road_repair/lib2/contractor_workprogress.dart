import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ContractorWorkProgress extends StatefulWidget {
  @override
  _ContractorWorkProgressState createState() => _ContractorWorkProgressState();
}

class _ContractorWorkProgressState extends State<ContractorWorkProgress> {
  List seg1, seg2, seg3;


  getData() async{
     await Firestore.instance.document("routes/one").get().then((ds) {
      setState(() {
        seg1 = ds["arr"];
      });
    });
    await Firestore.instance.document("routes/two").get().then((ds) {
      setState(() {
        seg2 = ds["arr"];
      });
    });
    await Firestore.instance.document("routes/three").get().then((ds) {
      setState(() {
        seg3 = ds["arr"];
      });
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        width: 500,
        height: 500,
        child: ListView(
          children: <Widget>[
            Card(
              color: Colors.purple,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => WebViewer(
                              title: "Contractor 1",
                              segments: seg1,
                              doc: "routes/one",
                              url:
                                  "https://map-road-rash.netlify.com/?type=one")));
                },
                child: Container(
                  height: 100,
                  child: Center(
                    child: Text(
                      "Contractor 1",
                      style: TextStyle(color: Colors.white, fontSize: 32),
                    ),
                  ),
                ),
              ),
            ),
            Card(
              color: Colors.purple,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => WebViewer(
                              title: "Contractor 2",
                              segments: seg2,
                              doc: "routes/two",
                              url:
                                  "https://map-road-rash.netlify.com/?type=two")));
                },
                child: Container(
                  height: 100,
                  child: Center(
                    child: Text(
                      "Contractor 2",
                      style: TextStyle(color: Colors.white, fontSize: 32),
                    ),
                  ),
                ),
              ),
            ),
            Card(
              color: Colors.purple,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) => WebViewer(
                              title: "Contractor 3",
                              segments: seg3,
                              doc: "routes/three",
                              url:
                                  "https://map-road-rash.netlify.com/?type=three")));
                },
                child: Container(
                  height: 100,
                  child: Center(
                    child: Text(
                      "Contractor 3",
                      style: TextStyle(color: Colors.white, fontSize: 32),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WebViewer extends StatefulWidget {
  const WebViewer({Key key, this.url, this.title, this.segments, this.doc})
      : super(key: key);

  final String url;
  final String title;
  final List segments;
  final String doc;
  @override
  _WebViewerState createState() => _WebViewerState();
}

class _WebViewerState extends State<WebViewer> {
  int i = 0;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        WebviewScaffold(
          url: widget.url,
          appBar: new AppBar(
            actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.of(context).pop();
                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => Scaffold(
                          appBar: AppBar(),
                          body: Container(
                            child: ListView.builder(
                              itemCount: widget.segments.length,
                              itemBuilder: (BuildContext context, int index) {
                                return ListTile(
                                  leading: Checkbox(materialTapTargetSize: MaterialTapTargetSize.padded,
                                    value: widget.segments[index]
                                        ["isCompleted"],
                                    onChanged: (val) {
                                      Firestore.instance
                                          .document(widget.doc)
                                          .updateData({'isCompleted': val});
                                    },
                                  ),
                                  title: Text(index.toString()),
                                );
                              },
                            ),
                          ),
                    ))); 
                  }),
            ],
            title: new Text(widget.title),
          ),
        ),
      ],
    );
  }
}
