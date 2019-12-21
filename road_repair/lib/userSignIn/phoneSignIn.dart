import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:road_repair/Models/user.dart';

class PhoneAuthentication extends StatefulWidget {
  final String phone;
  final registerUser;

  const PhoneAuthentication(
      {Key key, @required this.registerUser, @required this.phone})
      : super(key: key);
  @override
  _PhoneAuthenticationPageState createState() =>
      new _PhoneAuthenticationPageState();
}

class _PhoneAuthenticationPageState extends State<PhoneAuthentication> {
  String phoneNo;
  String smsCode;
  String verificationId;
  bool isPhoneVerified = false;
  bool isSmsSent = false;
  String error = '';
  FirebaseAuth _auth = FirebaseAuth.instance;
  final _formkey = GlobalKey<FormState>();
  final myController = TextEditingController();
  @override
  void initState() {
    super.initState();
    this.phoneNo = widget.phone;
  }

  Future<void> verifyPhone() async {
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      this.verificationId = verId;
    };

    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
      setState(() {
        isSmsSent = true;
      });
      smsCodeDialog(context).then((value) {
        print('Signed in');
      });
    };

    final PhoneVerificationCompleted verifiedSuccess =
        (AuthCredential credential) {
      widget.registerUser(credential);
      setState(() {
        isPhoneVerified = true;
      });
      print('verified');
    };

    final PhoneVerificationFailed veriFailed = (AuthException exception) {
      print('${exception.message}');
      _erroDialog('Error', exception.message);
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
      codeSent: smsCodeSent,
      phoneNumber: this.phoneNo,
      timeout: const Duration(seconds: 5),
      verificationCompleted: verifiedSuccess,
      verificationFailed: veriFailed,
      codeAutoRetrievalTimeout: autoRetrieve,
    );
  }

  Future<bool> smsCodeDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text('Enter sms Code'),
            content: TextField(
              controller: myController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              onChanged: (value) {
                if (myController.text == value) {
                  this.smsCode = value;
                  print(myController.text.toString());
                } else if (myController.text != value) {
                  setState(() => error = 'Wrong OTP entered');
                  print(myController.text.toString());
                } else if (myController.text == '') {
                  setState(() => error = 'Please enter the OTP');
                  print(myController.text.toString());
                }
              },
            ),
            contentPadding: EdgeInsets.all(10.0),
            actions: <Widget>[
              new FlatButton(
                child: Text('Done'),
                onPressed: () async {
                  FirebaseAuth.instance.currentUser().then((user) async {
                    if (user != null) {
                      await signIn();
                      Navigator.pop(context);
                    } else {
                      await signIn();
                      Navigator.pop(context);
                    }
                  }).catchError((onError) {
                    Navigator.pop(context);
                    _erroDialog('Error', onError.toString());
                  });
                },
              )
            ],
          );
        });
  }

  User _userFromFirebaseUser(FirebaseUser user) {
    // User is a class through which data is sent back/retreived to firebase authentication
    return user != null ? User(uid: user.uid) : null;
  }

  Future<bool> signIn() async {
    try {
      final AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      if (credential.providerId != null) {
        FirebaseUser user = await widget.registerUser(credential);
        final FirebaseUser currentUser = await _auth.currentUser();
        assert(user.uid == currentUser.uid);
        _userFromFirebaseUser(user);
        if (user != null) {
          setState(() {
            isPhoneVerified = true;
          });
          return true;
        } else
          return false;
      }
      return false;
    } catch (e) {
      print(e.toString());
      _erroDialog('Error', e.message.toString());
      return false;
    }
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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: new AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          iconTheme: new IconThemeData(color: Color(0xFF18D191))),
      body: Container(
        width: double.infinity,
        child: Form(
          key: _formkey,
          child: new Flex(
            direction: Axis.vertical,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 100.0, bottom: 80.0),
                    child: new Text(
                      "Hexanovate",
                      style: new TextStyle(fontSize: 30.0),
                    ),
                  )
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
                child: new TextFormField(
                  decoration: InputDecoration(hintText: 'Enter Phone number'),
                  initialValue: widget.phone,
                  readOnly: true,
                  validator: (val) => validateMobile(
                      val), // validateMobile() is the function made to check weather the entered phone number is correct
                  onChanged: (value) {
                    this.phoneNo = value;
                  },
                  onSaved: (val) => phoneNo = val,
                ),
              ),
              new SizedBox(
                height: 15.0,
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, right: 20.0, top: 15.0),
                      child: GestureDetector(
                        onTap: isPhoneVerified
                            ? () {
                                Navigator.pushReplacementNamed(
                                    context, '/home');
                              }
                            : () async {
                                if (_formkey.currentState.validate()) {
                                  verifyPhone();
                                }
                              },
                        child: new Container(
                            alignment: Alignment.center,
                            height: 60.0,
                            decoration: new BoxDecoration(
                                color: Color(0xFF18D191),
                                borderRadius: new BorderRadius.circular(35.0)),
                            child: new Text(
                                isPhoneVerified ? 'Continue' : "verify",
                                style: new TextStyle(
                                    fontSize: 20.0, color: Colors.white))),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String validateMobile(String value) {
    String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = new RegExp(patttern);
    if (value.length == 0) {
      return 'Please enter mobile number';
    } else if (!regExp.hasMatch(value)) {
      return 'Please enter valid mobile number';
    }
    return null;
  }
}
