import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:flutter/foundation.dart';

class MLARVR extends StatefulWidget {
  @override
  _MLARVRState createState() => _MLARVRState();
}

class _MLARVRState extends State<MLARVR> {
  ui.Image image;
  bool isImageloaded = false;
  void initState() {
    super.initState();
    init();
  }

  Future <Null> init() async {
    final ByteData data = await rootBundle.load('Assets/map.jpeg');
    image = await loadImage(new Uint8List.view(data.buffer));
  }
  
  Future<ui.Image> loadImage(List<int> img) async {
    final Completer<ui.Image> completer = new Completer();
    ui.decodeImageFromList(img, (ui.Image img) {
      setState(() {
        isImageloaded = true;
      });
      return completer.complete(img);
    });
    return completer.future;
  }

  Widget _buildImage() {
    if (this.isImageloaded) {
      return new CustomPaint(
          painter: new ImageEditor(image: image),
        );
    } else {
      return new Center(child: new Text('loading'));
    }
  }

  @override
  Widget build(BuildContext context) {
    //print(Rect.fromLTRB(left, top, right, bottom))
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: _buildImage(),
      ),
    );
  }
}

class PotholePainter extends CustomPainter{
  PotholePainter(this.image, this.potholes);
  final ui.Image image;
  final List<Rect> potholes;
  
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, Offset.zero, Paint());
    for(var i = 0; i<potholes.length;i++){
      canvas.drawRect(potholes[i], Paint());
    }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return null;
  }
}

class ImageEditor extends CustomPainter {


  ImageEditor({
    this.image,
  });

  ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    //ByteData data = image.toByteData();
    canvas.drawImage(image, new Offset(0.0, 0.0), new Paint());
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

}



class HttpService {
  final String postsURL = "https://jsonplaceholder.typicode.com/posts";

  Future<List<Post>> getPosts() async {
    Response res = await get(postsURL);

    if (res.statusCode == 200) {
      List<dynamic> body = jsonDecode(res.body);

      List<Post> posts = body
          .map(
            (dynamic item) => Post.fromJson(item),
          )
          .toList();

      return posts;
    } else {
      throw "Can't get posts.";
    }
  }
}

class Post {
  final int userId;
  final int id;
  final String title;
  final String body;

  Post({
    @required this.userId,
    @required this.id,
    @required this.title,
    @required this.body,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      userId: json['userId'] as int,
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }
}