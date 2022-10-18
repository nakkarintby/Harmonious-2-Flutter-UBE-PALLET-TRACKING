import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/components/menu_list2.dart';
import 'package:test/screens/Supplier1.dart';
import 'package:test/screens/supplier2.dart';
import 'package:test/screens/supplier3.dart';

class Menu extends StatefulWidget {
  static String routeName = "/menu";
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<Menu> {
  bool supplier1 = true;
  bool supplier2 = true;
  bool supplier3 = true;

  @override
  void initState() {
    super.initState();
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
            right: MediaQuery.of(context).size.width / 1.78,
            child: Image.asset("assets/shms1.png", width: size.width * 0.38),
          ),
          Positioned(
            //top: MediaQuery.of(context).size.height / 1.135,
            right: MediaQuery.of(context).size.width / 20,
            child: ElevatedButton(
              onPressed: () {},
              child: Text('1.0'),
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
        onWillPop: () async {
          return exit(0);
        },
        child: Scaffold(
          body: Container(
            constraints: BoxConstraints.expand(),
            decoration: BoxDecoration(
                image: new DecorationImage(
              image: new AssetImage("assets/hmc_background6.jpeg"),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.5), BlendMode.dstATop),
            )),
            alignment: Alignment.center,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: 50),
              child: Column(
                children: [
                  Visibility(
                    visible: supplier1,
                    child: MenuList2(
                      text: "Supplier-1",
                      imageIcon: ImageIcon(
                        AssetImage('assets/container.png'),
                        size: 45,
                        color: Colors.blue,
                      ),
                      press: () => {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Supplier1()))
                      },
                    ),
                  ),
                  Visibility(
                    visible: supplier2,
                    child: MenuList2(
                      text: "Supplier-2",
                      imageIcon: ImageIcon(
                        AssetImage('assets/transportation.png'),
                        size: 45,
                        color: Colors.blue,
                      ),
                      press: () => {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Supplier2()))
                      },
                    ),
                  ),
                  Visibility(
                    visible: supplier3,
                    child: MenuList2(
                      text: "Supplier-3",
                      imageIcon: ImageIcon(
                        AssetImage('assets/checkup.png'),
                        size: 45,
                        color: Colors.blue,
                      ),
                      press: () => {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Supplier3()))
                      },
                    ),
                  ),

                  //_bottomWidget(),
                ],
              ),
            ),
          ),
        ));
  }
}
