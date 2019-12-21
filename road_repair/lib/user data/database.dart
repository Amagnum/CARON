import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});

  final CollectionReference userData =
      Firestore.instance.collection('UserData');

  Future updateUserData(String uid, String username, String email,
      String password, String phoneNo) async {
    return await userData.document(uid).setData({
      'username': username,
      'email': email,
      'userId': uid,
      'password': password,
      'phoneNo': phoneNo,
    });
  }
}
