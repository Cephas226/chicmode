import 'dart:async';
import 'dart:typed_data';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:getx_app/model/product_model.dart';
import 'package:getx_app/pages/categories/categories_page.dart';
import 'package:getx_app/pages/favoris/favoris_page.dart';
import 'package:getx_app/pages/rate/rate_page.dart';
import 'package:getx_app/pages/videos/took.dart';
import 'dart:math' as math;
import 'package:getx_app/widget/oval-right-clipper.dart';
import 'package:getx_app/widget/photo_widget/photohero.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:favorite_button/favorite_button.dart';
import '../../main.dart';
import 'home_controller.dart';
import 'next_page.dart';

class HomePage extends GetView<HomeController> {
  final HomeController _prodController = Get.put(HomeController());
  CarouselController carouselController = new CarouselController();
  String titlexy = 'Accueil';
  List<String> imageList = [];
  var currentPos=0;
  @override
  Widget build(BuildContext context) {
    _prodController.monContext=context;
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
            //key: _prodController.key1,
            title: Obx(()=>Text(_prodController.myHandler.value.title)),
            bottom: TabBar(
              indicatorColor: Colors.black,
              controller: _prodController.controller,
              tabs: <Tab>[
                Tab(icon: Icon(Icons.photo_camera)),
                Tab(icon: Icon(Icons.stars)),
                Tab(icon: Icon(Icons.video_library_sharp)),
              ],
            ),
            elevation: 0,
            backgroundColor: Color(0xFFF70759),
          ),
          drawer: _buildDrawer(context),
          body: TabBarView(
            controller: _prodController.controller,
            children: [
              SafeArea(
                child: Container(
                  child: Column(
                    children: [
                      Obx(() => Wrap(
                          spacing: 20,
                          children: List<Widget>.generate(4, (int index) {
                            return InkWell(
                              onTap: ()=>{
                              },
                              child: ChoiceChip(
                                label: Text(_chipLabel[index]),
                                selected: _prodController.selectedChip == index,
                                onSelected: (bool selected) async {
                                  _prodController.selectedChip =
                                  selected ? index : null;
                                  _prodController.getChipProduct(productChip
                                      .values[_prodController.selectedChip]);
                                },
                              ),
                            );
                          }))),
                      Obx(() => Expanded(
                            child: Container(
                              child:_prodController.dataProductChip.isNotEmpty ?
                              _detailStaggeredGridView(context, _prodController):Text("Chargement en Cours"),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              RatePage(),
              Center(
                child: TokPage(),
              ),
            ],
          )),
    );
  }
}
_buildDrawer(context) {

  final String image = "https://firebasestorage.googleapis.com/v0/b/africanstyle-15779.appspot.com/o/avatar.png?alt=media&token=664ebc08-a844-4ba0-8345-8bbf8fc4589a";
  return ClipPath(
    clipper: OvalRightBorderClipper(),
    child: Drawer(
      child: Container(
        padding: const EdgeInsets.only(left: 16.0, right: 40),
        decoration: BoxDecoration(
            color: primary, boxShadow: [BoxShadow(color: Colors.black45)]),
        width: 300,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(
                      Icons.power_settings_new,
                      color: active,
                    ),
                    onPressed: () {},
                  ),
                ),
                Container(
                  height: 90,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                          colors: [Colors.pink, Colors.deepPurple])),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(image),
                  ),
                ),
                SizedBox(height: 5.0),
                Text(
                  "@ChicMode",
                  style: TextStyle(color: active, fontSize: 16.0),
                ),
                SizedBox(height: 30.0),
                _buildRow(Icons.home, "Accueil",HomePage(),context),
                _buildDivider(),
                _buildRow(Icons.bookmark, "Mes favoris",FavorisPage(),context),
                _buildDivider(),
                _buildRow(Icons.email, "Nous contacter",CategoriesPage(),context),
                _buildDivider(),
                _buildRow(Icons.phone_android_outlined, "Nos applications",FavorisPage(),context),
                _buildDivider(),
                _buildRow(Icons.info_outline,"Aide", FavorisPage(),context),
                _buildDivider(),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
Divider _buildDivider() {
  return Divider(
    color: active,
  );
}
Widget _buildRow(IconData icon, String title,route,context) {
  final TextStyle tStyle = TextStyle(color: active, fontSize: 16.0);
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: InkWell(
      onTap: () {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (BuildContext context) => route));
      },
      child: Row(children: [
        Icon(
          icon,
          color: active,
        ),
        SizedBox(width: 10.0),
        Text(
          title,
          style: tStyle,
        ),
        Spacer(),
      ]),
    ),
  );
}
Widget _detailStaggeredGridView(context, controller) {
  final _nativeAdController = NativeAdmobController();
  return
    Scaffold(
    body:
    StaggeredGridView.countBuilder(
      crossAxisCount: 4,
      padding: const EdgeInsets.all(2.0),
      itemCount: controller.dataProductChip.length,
      itemBuilder: (BuildContext context, int index) =>
          Container(
            decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.all(
                    Radius.circular(12))),
            child:
            ClipRRect(
                borderRadius:
                BorderRadius.all(Radius.circular(12)),
                child:
                Stack(
                  clipBehavior: Clip.none, fit: StackFit.passthrough,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.to(()=>
                            Scaffold(
                              //floatingActionButton: buildSpeedDial(controller,index,context),
                              appBar: AppBar(
                                backgroundColor: Color(0xFFF70759),
                                title: const Text('Details'),
                              ),

                              body: CarouselSlider.builder(
                                itemCount: controller.dataProductChip.length,
                                options: CarouselOptions(
                                  height: 800,
                                  scrollDirection: Axis.vertical,
                                  initialPage: index,
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
                                              photo: controller.dataProductChip[itemIndex].url,
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
                                              Text(controller.dataProductChip[itemIndex].vues.toString(),
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
                                                  child: Icon(Icons.stars,
                                                      size: 35,
                                                      color: Colors.white)),
                                              Text(controller.dataProductChip[itemIndex].note.toString(),
                                                  style: TextStyle(
                                                      color: Colors.white))
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: ()=>{
                                            _shareImage(controller.dataProductChip[itemIndex].url,controller.dataProductChip[itemIndex].productId,context)
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
                                        ),
                                      ],
                                    ),
                                  ))),
                                        Positioned.fill(
                                          child: Align(
                                              alignment: Alignment.bottomCenter,
                                              child:
                                              Container(
                                                  margin: EdgeInsets.all(8),
                                                  height: 90,
                                                  color: Colors.white24,
                                                  child: NativeAdmob(
                                                    adUnitID: NativeAd.testAdUnitId,
                                                    controller: _nativeAdController,
                                                    type: NativeAdmobType.full,
                                                    loading: Center(child: CircularProgressIndicator()),
                                                    error: Text('failed to load'),
                                                  ))
                                          ),
                                        ),
                                      ],
                                    ),
                              ),
                            )
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadiusDirectional
                                .circular(20)),
                        clipBehavior: Clip.antiAlias,
                        child: FadeInImage.memoryNetwork(
                            placeholder:
                            kTransparentImage,
                            image: controller.dataProductChip[index].url,
                            fit: BoxFit.cover),
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
                                    Get.to(()=>Scaffold(
                                     // floatingActionButton: buildSpeedDial(controller,index,context),
                                      appBar: AppBar(
                                        backgroundColor: Color(0xFFF70759),
                                        title: const Text('Details'),
                                      ),
                                      body: CarouselSlider.builder(
                                        itemCount: controller.dataProductChip.length,
                                        options: CarouselOptions(
                                          height: 800,
                                          scrollDirection: Axis.vertical,
                                          initialPage: index,
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
                                                      photo: controller.dataProductChip[itemIndex].url,
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
                                                                    Text(controller.dataProductChip[itemIndex].vues.toString(),
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
                                                                        child: Icon(Icons.stars,
                                                                            size: 35,
                                                                            color: Colors.white)),
                                                                    Text(controller.dataProductChip[itemIndex].note.toString(),
                                                                        style: TextStyle(
                                                                            color: Colors.white))
                                                                  ],
                                                                ),
                                                              ),
                                                              GestureDetector(
                                                                onTap: ()=>{
                                                                  _shareImage(controller.dataProductChip[itemIndex].url,controller.dataProductChip[itemIndex].productId,context)
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
                                                              ),
                                                            ],
                                                          ),
                                                        ))),
                                              ],
                                            ),
                                      ),
                                    ));
                                  },
                                  icon: Icon(
                                    Icons
                                        .remove_red_eye_sharp,
                                    color: Colors.white70,
                                  ),
                                ),
                                IconButton(
                                    onPressed: () => {},
                                    icon: FavoriteButton(
                                        iconSize: 40,
                                        isFavorite: false,
                                        valueChanged:
                                            (_isFavorite) {
                                          if (_isFavorite) {
                                            controller.addProduct(
                                                controller.dataProductChip[index],
                                                context);
                                          }
                                        })),
                                IconButton(
                                    onPressed: () async =>
                                    {
                                      _saveImage(
                                          controller.dataProductChip[index].url,
                                          controller.dataProductChip[index].productId,
                                          context),
                                    },
                                    icon: Icon(
                                      Icons.file_download,
                                      color:
                                      Colors.white70,
                                    )),
                              ],
                            ),
                            decoration: new BoxDecoration(
                                color: Colors.black26,
                                borderRadius:
                                BorderRadius.all(
                                    Radius.circular(
                                        10))),
                          ),
                        )),
                  ],
                )
            ),
          ),
      staggeredTileBuilder: (int index) =>
      new StaggeredTile.fit(2),
      mainAxisSpacing: 3.0,
      crossAxisSpacing: 4.0, //
    ),
  );
}
_saveImage(url, name, context) async {
  if (await Permission.storage.request().isGranted) {
    var client = http.Client();
    var response = await client.get(Uri.parse(url));
    final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.bodyBytes),
        quality: 60,
        name: "model" + name.toString());
    ScaffoldMessenger.of(context)
        .showSnackBar(mysnackBar("Image sauvegardé"));
  } else if (await Permission.storage.request().isPermanentlyDenied) {
    await openAppSettings();
  } else if (await Permission.storage.request().isDenied) {

  }
}
mysnackBar(message){
  return SnackBar(content: Text(message));
}
_shareImage(url, name, context) async {
  if (await Permission.storage.request().isGranted) {
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
    ], text: 'Pour plus de modèles de pagnes, télécharges l\'application ChicMode via ce lien 👉🏼');
  } else if (await Permission.storage.request().isPermanentlyDenied) {
    await openAppSettings();
  }
}
/*SpeedDial buildSpeedDial(controller,index,context) {
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
          _saveImage(controller.dataProductChip[index].url,controller.dataProductChip[index]["name"],context)
        },
        labelStyle: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
        labelBackgroundColor: Colors.black,
      ),
      SpeedDialChild(
        child: Icon(Icons.favorite, color: Colors.white),
        backgroundColor: Colors.blueAccent,
        onTap: () => {

        },
        labelStyle: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
        labelBackgroundColor: Colors.black,
      ),
*//*      SpeedDialChild(
        child: Icon(Icons.share, color: Colors.white),
        backgroundColor: Colors.blueAccent,
        onTap: () async => {},
        labelStyle: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
        labelBackgroundColor: Colors.black,
      ),*//*
    ],
  );
}*/
