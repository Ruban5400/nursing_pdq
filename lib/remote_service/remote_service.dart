import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../constants/api.dart';
import '../screens/dummy.dart';

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

  Future<Map<String, dynamic>> postDataFromApi(
    String apiPath,
    Map<String, String> headers,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse(apiPath);
    final http.Response response;
    try {
      response = await http
          .post(uri, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 15));
    } on SocketException {
      throw const ApiException.network();
    } on TimeoutException {
      throw const ApiException.timeout();
    }

    final Map<String, dynamic> json;
    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException.serverError(
        'Unexpected response format (status ${response.statusCode})',
      );
    }

    // Auth error — comes back as 200 with a "Message" key
    if (json.containsKey('Message')) {
      final msg = json['Message'] as String? ?? '';
      if (msg.toLowerCase().contains('authorization') ||
          msg.toLowerCase().contains('denied')) {
        throw const ApiException.unauthorized();
      }
      // Any other "Message" key means no data / business-level error
      throw ApiException.noRecords(msg);
    }

    return json;
  }
}
