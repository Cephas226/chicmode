import 'dart:convert';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:get/get.dart';
import 'package:getx_app/model/product_model.dart';
import 'package:getx_app/themes/color_theme.dart';
import 'package:getx_app/widget/videoPlayer.dart';
import 'package:hive/hive.dart';
import 'package:getx_app/domain/request.dart';

class HomeController extends GetxController with SingleGetTickerProviderMixin {
  String titlex = 'Accueil';
  RxList<Product> dataProduct = <Product>[].obs;
  RxList<Product> dataProductChip = <Product>[].obs;
  String productBoxName = 'product';
  var _selectedChip = 0.obs;
  get selectedChip => this._selectedChip.value;
  set selectedChip(index) => this._selectedChip.value = index;
  int coins = 0;
  Box<Product> productBox;
  TabController controller;
  bool isFrench = false;
  final List<MyTabs> _tabs = [
    new MyTabs(title: "Accueil"),
    new MyTabs(title: "Noter"),
    new MyTabs(title: "Video"),
  ];
  Rx<MyTabs> myHandler;
  bool checkConfiguration() => true;
  var monContext;
  BannerAd bannerAd;
  InterstitialAd interstitialAd;
  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo();
  final _nativeAdController = NativeAdmobController();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  RxString messageTitle = "Empty".obs;
  RxString notificationAlert = "alert".obs;
  InterstitialAd createInterstitialAd() {
    return InterstitialAd(
        targetingInfo: targetingInfo,
        adUnitId: interstitielUnitID,
        listener: (MobileAdEvent event) {
          print('interstitial event: $event');
        });
  }

  BannerAd createBannerAdd() {
    return BannerAd(
        targetingInfo: targetingInfo,
        adUnitId: banniereUnitID,
        size: AdSize.smartBanner,
        listener: (MobileAdEvent event) {
          print('Bnner Event: $event');
        });
  }

  @override
  void onInit() async {
    super.onInit();
    selectedChip = 0;
    readProduct();
    productBox = Hive.box<Product>(productBoxName);
    getChipProduct(productChip.values[0]);
    controller = new TabController(vsync: this, length: 3);
    myHandler = _tabs[0].obs;
    controller.addListener(_handleSelected);
    FirebaseAdMob.instance.initialize(appId: banniereUnitID);
    /*bannerAd = createBannerAdd()
      ..load()
      ..show();
    await RewardedVideoAd.instance.show();*/
    }
  void _handleSelected() {
    myHandler.value = _tabs[controller.index];
  }

  @override
  void dispose() {
    bannerAd?.dispose();
    interstitialAd?.dispose();
    super.dispose();
  }

  void readProduct() async {
    Request request = Request(url: 'product');
    request.get().then((value) {
      if (value.statusCode == 200) {
        List jsonResponse = jsonDecode(value.body);
        dataProduct.value =jsonResponse.map((e) => Product.fromJson(e)).toList();
        dataProductChip.value = dataProduct.reversed.toList()..shuffle();
        print("Loaded");
      } else {
        print('Backend error');
      }
    }).catchError((onError) {
      printError();
    });
  }

  addProduct(prod, context) async {
    productBox.add(prod);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Enregistré dans favoris')));
  }

  void removeProduct(int id) async {
    productBox.deleteAt(id);
    print("succes");
  }

  List<dynamic> getChipProduct(productChip chip) {
    switch (chip) {
      case productChip.TOUT:
        dataProductChip.value = dataProduct.toList()..shuffle();
        return dataProductChip;

      case productChip.RECENT:
        dataProductChip.value = dataProduct.reversed.toList();
        return dataProductChip;

      case productChip.MIEUX_NOTE:
        dataProductChip.value = dataProduct.where((o) => o.note > 3).toList()
          ..shuffle();
        return dataProductChip;

      case productChip.ALEATOIRE:
        return dataProductChip.reversed.toList();
    }
    return dataProductChip;
  }
  toggleRepeat(bool newValue) {
    isFrench = newValue;
    update(['isRepeat', true]);
  }
}
