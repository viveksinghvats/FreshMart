import 'package:http/http.dart' show Client;
import 'dart:convert';
import 'constants.dart';
import '../service/common.dart';

class CartService {
  static final Client client = Client();

  // add product in cart
  static Future<Map<String, dynamic>> addProductToCart(body) async {
    String token, languageCode, locationData;
    await Common.getToken().then((onValue) {
      token = onValue;
    });
    await Common.getSelectedLanguage().then((code) {
      languageCode = code ?? "";
    });
    await Common.getLocation().then((locationDataValue) async {
      locationData = "location=" + locationDataValue['_id'];
    });
    final response = await client.post(
        Constants.BASE_URL + "cart/add/product?$locationData",
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'bearer $token',
          'language': languageCode,
        });
    return json.decode(response.body);
  }

  // get product in cart
  static Future<Map<String, dynamic>> getProductToCart() async {
    String token, languageCode, locationData;
    await Common.getToken().then((onValue) {
      token = onValue;
    });
    await Common.getSelectedLanguage().then((code) {
      languageCode = code ?? "";
    });
    await Common.getLocation().then((locationDataValue) async {
      locationData = "location=" + locationDataValue['_id'];
    });
    final response = await client
        .get(Constants.BASE_URL + "cart/user/items?$locationData", headers: {
      'Content-Type': 'application/json',
      'Authorization': 'bearer $token',
      'language': languageCode,
    });
    return json.decode(response.body);
  }

  // update product in cart
  static Future<Map<String, dynamic>> updateProductToCart(body) async {
    String token, languageCode, locationData;
    await Common.getToken().then((onValue) {
      token = onValue;
    });
    await Common.getSelectedLanguage().then((code) {
      languageCode = code ?? "";
    });
    await Common.getLocation().then((locationDataValue) async {
      locationData = "location=" + locationDataValue['_id'];
    });
    final response = await client.put(
        Constants.BASE_URL + "cart/update/product?$locationData",
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'bearer $token',
          'language': languageCode,
        });
    return json.decode(response.body);
  }

  // delete form cart
  static Future<Map<String, dynamic>> deleteDataFromCart(body) async {
    String token, languageCode, locationData;
    await Common.getToken().then((onValue) {
      token = onValue;
    });
    await Common.getSelectedLanguage().then((code) {
      languageCode = code ?? "";
    });
    await Common.getLocation().then((locationDataValue) async {
      locationData = "location=" + locationDataValue['_id'];
    });
    final response = await client.put(
        Constants.BASE_URL + "cart/delete/product?$locationData",
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'bearer $token',
          'language': languageCode,
        });
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> deleteAllDataFromCart(cartId) async {
    String token, languageCode, locationData;
    await Common.getToken().then((onValue) {
      token = onValue;
    });
    await Common.getSelectedLanguage().then((code) {
      languageCode = code ?? "";
    });
    await Common.getLocation().then((locationDataValue) async {
      locationData = "location=" + locationDataValue['_id'];
    });
    final response = await client.delete(
        Constants.BASE_URL + "cart/all/items/$cartId?$locationData",
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'bearer $token',
          'language': languageCode,
        });
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> paymentTimeCarDataDelete(Map body) async {
    String token, languageCode, locationData;
    await Common.getToken().then((onValue) {
      token = onValue;
    });
    await Common.getSelectedLanguage().then((code) {
      languageCode = code ?? "";
    });
    await Common.getLocation().then((locationDataValue) async {
      locationData = "location=" + locationDataValue['_id'];
    });
    final response = await client.put(
        Constants.BASE_URL + "cart/remove/multi/product?$locationData",
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'bearer $token',
          'language': languageCode,
        });
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> minOrderAmoutCheckApi() async {
    String token, languageCode;
    await Common.getToken().then((onValue) {
      token = onValue;
    });
    await Common.getSelectedLanguage().then((code) {
      languageCode = code ?? "";
    });
    final response = await client
        .get(Constants.BASE_URL + "delivery/tax/settings/info", headers: {
      'Content-Type': 'application/json',
      'Authorization': 'bearer $token',
      'language': languageCode,
    });
    return json.decode(response.body);
  }
}
