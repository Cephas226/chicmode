import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_app/model/product_model.dart';
import 'package:getx_app/services/backend_service.dart';
import 'package:hive/hive.dart';
import 'package:getx_app/domain/request.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
class HomeController extends GetxController {
  String titlex = 'Accueil';
  RxList<Product> dataProduct = <Product>[].obs;
  RxList<Product> dataProductChip = <Product>[].obs;
  bool favorite= false;
  RxBool permissionGranted=false.obs;
  String productBoxName = 'product';
  //Gestion des chip

  List _inventoryList = <Product>[];

  List get inventoryList => _inventoryList;

  var _selectedChip = 0.obs;
  final photoIndex = 0.obs;

  final initialPage = 0.obs;

  //get photoIndex => this._photoIndex.value;
  get selectedChip => this._selectedChip.value;
  set selectedChip(index) => this._selectedChip.value = index;

  //Box
  Box<Product> productBox;
  static var client = http.Client();
  @override
  void onInit() async {
    super.onInit();
   // getChipProduct(productChip.TOUT);
    readProduct();
    //await Hive.openBox<Product>(productBoxName);

    productBox = Hive.box<Product>(productBoxName);
    //
    setTabName(0);
  }
  @override
  void dispose() {
    super.dispose();
  }

  void readProduct() async {
    Request request = Request(url: 'product');
    request.get().then((value) {
      if(value.statusCode==200){
        List jsonResponse = jsonDecode(value.body);
        dataProduct.value = jsonResponse.map((e) => Product.fromJson(e)).toList();
        dataProductChip.value=dataProduct.reversed.toList();
        print("Loaded");
      }else{
        print('Backend error');
      }
    }).catchError((onError) {
      printError();
    });
  }
  addProduct(Product prod,context) async {
    productBox.add(prod);
    //print(productBox);
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Enregistré dans favoris')));
  }
  void removeProduct(int id) async{
    //var producBox = await Hive.openBox(productBox);
    productBox.deleteAt(id);
    print("succes");
  }
  favToggleRepeat(bool newValue) {
    favorite = newValue;
    update(['favorite', true]);
  }

  Future<List> fetchProduct() async {
    final response =
    await client.get(Uri.parse("https://myafricanstyle.herokuapp.com/product"));

    if (response.statusCode == 200)
      return json.decode(response.body);
    return [];
  }

  Future<List> getChipProduct(productChip chip) {
    print("hello");
    switch (chip) {
      case productChip.TOUT:
       return  fetchProduct().then((value) => value.toList()..shuffle());

      case productChip.RECENT:
        return  fetchProduct().then((value) => value.reversed.toList());

      case productChip.MIEUX_NOTE:
        return fetchProduct().then((value) => value.toList());

      case productChip.ALEATOIRE:
        return fetchProduct().then((value) => value.reversed.toList());
    }
    return fetchProduct();
  }
  String setTabName(int index) {
    switch (index) {
      case 0:
        print(titlex);
        return  titlex="Accueil";

      case 1:
        print(titlex);
        return titlex="Noter";

      case 2:
        print(titlex);
        return titlex="Vidéos";
    }
    return titlex;
  }


}
