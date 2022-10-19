import 'dart:convert';
import 'dart:core';
import 'dart:core';
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
import 'package:test/class/postpallet.dart';

class Supplier1 extends StatefulWidget {
  static String routeName = "/supplier1";
  @override
  _Supplier1State createState() => _Supplier1State();
}

class _Supplier1State extends State<Supplier1> {
  TextEditingController itrController = TextEditingController();
  TextEditingController scanController = TextEditingController();
  late Timer timer;
  Color itrColor = Color(0xFFFFFFFF);
  Color ScanColor = Color(0xFFFFFFFF);
  bool itrReadonly = false;
  bool scanReadonly = false;
  bool postEnabled = false;
  int step = 0;
  int max = 0;
  List<String> list = [];
  bool itrVisible = false;
  bool scanVisible = false;
  bool listVisible = false;
  int toong = 0;
  String showScanner = '';
  bool showCamera = false;
  late List<FocusNode> focusNodes = List.generate(3, (index) => FocusNode());
  String usernameUser = "";

  @override
  void initState() {
    super.initState();
    setState(() {
      step = 0;
    });
    getConfigs();
    setVisible();
    setReadOnly();
    setColor();
    setText();
    setFocus();
  }

  Future<void> getConfigs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      max = prefs.getInt('maxSupplier1');
      showScanner = prefs.getString('showScanner');
      usernameUser = prefs.getString('username');
    });

    if (showScanner == 'NO CAMERA') {
      setState(() {
        showCamera = false;
      });
    } else if (showScanner == 'HAVE CAMERA') {
      setState(() {
        showCamera = true;
      });
    }
  }

  void setVisible() {
    if (step == 0) {
      setState(() {
        itrVisible = true;
        scanVisible = false;
      });
    } else if (step == 1) {
      setState(() {
        itrVisible = true;
        scanVisible = true;
      });
    }
  }

  void setReadOnly() {
    if (step == 0) {
      setState(() {
        itrReadonly = false;
        scanReadonly = false;
        postEnabled = false;
      });
    } else if (step == 1) {
      setState(() {
        itrReadonly = true;
        scanReadonly = false;
        postEnabled = false;
      });
    } else if (step == 2) {
      setState(() {
        itrReadonly = true;
        scanReadonly = true;
        postEnabled = true;
      });
    }
  }

  void setColor() {
    if (step == 0) {
      setState(() {
        itrColor = Color(0xFFFFFFFF);
        ScanColor = Color(0xFFFFFFFF);
      });
    } else if (step == 1) {
      setState(() {
        itrColor = Color(0xFFEEEEEE);
        ScanColor = Color(0xFFFFFFFF);
      });
    } else if (step == 2) {
      setState(() {
        itrColor = Color(0xFFEEEEEE);
        ScanColor = Color(0xFFEEEEEE);
      });
    }
  }

  void setText() {
    if (step == 0) {
      setState(() {
        itrController.text = "";
        scanController.text = "";
      });
    } else if (step == 1) {
      setState(() {
        scanController.text = "";
      });
    }
  }

  void setFocus() {
    if (step == 0) {
      Future.delayed(Duration(milliseconds: 100))
          .then((_) => FocusScope.of(context).requestFocus(focusNodes[0]));
    } else if (step == 1) {
      Future.delayed(Duration(milliseconds: 100))
          .then((_) => FocusScope.of(context).requestFocus(focusNodes[1]));
    } else if (step == 2) {
      Future.delayed(Duration(milliseconds: 100))
          .then((_) => FocusScope.of(context).requestFocus(focusNodes[2]));
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
    if (itrController.text.length != 13) {
      showErrorDialog('Please Enter ITR 13 LETTERS');
      setVisible();
      setReadOnly();
      setColor();
      setText();
      setFocus();
      return;
    }
    setState(() {
      step++;
    });
    setVisible();
    setReadOnly();
    setColor();
    setText();
    setFocus();
  }

  Future<void> checkScan() async {
    if (scanController.text.toString() == '-1') {
      setState(() {
        scanController.text = '';
      });
      return;
    }
    int temp = 0;
    setState(() {
      temp = int.parse(scanController.text.toString());
      scanController.text = temp.toString();
    });
    for (int i = 0; i < list.length; i++) {
      if (list[i] == scanController.text.toString()) {
        showErrorDialog('Data Duplicate!');
        setVisible();
        setReadOnly();
        setColor();
        setText();
        setFocus();
        return;
      }
    }
    setState(() {
      list.add(scanController.text.toString());
      scanController.text = '';
    });
    if (list.length != 0) {
      setState(() {
        listVisible = true;
      });
    }

    if (list.length == max) {
      setState(() {
        step++;
      });
    }
    setVisible();
    setReadOnly();
    setColor();
    setText();
    setFocus();
  }

  Future<void> post() async {
    late List<PostPallet?> listpallet = [];
    for (int i = 0; i < list.length; i++) {
      late PostPallet? pallet = new PostPallet();
      setState(() {
        pallet.iTRNo = itrController.text.toString();
        pallet.rFID = list[i];
        pallet.rFIDHEX = list[i];
        pallet.scanBy = usernameUser;
        pallet.createdTime = DateTime.now().toString();
        listpallet.add(pallet);
      });
    }

    final uri = Uri.parse(
        'http://selene.hms-cloud.com:8088/API/api/receivedpallet/create');
    final headers = {'Content-Type': 'application/json'};
    var jsonBody = jsonEncode(listpallet);
    final encoding = Encoding.getByName('utf-8');
    http.Response response = await http.post(
      uri,
      headers: headers,
      body: jsonBody,
      encoding: encoding,
    );

    print(jsonBody);

    if (response.statusCode != 200) {
      showErrorDialog('Error Http Request');
      return;
    }

    var data = json.decode(response.body);
    setState(() {
      String temp = response.body
          .toString()
          .substring(1, response.body.toString().length - 1);
      toong = int.parse(temp);
    });
    print(data.toString());
    setState(() {
      step = 0;
      list.clear();
      listVisible = false;
    });
    showSuccessDialog("POST SUCCESFUL!");
    setVisible();
    setReadOnly();
    setColor();
    setText();
    setFocus();
  }

  Future<void> scanQR() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    if (step == 1) {
      setState(() {
        scanController.text = barcodeScanRes;
      });
      checkScan();
    }
  }

  Widget _firstWidget() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment:
              MainAxisAlignment.center, //Center Row contents horizontally,
          crossAxisAlignment:
              CrossAxisAlignment.center, //Center Row contents vertically,
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height / 14,
              width: MediaQuery.of(context).size.width / 3.5,
              child: OutlineButton(
                child: Text(
                  "No. " + toong.toString(),
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
                  MediaQuery.of(context).size.width / 6,
                  MediaQuery.of(context).size.width /
                      6), // button width and height
              child: ClipOval(
                child: Material(
                  color: Colors.orange[300], // button color
                  child: InkWell(
                    splashColor: Colors.green, // splash color
                    onTap: () {
                      setState(() {
                        step = 0;
                        list.clear();
                        listVisible = false;
                      });
                      setVisible();
                      setReadOnly();
                      setColor();
                      setText();
                      setFocus();
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
          height: 16,
        ),
        TextFormField(
          keyboardType: TextInputType.number,
          focusNode: focusNodes[0],
          maxLength: 13,
          onFieldSubmitted: (value) {
            if (value.isNotEmpty) {
              checkITR();
            }
          },
          readOnly: itrReadonly,
          controller: itrController,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            fillColor: itrColor,
            filled: true,
            hintText: "Please Enter ITR",
            prefixIcon: Icon(
              Icons.assessment_outlined,
              size: 26,
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
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment:
              MainAxisAlignment.center, //Center Row contents horizontally,
          crossAxisAlignment:
              CrossAxisAlignment.center, //Center Row contents vertically,
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height / 14,
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
          ],
        ),
      ],
    );
  }

  Widget _secondWidget() {
    return Column(children: <Widget>[
      TextFormField(
        focusNode: focusNodes[1],
        keyboardType: TextInputType.number,
        //maxLength: 13,
        onFieldSubmitted: (value) {
          if (value.isNotEmpty) {
            checkScan();
          }
        },
        readOnly: scanReadonly,
        controller: scanController,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          fillColor: ScanColor,
          filled: true,
          hintText: "Please Scan",
          prefixIcon: Icon(
            Icons.document_scanner_outlined,
            size: 26,
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
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      SizedBox(
        height: 16,
      ),
      Row(
        mainAxisAlignment:
            MainAxisAlignment.center, //Center Row contents horizontally,
        crossAxisAlignment:
            CrossAxisAlignment.center, //Center Row contents vertically,
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height / 12,
            width: MediaQuery.of(context).size.width / 3.5,
            child: new RaisedButton(
              focusNode: focusNodes[2],
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
            width: MediaQuery.of(context).size.width / 8,
          ),
          Visibility(
              visible: showCamera,
              child: SizedBox.fromSize(
                size: Size(
                    MediaQuery.of(context).size.width / 6,
                    MediaQuery.of(context).size.width /
                        6), // button width and height
                child: ClipOval(
                  child: Material(
                    color: Colors.orange[300], // button color
                    child: InkWell(
                      splashColor: Colors.green, // splash color
                      onTap: () {}, // button pressed
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                              icon: Icon(
                                Icons.qr_code_scanner_rounded,
                                color: Colors.black,
                              ),
                              onPressed: scanQR)
                        ],
                      ),
                    ),
                  ),
                ),
              ))
        ],
      ),
    ]);
  }

  Widget _showLists(BuildContext context) {
    return Visibility(
        visible: listVisible,
        child: SingleChildScrollView(
          child: Column(children: <Widget>[
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                int temp = index + 1;
                return Card(
                  child: ListTile(
                    leading: RawMaterialButton(
                      onPressed: () {
                        if (list.length == max) {
                          setState(() {
                            list.removeAt(index);
                            step--;
                          });
                          if (list.length == 0) {
                            setState(() {
                              listVisible = false;
                            });
                          }
                          setVisible();
                          setReadOnly();
                          setColor();
                          setText();
                          setFocus();
                        } else {
                          setState(() {
                            list.removeAt(index);
                          });
                          if (list.length == 0) {
                            setState(() {
                              listVisible = false;
                            });
                          }
                          setVisible();
                          setReadOnly();
                          setColor();
                          setText();
                          setFocus();
                        }
                      },
                      elevation: 1.0,
                      fillColor: Colors.white70,
                      child: Icon(
                        Icons.delete,
                        size: 35.0,
                        color: Colors.red,
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
                  Visibility(
                      visible: itrVisible,
                      child: Container(
                        padding: EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _firstWidget(),
                          ],
                        ),
                      )),
                  SizedBox(height: 14),
                  Visibility(
                    visible: scanVisible,
                    child: Container(
                      padding: EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _secondWidget(),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 14),
                  Visibility(
                      visible: listVisible,
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
