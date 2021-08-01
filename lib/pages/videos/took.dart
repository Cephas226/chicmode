import 'package:flutter/material.dart';
import 'package:getx_app/pages/dashboard/dashboard_page.dart';
import 'package:getx_app/pages/home/home_controller.dart';
import 'package:getx_app/pages/videos/trending.dart';
import 'package:get/get.dart';

class TokPage extends StatefulWidget {
  @override
  _TokPageState createState() => _TokPageState();
}
final HomeController _prodController = Get.put(HomeController());
class _TokPageState extends State<TokPage> {
  int currentIndex = 0;
  PageController pageController;

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
      appBar: AppBar(
        leading: new IconButton(
          color: Colors.black,
            icon: new Icon(Icons.arrow_back),
            onPressed: ()  {
              Get.off(()=>DashboardPage());
                  _prodController.createInterstitialAd()
                ..load()
                ..show();
            }
        ),
        title: Text(
          "Vidéos",
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: PageView(
        controller: pageController,
        children: <Widget>[
          Center(
            child: Trending(),
          ),
        ],
        onPageChanged: (int index) {
          setState(
                () {
              currentIndex = index;
            },
          );
        },
      ),
    );
  }
}