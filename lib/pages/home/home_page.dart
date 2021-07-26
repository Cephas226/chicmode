import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:getx_app/model/product_model.dart';
import 'package:getx_app/pages/videos/took.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math' as math;
import 'dart:io';
import 'package:getx_app/services/backend_service.dart';
import 'package:getx_app/widget/photo_widget/photohero.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:favorite_button/favorite_button.dart';
import '../../main.dart';
import 'home_controller.dart';

class HomePage extends GetView<HomeController> {
  final HomeController _prodController = Get.put(HomeController());
  CarouselController carouselController = new CarouselController();

  String titlexy = 'Accueil';
  List<String> imageList = [];
  var chipIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<String> _chipLabel = [
      'Tout',
      'Récent',
      'Mieux noté',
      'Aléatoire'
    ];
    return DefaultTabController(
      length: 3,
      child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              indicatorColor: Colors.black,
              onTap: (index) {
                print(index);
              },
              tabs: [
                Tab(icon: Icon(Icons.photo_camera)),
                Tab(icon: Icon(Icons.stars)),
                Tab(icon: Icon(Icons.video_library_sharp)),
              ],
            ),
            title: Text(
              _prodController.titlex,
              style: TextStyle(color: Colors.white),
            ),
            elevation: 0,
            backgroundColor: Color(0xFFF70759),
          ),
          drawer: MainDrawer(),
          body: TabBarView(
            children: [
              SafeArea(
                child: Container(
                  child: Column(
                    children: [
                      Obx(() => Wrap(
                          spacing: 20,
                          children: List<Widget>.generate(4, (int index) {
                            return ChoiceChip(
                              label: Text(_chipLabel[index]),
                              selected: _prodController.selectedChip == index,
                              onSelected: (bool selected) {
                                _prodController.selectedChip =
                                    selected ? index : null;
                                chipIndex = index;
                                _prodController
                                    .getChipProduct(productChip.values[index]);
                              },
                            );
                          }))),
                      Expanded(
                        child: new Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: _listStaggered(
                              context,
                              _prodController,
                              _prodController.getChipProduct(
                                  productChip.values[chipIndex])),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Center(
                child: FutureBuilder(
                    future: Dataservices.fetchProductx(),
                    builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                      final data = snapshot.data;
                      return snapshot.hasData
                          ? CarouselSlider.builder(
                              itemCount: snapshot.data.length,
                              options: CarouselOptions(
                                height: 800,
                                scrollDirection: Axis.vertical,
                                initialPage: 0,
                                viewportFraction: 1,
                                aspectRatio: 16 / 9,
                                enableInfiniteScroll: false,
                                autoPlay: false,
                              ),
                              itemBuilder: (BuildContext context, int itemIndex,
                                      int pageViewIndex) =>
                                  Stack(
                                children: <Widget>[
                                  Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadiusDirectional.circular(
                                                20)),
                                    clipBehavior: Clip.antiAlias,
                                    child: Container(
                                      padding: const EdgeInsets.all(0.0),
                                      height: double.infinity,
                                      color: Color(0xFFF70759),
                                      child: PhotoHero(
                                        photo: data[itemIndex]["url"],
                                        width: double.infinity,
                                        height: double.infinity,
                                        onTap: () {
                                          print("cooly");
                                        },
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 80,
                                    top: 500,
                                    child: Container(
                                      child: Row(
                                        children: [
                                          RatingBar.builder(
                                            initialRating: 3,
                                            minRating: 1,
                                            direction: Axis.horizontal,
                                            allowHalfRating: true,
                                            itemCount: 5,
                                            itemPadding: EdgeInsets.symmetric(
                                                horizontal: 4.0),
                                            itemBuilder: (context, _) => Icon(
                                              Icons.star,
                                              color: Colors.amber,
                                            ),
                                            onRatingUpdate: (rating) {
                                              print(pageViewIndex);
                                              pageViewIndex++;
                                              // carouselController.nextPage();
                                            },
                                          ),
                                        ],
                                      ),
                                      decoration: new BoxDecoration(
                                          color: Colors.white24,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(12))),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const CircularProgressIndicator();
                    }),
              ),
              Center(
                child: TokPage(),
              ),
            ],
          )),
    );
  }
}

Widget _details(context, item, meIndex, fonction,url, name) {
  return Scaffold(
    floatingActionButton: buildSpeedDial(url, name, context),
    appBar: AppBar(
      backgroundColor: Color(0xFFF70759),
      title: const Text('Detail'),
    ),
    body: FutureBuilder(
        future: fonction,
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          final data = snapshot.data;

          return snapshot.hasData
              ? CarouselSlider.builder(
                  itemCount: snapshot.data.length,
                  options: CarouselOptions(
                    height: 800,
                    scrollDirection: Axis.vertical,
                    initialPage: meIndex,
                    viewportFraction: 1,
                    aspectRatio: 16 / 9,
                    enableInfiniteScroll: false,
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
                            photo: data[itemIndex]["url"],
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
                                          Icon(Icons.remove_red_eye,
                                              size: 35, color: Colors.white),
                                          Text(
                                              data[itemIndex]["vues"]
                                                  .toString(),
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
                                              child: Icon(
                                                  Icons.star_rate_outlined,
                                                  size: 35,
                                                  color: Colors.white)),
                                          Text(
                                              data[itemIndex]["note"]
                                                  .toString(),
                                              style: TextStyle(
                                                  color: Colors.white))
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () async => {
                                        if (permission() != null){
                                          _shareImage(
                                              data[itemIndex]["url"],
                                              data[itemIndex]["productId"],
                                              context)
                                        }
                                      },
                                      child: Container(
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
                                    )
                                  ],
                                ),
                              ))),
                    ],
                  ),
                )
              : Center(
                  child: CircularProgressIndicator(),
                );
        }),
  );
}

