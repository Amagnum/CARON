import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadModel {
  bool isUploaded;
  bool uploading;
  File imageFile;
  String imageUrl;

  ImageUploadModel({
    this.isUploaded,
    this.uploading,
    this.imageFile,
    this.imageUrl,
  });
}

class FeedPage extends StatefulWidget {
  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  //List<Object> images = List<Object>();
  //Future<File> _imageFile;
  //List<File> bhagwan;
  Position pos;
  GeoFirePoint upPoint;
  FirebaseUser upUser;

  @override
  void initState() {
    super.initState();
  }

  loadLocation() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    Position posit = await Geolocator().getCurrentPosition().catchError((err) {
      Fluttertoast.showToast(msg: 'Please enable location');
    });
    GeoFirePoint point = GeoFirePoint(posit.latitude, posit.longitude);
    setState(() {
      pos = posit;
      upPoint = point;
      upUser = user;
    });
  }

  var myFeedbackText = "COULD BE BETTER";
  var sliderValue = 3.0;
  IconData myFeedback = FontAwesomeIcons.sadTear;
  Color myFeedbackColor = Color(0xFF2633C5);

  Widget buildGridView() {
    return ListView.builder(
        itemCount: 1,
        //viewportFraction: 0.8,
        //scale: 0.9,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          if (_tasks.length == 0) {
            return Card(
              child: IconButton(
                icon: Icon(Icons.add_a_photo),
                onPressed: () {
                  openFileExplorer();
                },
              ),
            );
          }
          if (_tasks[index].isInProgress) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (_tasks[index].isSuccessful) {
            return Image.network(
              images[index].toString(),
              width: 300,
              height: 300,
            );
          } else
            return Center(
                child: Text(
              'No images',
              style: TextStyle(color: Colors.black),
            ));
        });
  }

  void okTested() async {
    loadLocation();
    if (images.length == 0) {
      Fluttertoast.showToast(msg: 'Please add one image!');
      return;
    }

    Fluttertoast.showToast(msg: 'Please Wait');
    if (pos == null || upUser == null) {
      Fluttertoast.showToast(msg: 'Please enable Location');
    } else {
      Firestore().collection('Reports').add({
        'userId': upUser.uid,
        'images': images,
        'rating': sliderValue,
        'status': 'submitted',
        'category': 'Pot Holes',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'location': upPoint.data,
      }).then((val) {
        Navigator.pushReplacementNamed(context, '/home');
      });
    }
  }

  // ########################################## image handler #########################
  List<String> images = [];
  String _path;
  String _extension;
  List<StorageUploadTask> _tasks = <StorageUploadTask>[];

  void openFileExplorer() async {
    try {
      _path = null;
      _path = await FilePicker.getFilePath(
          type: FileType.IMAGE, fileExtension: _extension);
      uploadToFirebase();
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    }
    if (!mounted) return;
  }

  uploadToFirebase() {
    if (_path == null) return;
    String fileName = _path.split('/').last;
    String filePath = _path;
    upload(fileName, filePath);
  }

  upload(fileName, filePath) async {
    _extension = fileName.toString().split('.').last;
    StorageReference storageRef =
        FirebaseStorage.instance.ref().child('reports/' + fileName);
    final StorageUploadTask uploadTask = storageRef.putFile(
      File(filePath),
      StorageMetadata(
        contentType: '${FileType.IMAGE}/$_extension',
      ),
    );
    setState(() {
      _tasks.add(uploadTask);
    });
    await uploadTask.onComplete.then((snap) async {
      String url = await snap.ref.getDownloadURL();
      if (url != null)
        setState(() {
          images.add(url);
        });
    });
  }

  Future<void> downloadFile(StorageReference ref) async {
    final String url = await ref.getDownloadURL();
    final http.Response downloadData = await http.get(url);
    final Directory systemTempDir = Directory.systemTemp;
    final File tempFile = File('${systemTempDir.path}/tmp.jpg');
    if (tempFile.existsSync()) {
      await tempFile.delete();
    }
    await tempFile.create();
    final StorageFileDownloadTask task = ref.writeToFile(tempFile);
    final int byteCount = (await task.future).totalByteCount;
    var bodyBytes = downloadData.bodyBytes;
    final String name = await ref.getName();
    final String path = await ref.getPath();
    print(
      'Success!\nDownloaded $name \nUrl: $url'
      '\npath: $path \nBytes Count :: $byteCount',
    );
  }

  Widget imagePicker() {
    final List<Widget> children = <Widget>[];
    _tasks.forEach((StorageUploadTask task) {
      final Widget tile = UploadTaskListTile(
        task: task,
        onDismissed: () => setState(() => _tasks.remove(task)),
        onDownload: () => downloadFile(task.lastSnapshot.ref),
      );
      children.add(tile);
    });
    print(images.length);
    return ListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: <Widget>[
        _tasks.length == 0
            ? Card(
                child: IconButton(
                  icon: Icon(Icons.add_a_photo),
                  onPressed: () {
                    openFileExplorer();
                  },
                ),
              )
            : Container(),
        _tasks.length == 0
            ? Container()
            : ListView(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: children,
              ),
        images.length == 0
            ? Container()
            : Image.network(
                images[0].toString(),
                height: 200,
              ),
      ],
    );
  }

  //####################################### end ############################

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.lightBlue),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        title: Text(
          "Feedback",
          style: TextStyle(color: Colors.lightBlue),
        ),
        actions: <Widget>[
          IconButton(icon: Icon(FontAwesomeIcons.solidStar), onPressed: () {}),
        ],
      ),
      body: Container(
        color: Color(0xffE5E5E5),
        padding: EdgeInsets.all(15),
        child: ListView(
          children: <Widget>[
            imagePicker(),
            Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    child: Text(
                  "On a scale of 1 to 5, how do you rate the damage it can cause?",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold),
                )),
              ),
            ),
            SizedBox(height: 10.0),
            Container(
                width: 350.0,
                height: 300.0,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                          child: Icon(
                        myFeedback,
                        color: myFeedbackColor,
                        size: 60.0,
                      )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                          child: Text(
                        myFeedbackText,
                        style: TextStyle(color: Colors.black, fontSize: 18.0),
                      )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                        child: Slider(
                          min: 1.0,
                          max: 5.0,
                          divisions: 4,
                          value: sliderValue,
                          activeColor: Colors.lightBlue,
                          inactiveColor: Colors.blueGrey,
                          onChanged: (newValue) {
                            setState(() {
                              sliderValue = newValue;
                              if (sliderValue >= 4.1 && sliderValue <= 5.0) {
                                myFeedback = FontAwesomeIcons.sadTear;
                                myFeedbackColor = Colors.red;
                                myFeedbackText = "URGENT";
                              }
                              if (sliderValue >= 3.1 && sliderValue <= 4.0) {
                                myFeedback = FontAwesomeIcons.frown;
                                myFeedbackColor = Colors.orange;
                                myFeedbackText = "DANGEROUS";
                              }
                              if (sliderValue >= 2.1 && sliderValue <= 3.0) {
                                myFeedback = FontAwesomeIcons.meh;
                                myFeedbackColor = Colors.amber;
                                myFeedbackText = "RISKY";
                              }
                              if (sliderValue >= 1.1 && sliderValue <= 2.0) {
                                myFeedback = FontAwesomeIcons.smile;
                                myFeedbackColor = Colors.lightBlue;
                                myFeedbackText = "NEEDS REPAIR";
                              }
                              if (sliderValue >= 0.0 && sliderValue <= 1.0) {
                                myFeedback = FontAwesomeIcons.laugh;
                                myFeedbackColor = Colors.green;
                                myFeedbackText = "GOOD TO GO";
                              }
                            });
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                          child: Text(
                        "Your Rating: $sliderValue",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold),
                      )),
                    ),
                    Container(
                        child: Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0)),
                          color: Colors.lightBlue,
                          child: Text(
                            'Submit',
                            style: TextStyle(
                                color: Color(0xffffffff), fontSize: 22),
                          ),
                          onPressed: () {
                            okTested();
                          },
                        ),
                      ),
                    )),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}

