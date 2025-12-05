import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../constants/api.dart';

const Map refreshTokenBody = {
  "Username": "Kauvery",
  "password": "Kmc@123",
  "grant_type": "password",
};
final _secureStorage = const FlutterSecureStorage();

class RemoteService {
  Future<bool> getRefreshToken() async {
    try {
      final uri = Uri.parse(ApiList.refreshTokenApi);
      var response = await http.post(
        uri,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: refreshTokenBody,
      );

      // response.body is a JSON string -> decode it
      final Map<String, dynamic> tokenResponse =
          json.decode(response.body) as Map<String, dynamic>;

      // required fields
      final accessToken = tokenResponse['access_token'] as String;
      final expiresIn = tokenResponse['expires_in'];

      await saveTokens(accessToken: accessToken, expiresInSeconds: expiresIn);
      bool tokenFetched =
          response.statusCode < 200 || response.statusCode >= 300
          ? false
          : true;
      return tokenFetched;
    } catch (err) {
      print("$err");
      return false;
    }
  }

  Future<void> saveTokens({
    required String accessToken,
    required int expiresInSeconds,
  }) async {
    final expiry = DateTime.now()
        .toUtc()
        .add(Duration(seconds: expiresInSeconds))
        .toIso8601String();
    await _secureStorage.write(key: 'access_token', value: accessToken);
    await _secureStorage.write(key: 'access_token_expiry', value: expiry);
  }

  // post call
  Future<String> postDataToApi(
    Map<String, String> apiHeader,
    Map apiBody,
  ) async {
    try {
      final uri = Uri.parse(ApiList.loginApi);
      var response = await http.post(
        uri,
        headers: apiHeader,
        body: jsonEncode(apiBody),
      );

      var loginStatus = jsonDecode(response.body);
      return loginStatus['status'];
    } catch (err) {
      print("$err");
      return 'Server error';
    }
  }

  // Get Api
  getDataFromApi(String api, Map<String, String> headers) async {
    try {
      final uri = Uri.parse(api);
      var response = await http.get(uri, headers: headers);
      // time out exception
      // .timeout(const Duration(seconds: 10));
      return compute(parseUserData, response.body);
      // } on TimeoutException {
      //   return {
      //     'success': false,
      //     'status': 'Request timed out',
      //     'message': 'TimeOut'
      //   };
    } on SocketException {
      return {
        'success': false,
        'status': 'You are offline',
        'message': 'Offline',
      };
    } catch (err) {
      print("$err");
      return "Please try again later 1";
    }
  }

  dynamic parseUserData(String responseBody) {
    var jsonData = jsonDecode(responseBody);
    return jsonData;
  }

  Future<Object> postDataFromApi(apiPath, apiHeaders, apiBody) async {
    try {
      final uri = Uri.parse(apiPath);
      var response = await http.post(
        uri,
        headers: apiHeaders,
        body: jsonEncode(apiBody),
      );
      Map<String, dynamic> result = jsonDecode(response.body);
      print('5400 -=-=-=-= result $result');
      return result;
    } catch (err) {
      return "Please try again later 2";
    }
  }

  //
  // logOut() async {
  //   try {
  //     final uri = Uri.parse('$baseUrl/v2/logout');
  //     var response = await http.post(
  //       uri,
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Accept': 'application/json',
  //         'Authorization': 'Bearer ${loginDetails["token"]}',
  //       },
  //     );
  //
  //     return response;
  //   } catch (err) {
  //     Get.to(const ErrorPage());
  //     return "Please try again later 4";
  //   }
  // }
}
