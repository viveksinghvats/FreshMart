import 'package:http/http.dart' show Client;
import 'dart:convert';
import 'constants.dart';
import 'common.dart';

class PaymentService {
  static final Client client = Client();
  static Future<Map<String, dynamic>> getDeliveryCharges(body) async {
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
        Constants.BASE_URL + "delivery/tax/settings/get/charges?$locationData",
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'bearer $token',
          'language': languageCode,
        });
    return json.decode(response.body);
  }
}
