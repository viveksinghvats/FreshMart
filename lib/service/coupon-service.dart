import 'package:http/http.dart' show Client;
import 'dart:convert';
import 'constants.dart';
import 'common.dart';

class CouponService {
  static final Client client = Client();
  // get coupons

  static Future<Map<String, dynamic>> applyCouponsCode(
      cartId, couponCode) async {
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
    var body = {"couponCode": couponCode.toString()};
    final response = await client.post(
        Constants.BASE_URL + "cart/apply/coupon/$cartId?$locationData",
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'bearer $token',
          'language': languageCode,
        });
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> removeCoupon(cartId) async {
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
    final response = await client.get(
        Constants.BASE_URL + "cart/remove/coupon/$cartId?$locationData",
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'bearer $token',
          'language': languageCode,
        });
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> couponList() async {
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
        .get(Constants.BASE_URL + "cart/coupon/list?$locationData", headers: {
      'Content-Type': 'application/json',
      'Authorization': 'bearer $token',
      'language': languageCode,
    });
    return json.decode(response.body);
  }
}