class UploadTaskListTile extends StatelessWidget {
  const UploadTaskListTile(
      {Key key, this.task, this.onDismissed, this.onDownload, this.onComplete})
      : super(key: key);

  final StorageUploadTask task;
  final VoidCallback onDismissed;
  final VoidCallback onDownload;
  final VoidCallback onComplete;
  String get status {
    String result;
    if (task.isComplete) {
      if (task.isSuccessful) {
        result = 'Complete';
      } else if (task.isCanceled) {
        result = 'Canceled';
      } else {
        result = 'Failed ERROR: ${task.lastSnapshot.error}';
      }
    } else if (task.isInProgress) {
      result = 'Uploading';
    } else if (task.isPaused) {
      result = 'Paused';
    }
    return result;
  }

  String _bytesTransferred(StorageTaskSnapshot snapshot) {
    return '${snapshot.bytesTransferred}/${snapshot.totalByteCount}';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StorageTaskEvent>(
      stream: task.events,
      builder: (BuildContext context,
          AsyncSnapshot<StorageTaskEvent> asyncSnapshot) {
        Widget subtitle;
        if (asyncSnapshot.hasData) {
          final StorageTaskEvent event = asyncSnapshot.data;
          final StorageTaskSnapshot snapshot = event.snapshot;
          subtitle = Text('$status: ${_bytesTransferred(snapshot)} bytes sent');
        } else {
          subtitle = const Text('Starting...');
        }
        return Dismissible(
          key: Key(task.hashCode.toString()),
          onDismissed: (_) => onDismissed(),
          child: ListTile(
            title: Text('Upload Task #${task.hashCode}'),
            subtitle: subtitle,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Offstage(
                  offstage: !task.isInProgress,
                  child: IconButton(
                    icon: const Icon(Icons.pause),
                    onPressed: () => task.pause(),
                  ),
                ),
                Offstage(
                  offstage: !task.isPaused,
                  child: IconButton(
                    icon: const Icon(Icons.file_upload),
                    onPressed: () => task.resume(),
                  ),
                ),
                Offstage(
                  offstage: task.isComplete,
                  child: IconButton(
                    icon: const Icon(Icons.cancel),
                    onPressed: () => task.cancel(),
                  ),
                ),
                Offstage(
                  offstage: !(task.isComplete && task.isSuccessful),
                  child: IconButton(
                    icon: const Icon(Icons.file_download),
                    onPressed: onDownload,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
