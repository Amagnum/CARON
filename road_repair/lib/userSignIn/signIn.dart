import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:road_repair/Models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Authentication extends StatefulWidget {
  final Function toggleView;
  Authentication({this.toggleView});

  @override
  _AuthenticationPageState createState() => new _AuthenticationPageState();
}

class _AuthenticationPageState extends State<Authentication> {
  String email;
  String password;
  String error = "";
  bool isLoading = false;
  final _formkey = GlobalKey<FormState>();

  FirebaseAuth _auth = FirebaseAuth.instance;
  bool checkValue = false;
  SharedPreferences sharedPreferences;

  User _userFromFirebaseUser(FirebaseUser user) {
    return user != null ? User(uid: user.uid) : null;
  }

  void _erroDialog(String title, String body) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(body + '\n\nPlease try again'),
          actions: <Widget>[
            FlatButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  signInwithEmailAndPassword() async {
    try {
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      FirebaseUser user = result.user;

      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);
      await _storeUser(user);
      print('the user.id is');
      print(user.uid);
      print('the currentUser.id is');
      print(currentUser.uid);
      _userFromFirebaseUser(user);
      _setRoute();
      _storeUser(user);

      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      _erroDialog('Error Occured', e.message.toString());

      return null;
    }
  }

  _storeUser(FirebaseUser user) async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      checkValue = true;
      sharedPreferences.setBool("check", checkValue);
      sharedPreferences.setString("username", user.displayName);
      sharedPreferences.setString('email', user.email);
      sharedPreferences.setString('phone', user.phoneNumber);
      sharedPreferences.setString("password", password);
    });
  }

  void _setRoute() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    print('user :' + user.uid);
    if (user != null) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacementNamed('/sign');
      _erroDialog('User not found', 'You are not added as an user');
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      resizeToAvoidBottomPadding: true,
      drawer: null,
      body: Container(
        width: double.infinity,
        child: Form(
          key: _formkey,
          child: new Flex(
            direction: Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Expanded(
                //mainAxisAlignment: MainAxisAlignment.center,
                //children: <Widget>[
                flex: 3,
                child: Center(
                  child: Text(
                    "Hexanovate",
                    style: new TextStyle(fontSize: 30.0),
                  ),
                ),
                //],
              ),
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 10,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
                child: new TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: new InputDecoration(labelText: 'Email'),
                  validator: (val) => val.isEmpty ? 'Enter an Email' : null,
                  onChanged: (val) {
                    setState(() => email = val);
                  },
                  onSaved: (val) => email = val,
                ),
              ),
              new SizedBox(
                height: 15.0,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
                child: new TextFormField(
                  obscureText: true,
                  decoration: new InputDecoration(labelText: 'Password'),
                  validator: (val) =>
                      val.length < 6 ? 'Enter a password 6+ chars long' : null,
                  onChanged: (val) {
                    setState(() => password = val);
                  },
                  onSaved: (val) => password = val,
                ),
              ),
              new Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 20.0, right: 20.0, bottom: 10),
                            child: GestureDetector(
                              onTap: () async {
                                if (_formkey.currentState.validate()) {
                                  print('object');
                                  dynamic result =
                                      await signInwithEmailAndPassword();
                                  if (result == null) {
                                    _erroDialog('Error', 'error occured');
                                  }
                                }
                              },
                              child: new Container(
                                  alignment: Alignment.center,
                                  height: 60.0,
                                  decoration: new BoxDecoration(
                                      color: Color(0xFF18D191),
                                      borderRadius:
                                          new BorderRadius.circular(35.0)),
                                  child: new Text("Login",
                                      style: new TextStyle(
                                          fontSize: 20.0,
                                          color: Colors.white))),
                            ),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      child: new Text("Create A New Account ",
                          style: new TextStyle(
                              fontSize: 20.0,
                              color: Color(0xFF18D191),
                              fontWeight: FontWeight.bold)),
                      onTap: () {
                        widget.toggleView();
                      },
                    )
                  ],
                ),
              ),
              Expanded(
                child: Divider(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
