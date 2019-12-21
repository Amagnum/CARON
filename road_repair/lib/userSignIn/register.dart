import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:road_repair/Models/user.dart';
import 'package:road_repair/user%20data/database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Register extends StatefulWidget {
  final Function toggleView;
  Register({this.toggleView});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<Register> {
  String phoneNo;
  String email;
  String password;
  String username;
  String smsCode;
  String verificationId;
  bool isVerified = false;
  bool isLoading = false;
  String error = "";
  final myController = TextEditingController();
  AuthCredential credits;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formkey = GlobalKey<FormState>();

  User _userFromFirebaseUser(FirebaseUser user) {
    return user != null ? User(uid: user.uid) : null;
  }

  registerwithEmailAndPassword() async {
    try {
      setState(() {
        isLoading = true;
      });
      await verifyPhone();
      await smsCodeDialog(context).then((value) {
        print('Signed in');
      });
      FirebaseUser user = (await _auth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user;
      UserUpdateInfo info = new UserUpdateInfo();
      info.displayName = username;
      await user.updateProfile(info);
      if (credits == null) {
        await user.delete();
        setState(() {
          isLoading = false;
        });
        _erroDialog(
            'Verification failed', 'error occured during phone verification');
        return null;
      }
      AuthResult result =
          await user.linkWithCredential(credits).catchError((error) async {
        await user.delete();
        _erroDialog('Verification failed', error.message.toString());
        setState(() {
          isLoading = false;
        });
        return null;
      });
      user = result.user;
      print(user.phoneNumber);
      if (user.phoneNumber == null) {
        await user.delete();
        _erroDialog(
            'Verification failed', 'error occured during phone verification');
        setState(() {
          isLoading = false;
        });
        return null;
      }
      assert(user != null);
      assert(await user.getIdToken() != null);
      print(user.uid);
      //create a   document for the   user with the received uid
      await DatabaseService(uid: user.uid)
          .updateUserData(user.uid, username, email, password, phoneNo);
      await _storeUser(true);
      setState(() {
        isLoading = false;
      });
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      _erroDialog('Error occured in registration', e.message.toString());
      setState(() {
        isLoading = false;
      });
      return null;
    }
  }

  _storeUser(bool value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      sharedPreferences.setBool("check", value);
      sharedPreferences.setString("username", username);
      sharedPreferences.setString("email", email);
      sharedPreferences.setString('phone', phoneNo);
      sharedPreferences.setString("password", password);
    });
  }

  Future<void> verifyPhone() async {
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      this.verificationId = verId;
    };

    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
      setState(() {
        verificationId = verId;
      });
    };

    final PhoneVerificationCompleted verifiedSuccess =
        (AuthCredential credential) {
      print('verified');
      setState(() {
        credits = credential;
        isVerified = true;
      });
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
          return AlertDialog(
            title: Text('Enter sms Code'),
            content: ListView(
              shrinkWrap: true,
              children: <Widget>[
                isVerified
                    ? Text('Auto Verified')
                    : TextField(
                        controller: myController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        onChanged: (value) {},
                      ),
              ],
            ),
            contentPadding: EdgeInsets.all(10.0),
            actions: <Widget>[
              FlatButton(
                child: Text('Done'),
                onPressed: () async {
                  if (isVerified) {
                    Navigator.of(context).pop();
                  } else {
                    await signIn();
                    Navigator.of(context).pop();
                  }
                },
              )
            ],
          );
        });
  }

  Future<AuthCredential> signIn() async {
    try {
      final AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: verificationId,
        smsCode: myController.text,
      );
      //FirebaseUser user =
      //  (await FirebaseAuth.instance.signInWithCredential(credential)).user;
      if (credential != null) {
        setState(() {
          credits = credential;
        });
        return credential;
      } else
        return null;
    } catch (e) {
      print(e.toString());
      _erroDialog('Error', e.message.toString());
      return null;
    }
  }

  void _erroDialog(String title, String body) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: body == null
              ? Text('success')
              : Text(body + '\n\nPlease try again'),
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
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      body: Stack(
        children: <Widget>[
          Container(
            width: double.infinity,
            child: Form(
              key: _formkey,
              child: ListView(
                //crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 80.0, bottom: 80.0),
                        child: Text(
                          "Hexanovate",
                          style: TextStyle(fontSize: 30.0),
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 0.0),
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Username'),
                      validator: (val) => val.isEmpty ? 'Enter Username' : null,
                      onChanged: (val) {
                        setState(() => username = val);
                      },
                      onSaved: (val) => username = val,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 0.0),
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(labelText: 'Email'),
                      validator: (val) => val.isEmpty ? 'Enter an Email' : null,
                      onChanged: (val) {
                        setState(() => email = val);
                      },
                      onSaved: (val) => email = val,
                    ),
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 0.0),
                    child: TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(labelText: 'Set Password'),
                      validator: (val) => val.length < 6
                          ? 'Enter a password 6+ chars long'
                          : null,
                      onChanged: (val) {
                        setState(() => password = val);
                      },
                      onSaved: (val) => password = val,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 0.0),
                    child: TextFormField(
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(labelText: 'Phone Number'),
                      validator: (val) => validateMobile(val),
                      initialValue: '+91',
                      onChanged: (val) {
                        setState(() => phoneNo = val);
                      },
                      onSaved: (val) => phoneNo = val,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 20.0, right: 20.0, top: 15.0, bottom: 10),
                          child: GestureDetector(
                            onTap: () async {
                              if (_formkey.currentState.validate()) {
                                dynamic result =
                                    await registerwithEmailAndPassword();
                                if (result != null) {
                                  Navigator.pushReplacementNamed(
                                      context, '/init');
                                  _erroDialog('Registration successful', null);
                                }
                                if (result == null) {
                                  _erroDialog(
                                      'Registration Failed', 'Error occured!');
                                }
                              }
                            },
                            child: Container(
                                alignment: Alignment.center,
                                height: 60.0,
                                decoration: BoxDecoration(
                                    color: Color(0xFF18D191),
                                    borderRadius: BorderRadius.circular(35.0)),
                                child: Text("Register",
                                    style: TextStyle(
                                        fontSize: 20.0, color: Colors.white))),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Padding(
                          padding: const EdgeInsets.only(bottom: 60.0),
                          child: GestureDetector(
                            child: Text("Already registered ? Sign In ",
                                style: TextStyle(
                                    fontSize: 20.0,
                                    color: Color(0xFF18D191),
                                    fontWeight: FontWeight.bold)),
                            onTap: () {
                              widget.toggleView();
                            },
                          )),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  String validateMobile(String value) {
    String patttern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = RegExp(patttern);
    if (value.length == 0) {
      return 'Please enter mobile number';
    } else if (!regExp.hasMatch(value)) {
      return 'Please enter valid mobile number';
    }
    return null;
  }
}