Widget _listStaggered(context, controller, fonction) {
  return Scaffold(
    body: FutureBuilder(
        future: fonction,
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          final data = snapshot.data;
          print(data);
          return snapshot.hasData
              ? StaggeredGridView.countBuilder(
                  crossAxisCount: 4,
                  padding: const EdgeInsets.all(2.0),
                  itemCount: data.length,
                  itemBuilder: (BuildContext context, int index) => Container(
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                    child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        child: Stack(
                          clipBehavior: Clip.none,
                          fit: StackFit.passthrough,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Get.to(() =>
                                    _details(context, data, index, fonction,data[index]["url"],data[index]["productId"]));
                                /*Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                      builder: (BuildContext
                                      context) {
                                        return _details(context, data.reversed.toList(),index);
                                      }));*/
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadiusDirectional.circular(20)),
                                clipBehavior: Clip.antiAlias,
                                child: FadeInImage.memoryNetwork(
                                    placeholder: kTransparentImage,
                                    image: data[index]["url"],
                                    fit: BoxFit.contain),
                              ),
                            ),
                            Positioned(
                                left: 130,
                                top: 0,
                                child: Center(
                                  child: Container(
                                    child: Column(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            _details(context, data, index, fonction,data[index]["url"],data[index]["productId"]);
                                          },
                                          icon: Icon(
                                            Icons.remove_red_eye_sharp,
                                            color: Colors.white70,
                                          ),
                                        ),
                                        IconButton(
                                            onPressed: () => {},
                                            icon: FavoriteButton(
                                                iconSize: 40,
                                                isFavorite: false,
                                                valueChanged: (_isFavorite) {
                                                  if (_isFavorite) {
                                                    controller.addProduct(
                                                        data, context);
                                                  }
                                                })),
                                        IconButton(
                                            onPressed: () async => {
                                                  if (permission() != null) {
                                                    _saveImage(data[index]["url"], data[index]["productId"], context)
                                                  },
                                                },
                                            icon: Icon(
                                              Icons.file_download,
                                              color: Colors.white70,
                                            )),
                                      ],
                                    ),
                                    decoration: new BoxDecoration(
                                        color: Colors.black26,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10))),
                                  ),
                                )),
                          ],
                        )),
                  ),
                  staggeredTileBuilder: (int index) => new StaggeredTile.fit(2),
                  mainAxisSpacing: 3.0,
                  crossAxisSpacing: 4.0, //
                )
              : Center(
                  child: CircularProgressIndicator(),
                );
        }),
  );
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

SpeedDial buildSpeedDial(url, name, context) {
  return SpeedDial(
    animatedIcon: AnimatedIcons.menu_close,
    animatedIconTheme: IconThemeData(size: 28.0),
    backgroundColor: Colors.blue[900],
    visible: true,
    curve: Curves.easeInCubic,
    children: [
      SpeedDialChild(
        child: Icon(Icons.file_download, color: Colors.white),
        backgroundColor: Colors.blueAccent,
        onTap: () => {
          _saveImage(url,name,context)
        },
        labelStyle: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
        labelBackgroundColor: Colors.black,
      ),
      SpeedDialChild(
        child: Icon(Icons.favorite, color: Colors.white),
        backgroundColor: Colors.blueAccent,
        onTap: () => print('Pressed Write'),
        labelStyle: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
        labelBackgroundColor: Colors.black,
      ),
      SpeedDialChild(
        child: Icon(Icons.share, color: Colors.white),
        backgroundColor: Colors.blueAccent,
        onTap: () async => {
          _shareImage(
              url,
              name,
              context)
        },
        labelStyle: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
        labelBackgroundColor: Colors.black,
      ),
    ],
  );
}

Future<bool> permission() async {
  var permissionGranted;
  if (await Permission.storage.request().isGranted) {
    permissionGranted = true;
    return true;
  } else if (await Permission.storage.request().isPermanentlyDenied) {
    await openAppSettings();
  } else if (await Permission.storage.request().isDenied) {
    return permissionGranted = null;
  }
  return permissionGranted;
}

/*
Future<List<String>> pickFile() async {
  var client = http.Client();
  var response = await client.get(Uri.parse("https://myafricanstyle.herokuapp.com/files/b879a5c4-ab42-43d7-96f7-b1c38e15630d"));
  Share.shareFiles(response);
  */
/*final result = await FilePicker.platform.pickFiles(allowMultiple: true);
  return result == null ? <String>[] : result.paths;*/ /*

}*/
