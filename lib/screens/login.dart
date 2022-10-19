import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:test/screens/menu.dart';

class Login extends StatefulWidget {
  static String routeName = "/login";
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController usernameController = TextEditingController();
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  late Timer timer;
  double version = 1.0;

  TextEditingController supplier1Controller = TextEditingController();
  TextEditingController supplier2Controller = TextEditingController();
  TextEditingController supplier3Controller = TextEditingController();
  late List<FocusNode> focusNodes = List.generate(5, (index) => FocusNode());

  int maxSupplier1 = 0;
  int maxSupplier2 = 0;
  int maxSupplier3 = 0;
  String showScanner = '';

  @override
  void initState() {
    super.initState();
    setConfigs();
  }

  Future<void> setConfigs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool maxSupplier1Prefs = prefs.containsKey('maxSupplier1');
    bool maxSupplier2Prefs = prefs.containsKey('maxSupplier2');
    bool maxSupplier3Prefs = prefs.containsKey('maxSupplier3');
    bool showScannerPrefs = prefs.containsKey('showScanner');

    if (maxSupplier1Prefs &&
        maxSupplier2Prefs &&
        maxSupplier3Prefs &&
        showScannerPrefs) {
      setState(() {
        maxSupplier1 = prefs.getInt('maxSupplier1');
        maxSupplier2 = prefs.getInt('maxSupplier2');
        maxSupplier3 = prefs.getInt('maxSupplier3');
        showScanner = prefs.getString('showScanner');
      });
    } else {
      prefs.setInt('maxSupplier1', 0);
      prefs.setInt('maxSupplier2', 0);
      prefs.setInt('maxSupplier3', 0);
      prefs.setString('showScanner', 'NO CAMERA');
      setState(() {
        showScanner = prefs.getString('showScanner');
      });
    }
  }

  Future<void> editConfigs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Icon icon = Icon(Icons.edit, color: Colors.lightBlue);

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Row(children: [icon, Text(" " + 'Edit Configs')]),
            content: SingleChildScrollView(
                child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  focusNode: focusNodes[0],
                  //autofocus: true, //set initail focus on dialog
                  keyboardType: TextInputType.number,
                  readOnly: false,
                  controller: supplier1Controller
                    ..text = prefs.getInt('maxSupplier1').toString(),
                  decoration: InputDecoration(
                      labelText: 'GoodPack', hintText: "Enter max Good-Pack"),
                  textInputAction: TextInputAction.next,
                  onEditingComplete: () {
                    Future.delayed(Duration(milliseconds: 100)).then((_) =>
                        FocusScope.of(context).requestFocus(focusNodes[1]));
                  },
                ),
                TextFormField(
                  focusNode: focusNodes[1],
                  //autofocus: true, //set initail focus on dialog
                  keyboardType: TextInputType.number,
                  readOnly: false,
                  controller: supplier2Controller
                    ..text = prefs.getInt('maxSupplier2').toString(),
                  decoration: InputDecoration(
                      labelText: 'GPS', hintText: "Enter max GPS"),
                  textInputAction: TextInputAction.next,
                  onEditingComplete: () {
                    Future.delayed(Duration(milliseconds: 100)).then((_) =>
                        FocusScope.of(context).requestFocus(focusNodes[2]));
                  },
                ),
                TextFormField(
                  focusNode: focusNodes[2],
                  //autofocus: true, //set initail focus on dialog
                  keyboardType: TextInputType.number,
                  readOnly: false,
                  controller: supplier3Controller
                    ..text = prefs.getInt('maxSupplier3').toString(),
                  decoration: InputDecoration(
                      labelText: 'CIMC', hintText: "Enter max CIMC "),
                  textInputAction: TextInputAction.next,
                  onEditingComplete: () {
                    Future.delayed(Duration(milliseconds: 100)).then((_) =>
                        FocusScope.of(context).requestFocus(focusNodes[3]));
                  },
                ),
                SizedBox(
                  height: 25,
                ),
                new DropdownButton<String>(
                  focusNode: focusNodes[3],
                  isDense: true,
                  isExpanded: true,
                  value: showScanner,
                  items:
                      <String>['NO CAMERA', 'HAVE CAMERA'].map((String value) {
                    return new DropdownMenuItem<String>(
                      value: value,
                      child: new Text(value),
                    );
                  }).toList(),
                  onTap: () {
                    FocusScope.of(context).requestFocus(new FocusNode());
                  },
                  onChanged: (String? val) {
                    setState(() {
                      showScanner = val!;
                    });
                    Future.delayed(Duration(milliseconds: 100)).then((_) =>
                        FocusScope.of(context).requestFocus(focusNodes[4]));
                  },
                ),
              ],
            )),
            actions: <Widget>[
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text('Cancel'),
                onPressed: () {
                  setState(() {
                    showScanner = prefs.getString('showScanner');
                    Navigator.pop(context);
                  });
                },
              ),
              FlatButton(
                focusNode: focusNodes[4],
                color: Colors.green,
                textColor: Colors.white,
                child: Text('Save'),
                onPressed: () {
                  setState(() {
                    prefs.setInt(
                        'maxSupplier1', int.parse(supplier1Controller.text));
                    prefs.setInt(
                        'maxSupplier2', int.parse(supplier2Controller.text));
                    prefs.setInt(
                        'maxSupplier3', int.parse(supplier3Controller.text));
                    prefs.setString('showScanner', showScanner);
                    Navigator.pop(context);
                  });
                  alertDialog('Edit Successful', 'Success');
                },
              ),
            ],
          );
        });
  }

  void alertDialog(String msg, String type) {
    Icon icon = Icon(Icons.info_outline, color: Colors.lightBlue);
    switch (type) {
      case "Success":
        icon = Icon(Icons.check_circle_outline, color: Colors.lightGreen);
        break;
      case "Error":
        icon = Icon(Icons.error_outline, color: Colors.redAccent);
        break;
      case "Warning":
        icon = Icon(Icons.warning_amber_outlined, color: Colors.orangeAccent);
        break;
      case "Infomation":
        icon = Icon(Icons.info_outline, color: Colors.lightBlue);
        break;
    }

    showDialog(
        context: context,
        builder: (BuildContext builderContext) {
          timer = Timer(Duration(seconds: 5), () {
            Navigator.of(context, rootNavigator: true).pop();
          });

          return AlertDialog(
            title: Row(children: [icon, Text(" " + type)]),
            content: Text(msg),
          );
        }).then((val) {
      if (timer.isActive) {
        timer.cancel();
      }
    });
  }

  void showErrorDialog(String error) {
    alertDialog(error, 'Error');
  }

  void showSuccessDialog(String success) {
    alertDialog(success, 'Success');
  }

  Future<void> checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      Timer(Duration(seconds: 3), () async {
        if (usernameController.text.toString().length == 10) {
          prefs.setString('username', usernameController.text.toString());
          _btnController.reset();
          usernameController.text = '';
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Menu()));
        } else {
          _btnController.reset();
          usernameController.text = '';
          showErrorDialog('Please Enter username');
        }
      });
    } catch (e) {
      Navigator.pushReplacementNamed(context, Login.routeName);
    }
  }

  Widget _titleWidget() {
    return Container(
        height: MediaQuery.of(context).size.height * 0.15,
        width: MediaQuery.of(context).size.width * .55,
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade50,
          shape: BoxShape.circle,
        ),
        child: Image.asset(
          'assets/UBE_LOGO.png',
          height: MediaQuery.of(context).size.height * 0.25,
          width: MediaQuery.of(context).size.width * .55,
          fit: BoxFit.cover,
        ));
  }

  Widget _editWidget() {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      height: size.height / 10,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            //top: MediaQuery.of(context).size.height / 1.135,
            right: MediaQuery.of(context).size.width / 4,
            child: ElevatedButton(
              onPressed: () {
                editConfigs();
              },
              child: const Icon(
                Icons.settings,
                size: 30,
              ),
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                padding: EdgeInsets.all(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomWidget() {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      height: size.height / 6,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            //top: MediaQuery.of(context).size.height / 1.135,
            right: MediaQuery.of(context).size.width / 2.5,
            child: Image.asset("assets/shms1.png", width: size.width * 0.38),
          ),
          Positioned(
            //top: MediaQuery.of(context).size.height / 1.135,
            right: MediaQuery.of(context).size.width / 80,
            child: ElevatedButton(
              onPressed: () {},
              child: Text(version.toString()),
              style: ElevatedButton.styleFrom(
                primary: Colors.red[400], //
                shape: CircleBorder(),
                padding: EdgeInsets.all(12),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _contextWidget() {
    return Column(
      children: <Widget>[
        _entryFieldusername("username Number", isPassword: false),
      ],
    );
  }

  Widget _entryFieldusername(String title, {bool isPassword = false}) {
    return TextFormField(
      keyboardType: TextInputType.number,
      maxLength: 10,
      controller: usernameController,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.perm_identity_outlined),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black12),
            borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black12),
            borderRadius: BorderRadius.circular(10)),
        prefix: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _LoginButtonWidget() {
    return InkWell(
      child: Container(
        width: MediaQuery.of(context).size.width / 1.5,
        padding: EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: RoundedLoadingButton(
            color: Colors.blue.shade300,
            successColor: Color(0xfffbb448).withAlpha(100),
            controller: _btnController,
            onPressed: () => checkLogin(),
            valueColor: Colors.black,
            child: Text('Login', style: TextStyle(color: Colors.white))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return exit(0);
        },
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Color(0xfff7f6fb),
            body: Container(
                child: SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24, horizontal: 32),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      _titleWidget(),
                      SizedBox(height: 32),
                      Container(
                        padding: EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _contextWidget(),
                            SizedBox(height: 8),
                            _LoginButtonWidget(),
                            SizedBox(height: 8),
                            _editWidget(),
                          ],
                        ),
                      ),
                      _bottomWidget(),
                    ],
                  ),
                ),
              ),
            ))));
  }
}
