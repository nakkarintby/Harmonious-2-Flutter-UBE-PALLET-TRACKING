import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:passcode_screen/circle.dart';
import 'package:passcode_screen/keyboard.dart';
import 'package:passcode_screen/passcode_screen.dart';
import 'package:location/location.dart';

class Supplier1 extends StatefulWidget {
  static String routeName = "/supplier1";
  @override
  _Supplier1State createState() => _Supplier1State();
}

class _Supplier1State extends State<Supplier1> {
  TextEditingController itrController = TextEditingController();
  late Timer timer;
  Color itrColor = Color(0xFFFFFFFF);
  bool itrReadonly = false;
  bool postEnabled = false;
  bool scanEnabled = false;
  int step = 0;
  int max = 0;
  List<String> list = [];
  bool showList = false;
  int palletnumber = 0;
  String showScanner = '';

  @override
  void initState() {
    super.initState();
    getConfigs();
    setEnable();
    setColor();
    setText();
  }

  Future<void> getConfigs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      max = prefs.getInt('maxSupplier1');
      showScanner = prefs.getString('showScanner');
    });
  }

  void setEnable() {
    if (step == 0) {
      setState(() {
        itrReadonly = false;
        postEnabled = false;
        scanEnabled = false;
      });
    } else if (step == 1) {
      setState(() {
        itrReadonly = true;
        postEnabled = false;
        scanEnabled = true;
      });
    } else if (step == 2) {
      setState(() {
        itrReadonly = true;
        postEnabled = true;
        scanEnabled = false;
      });
    }
  }

  void setColor() {
    if (step == 0) {
      setState(() {
        itrColor = Color(0xFFFFFFFF);
      });
    } else if (step == 1) {
      setState(() {
        itrColor = Color(0xFFEEEEEE);
      });
    }
  }

  void setText() {
    if (step == 0) {
      setState(() {
        itrController.text = "";
      });
    }
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

  Future<void> checkITR() async {
    //call api set list

    setState(() {
      list.clear();
      step++;
    });
    setEnable();
    setColor();
    setText();
  }

  Future<void> scan() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (barcodeScanRes.isNotEmpty) {
      for (int i = 0; i < list.length; i++) {
        if (list[i] == barcodeScanRes) {
          showErrorDialog('Data Duplicate!');
          return;
        }
      }
      setState(() {
        list.add(barcodeScanRes);
      });

      if (list.length == max) {
        setState(() {
          step++;
        });
        setEnable();
        setColor();
        setText();
      }
    }
  }

  Future<void> post() async {
    showSuccessDialog("POST SUCCESFUL!");
    setState(() {
      step = 0;
      list.clear();
    });
    setEnable();
    setColor();
    setText();
  }

  Widget _entryFieldITR(String title, {bool isPassword = false}) {
    return TextFormField(
      //keyboardType: TextInputType.number,
      //maxLength: 10,
      onFieldSubmitted: (value) {
        if (value.isNotEmpty) {
          checkITR();
        }
      },
      readOnly: itrReadonly,
      controller: itrController,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        fillColor: itrColor,
        filled: true,
        hintText: "Please Enter ITR",
        prefixIcon: Icon(
          Icons.assessment_outlined,
          size: 32,
          color: Colors.green,
        ),
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

  Widget _contextWidget() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment:
              MainAxisAlignment.center, //Center Row contents horizontally,
          crossAxisAlignment:
              CrossAxisAlignment.center, //Center Row contents vertically,
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height / 10,
              width: MediaQuery.of(context).size.width / 3.5,
              child: OutlineButton(
                child: Text(
                  "No. " + palletnumber.toString(),
                  style: TextStyle(fontSize: 20.0),
                ),
                highlightedBorderColor: Colors.green,
                textColor: Colors.green,
                disabledTextColor: Colors.green[50],
                color: Colors.green[50],
                focusColor: Colors.green[50],
                hoverColor: Colors.green[50],
                highlightColor: Colors.green[50],
                splashColor: Colors.green[50],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                onPressed: () {},
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 8,
            ),
            SizedBox.fromSize(
              size: Size(
                  MediaQuery.of(context).size.width / 5,
                  MediaQuery.of(context).size.width /
                      5), // button width and height
              child: ClipOval(
                child: Material(
                  color: Colors.orange[300], // button color
                  child: InkWell(
                    splashColor: Colors.green, // splash color
                    onTap: () {
                      setState(() {
                        step = 0;
                        list.clear();
                      });
                      setEnable();
                      setColor();
                      setText();
                    }, // button pressed
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.add_box), // icon
                        Text("New"), // text
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
        SizedBox(
          height: 35,
        ),
        _entryFieldITR("ITR NUMBER", isPassword: false),
        SizedBox(
          height: 35,
        ),
        Row(
          mainAxisAlignment:
              MainAxisAlignment.center, //Center Row contents horizontally,
          crossAxisAlignment:
              CrossAxisAlignment.center, //Center Row contents vertically,
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height / 10,
              width: MediaQuery.of(context).size.width / 3.5,
              child: OutlineButton(
                child: Text(
                  list.length.toString() + " / " + max.toString(),
                  style: TextStyle(fontSize: 20.0),
                ),
                highlightedBorderColor: Colors.green,
                textColor: Colors.green,
                disabledTextColor: Colors.green[50],
                color: Colors.green[50],
                focusColor: Colors.green[50],
                hoverColor: Colors.green[50],
                highlightColor: Colors.green[50],
                splashColor: Colors.green[50],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                onPressed: () {},
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width / 8,
            ),
            SizedBox.fromSize(
              size: Size(
                  MediaQuery.of(context).size.width / 7,
                  MediaQuery.of(context).size.width /
                      7), // button width and height
              child: ClipOval(
                child: Material(
                  color: Colors.orange[300], // button color
                  child: InkWell(
                    splashColor: Colors.green, // splash color
                    onTap: () {
                      setState(() {
                        showList = !showList;
                      });
                    }, // button pressed
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          showList ? Icons.arrow_upward : Icons.arrow_downward,
                        ), // text
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
        SizedBox(
          height: 35,
        ),
        Row(
          mainAxisAlignment:
              MainAxisAlignment.center, //Center Row contents horizontally,
          crossAxisAlignment:
              CrossAxisAlignment.center, //Center Row contents vertically,
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height / 10,
              width: MediaQuery.of(context).size.width / 3.5,
              child: new RaisedButton(
                color: Colors.blue,
                child: const Text('POST',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    )),
                onPressed: postEnabled
                    ? () async {
                        await post();
                      }
                    : null,
              ),
            ),
            SizedBox(
              width: 15,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 10,
              width: MediaQuery.of(context).size.width / 3.5,
              child: new RaisedButton(
                color: Colors.green,
                child: const Text('SCAN',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    )),
                onPressed: scanEnabled
                    ? () async {
                        await scan();
                      }
                    : null,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 15,
        ),
      ],
    );
  }

  Widget _showLists(BuildContext context) {
    return Visibility(
        visible: showList,
        child: SingleChildScrollView(
          physics: ScrollPhysics(),
          child: Column(children: <Widget>[
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                int temp = index + 1;
                return Card(
                  child: ListTile(
                    leading: RawMaterialButton(
                      onPressed: () {},
                      elevation: 1.0,
                      fillColor: Colors.amber[100],
                      child: Icon(
                        Icons.assessment_outlined,
                        size: 35.0,
                        color: Colors.blue,
                      ),
                      padding: EdgeInsets.all(10.0),
                      shape: CircleBorder(),
                    ),
                    title: Text(temp.toString()),
                    subtitle: Text(list[index].toString()),
                  ),
                );
              },
              itemCount: list.length,
              shrinkWrap: true,
              padding: EdgeInsets.all(5),
              scrollDirection: Axis.vertical,
            ),
          ]),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  Container(
                    padding: EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _contextWidget(),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),
                  Visibility(
                      visible: showList,
                      child: Container(
                        padding: EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _showLists(context),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
        )));
  }
}

/*WillPopScope(
        onWillPop: () async {
          return exit(0);
        },
        child: */
