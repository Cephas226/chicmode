import 'dart:typed_data';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:favorite_button/favorite_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:getx_app/pages/categories/categories_controller.dart';
import 'package:getx_app/pages/home/home_page.dart';
import 'package:getx_app/services/backend_service.dart';
import 'package:getx_app/widget/photo_widget/photohero.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:share/share.dart';
import 'dart:math' as math;
import 'package:transparent_image/transparent_image.dart';
import 'package:http/http.dart' as http;
class CategoriesPage extends GetView<CategoriesController> {
  List homme;
  List femme;
  List couple;
  List enfant;
  final CategoriesController _catController = Get.put(CategoriesController());

  Widget _gestureDetector(BuildContext context,String param1,String param2,String assetUrl){
    return  GestureDetector(
      onTap: (){
        Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return
                Scaffold(
                    appBar: AppBar(
                      title: const Text('Photo'),
                      backgroundColor: Color(0xFFF70759),
                    ),
                    body:Center(
                      child:
                      FutureBuilder(
                          future: Dataservices.fetchProductx(),
                          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                            List xCriteria;
                            if (snapshot.hasData){
                              xCriteria=snapshot.data.where((o) => o[param1] == param2).toList();
                            }
                            return snapshot.hasData ?
                            GridView.builder(
                              itemCount:xCriteria.length,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: MediaQuery.of(context).orientation ==
                                    Orientation.landscape ? 3: 3,
                                crossAxisSpacing: 2,
                                mainAxisSpacing: 2,
                              ),
                              itemBuilder: (context,index,) {
                                return
                                  GestureDetector(
                                    onTap:(){
                                      Get.to(()=>Scaffold(
                                        floatingActionButton: buildSpeedDial(),
                                        appBar: AppBar(
                                          backgroundColor: Color(0xFFF70759),
                                          title: const Text('Details'),
                                        ),
                                        body: CarouselSlider.builder(
                                          itemCount: xCriteria.length,
                                          options: CarouselOptions(
                                            height: 800,
                                            scrollDirection: Axis.vertical,
                                            initialPage: index,
                                            viewportFraction: 1,
                                            aspectRatio: 16 / 9,
                                            enableInfiniteScroll: true,
                                            autoPlay: false,
                                          ),
                                          itemBuilder: (BuildContext context, int itemIndex,
                                              int pageViewIndex) =>
                                              Stack(
                                                children: <Widget>[
                                                  Card(
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadiusDirectional.circular(20)),
                                                    clipBehavior: Clip.antiAlias,
                                                    child: Container(
                                                      padding: const EdgeInsets.all(0.0),
                                                      height: double.infinity,
                                                      color: Color(0xFFF70759),
                                                      child: PhotoHero(
                                                        photo:xCriteria[itemIndex]["url"],
                                                        width: double.infinity,
                                                        height: double.infinity,
                                                        onTap: () {
                                                          Get.back();
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                      padding: EdgeInsets.only(bottom: 65, right: 10),
                                                      child: Align(
                                                          alignment: Alignment.bottomRight,
                                                          child: Container(
                                                            width: 70,
                                                            height: 400,
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                              children: <Widget>[
                                                                Container(
                                                                  padding: EdgeInsets.only(bottom: 25),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                    CrossAxisAlignment.center,
                                                                    children: <Widget>[
                                                                      Icon(Icons.favorite,
                                                                          size: 35, color: Colors.white),
                                                                      Text('427.9K',
                                                                          style: TextStyle(
                                                                              color: Colors.white))
                                                                    ],
                                                                  ),
                                                                ),
                                                                Container(
                                                                  padding: EdgeInsets.only(bottom: 20),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                    CrossAxisAlignment.center,
                                                                    children: <Widget>[
                                                                      Transform(
                                                                          alignment: Alignment.center,
                                                                          transform:
                                                                          Matrix4.rotationY(math.pi),
                                                                          child: Icon(Icons.sms,
                                                                              size: 35,
                                                                              color: Colors.white)),
                                                                      Text('2051',
                                                                          style: TextStyle(
                                                                              color: Colors.white))
                                                                    ],
                                                                  ),
                                                                ),
                                                                Container(
                                                                  padding: EdgeInsets.only(bottom: 50),
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                    CrossAxisAlignment.center,
                                                                    children: <Widget>[
                                                                      Transform(
                                                                          alignment: Alignment.center,
                                                                          transform:
                                                                          Matrix4.rotationY(math.pi),
                                                                          child: Icon(Icons.reply,
                                                                              size: 35,
                                                                              color: Colors.white)),
                                                                      Text('Partager',
                                                                          style: TextStyle(
                                                                              color: Colors.white))
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ))),
                                                ],
                                              ),
                                        ),
                                      ));
                                    },
                                    child:
                                    Card(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadiusDirectional
                                              .circular(20)),
                                      clipBehavior: Clip.antiAlias,
                                      child: FadeInImage.memoryNetwork(
                                          placeholder:
                                          kTransparentImage,
                                          image: xCriteria[index]["url"],
                                          fit: BoxFit.contain),
                                    )
                                  );
                              },
                            )
                                : Center (
                              child: Text(
                                  "Aucune image"
                              ),
                            );
                          }),
                    )
                );
            }
        ));
      },
      child: Stack(
        children: [
          Card(
            color: Colors.transparent,
            elevation: 0,
            child:
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                      image: AssetImage(assetUrl),
                      fit: BoxFit.cover)),
              child: Transform.translate(
                offset: Offset(50, -50),
                child:
                Container(
                  height: 100,
                  margin: EdgeInsets.symmetric(
                      horizontal: 65, vertical: 63),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.transparent),
                ),
              ),
            ),
          ),
          Positioned(
            left: 80,
            height: MediaQuery.of(context).size.height * 0.2,
            child: Center(
              child: Text(
                param2,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Raleway',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Catégories",
            style: TextStyle(color: Colors.black),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
        ),
      body: Container(
        child:
        ListView(
          padding: const EdgeInsets.all(1),
          children: <Widget>[
            _gestureDetector(context, "categorie", "Homme","assets/a.jpg"),
            _gestureDetector(context, "categorie", "Femme","assets/b.jpg"),
            _gestureDetector(context, "categorie", "Couple","assets/c.jpg"),
            _gestureDetector(context, "categorie", "Enfant","assets/d.jpg")
          ],
        ),
      ),
    );
  }


}

_saveImage(url, name, context) async {
  var client = http.Client();
  var response = await client.get(Uri.parse(url));
  final result = await ImageGallerySaver.saveImage(
      Uint8List.fromList(response.bodyBytes),
      quality: 60,
      name: "model" + name.toString());
  ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text('Image sauvegardée avec succès')));
  return result;
}

_shareImage(url, name, context) async {
  var client = http.Client();
  var response = await client.get(Uri.parse(url));
  final result = await ImageGallerySaver.saveImage(
      Uint8List.fromList(response.bodyBytes),
      quality: 60,
      name: "model" + name.toString());
  print(result["filePath"]);
  Share.shareFiles([
    result['filePath']
        .toString()
        .replaceAll(RegExp('file://'), '')
  ], text: 'Great picture');
}