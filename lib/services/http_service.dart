import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../data_models/api_obj_model.dart';
import '../utils/api_db_helper.dart';
import '../utils/cryptography_helper.dart';

class HttpService {
  static Map<String, String> convertToHeaders(Map<dynamic, dynamic> headers) {
    Map<String, String> convertedHeaders = {};
    headers.forEach((key, value) {
      convertedHeaders[key.toString()] = value.toString();
    });
    return convertedHeaders;
  }

  static Future<http.Response> post(
      {@required Uri apiUri,
      Duration ttl,
      Map<String, dynamic> headers,
      Map<dynamic, dynamic> body}) async {
    int ttlInMilliSeconds = -1;

    if (ttl != null) {
      ttlInMilliSeconds = ttl.inMilliseconds;
    }

    final ApiObj apiObj =
        ApiObj(url: apiUri.toString(), headers: headers, body: body);
    var contents = await ApiDBHelper.getDataByApiObj(apiObj: apiObj);

    if (contents.isEmpty) {
      try {
        var response =
            await http.post(apiUri, headers: headers, body: json.encode(body));

        if (response.statusCode == 200) {
          Map<String, dynamic> responseMap = {
            'statusCode': response.statusCode,
            'headers': response.headers,
            'body': response.body,
          };
          contents = jsonEncode(responseMap);

          String key = CryptographyHelper.getEncryptedApiObj(apiObj: apiObj);
          await ApiDBHelper.insert(
              key: key,
              content: contents,
              ttlInMilliSeconds: ttlInMilliSeconds);
          debugPrint("==============>post method successful");

          return response;
        } else {
          throw 'Failed to fetch data with status code ${response.statusCode}';
        }
      } catch (e) {
        debugPrint('Error in post method======> $e');
        throw e;
      }
    } else {
      var data = jsonDecode(contents);

      http.Response response = http.Response(
        data['body'],
        data['statusCode'],
        headers: convertToHeaders(
          data['headers'],
        ),
      );
      debugPrint("==============>post method successful");
      return response;
    }
  }

  static Future<http.Response> patch(
      {@required Uri apiUri,
      Map<String, dynamic> headers,
      Map<String, dynamic> body}) async {
    try {
      var response =
          await http.patch(apiUri, headers: headers, body: json.encode(body));

      if (response.statusCode == 200) {
        debugPrint("==============>request  successful");

        return response;
      } else {
        throw 'Failed to fetch data with status code ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('Error in patch method======> $e');
      throw e;
    }
  }

  static Future<http.Response> delete(
      {@required Uri apiUri,
      Map<String, dynamic> headers,
      Map<String, dynamic> body}) async {
    try {
      var response =
          await http.delete(apiUri, headers: headers, body: json.encode(body));

      if (response.statusCode == 200) {
        debugPrint("==============>request  successful");

        return response;
      } else {
        throw 'Failed to fetch data with status code ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('Error in delete method======> $e');
      throw e;
    }
  }

  static Future<http.StreamedResponse> multiPartRequest(
      {@required Uri apiUri,
      Map<String, dynamic> headers,
      String imagePath,
      Map<String, dynamic> body}) async {
    var formData = http.MultipartRequest('POST', apiUri)
      ..headers.addAll(headers);
    formData.files.add(await http.MultipartFile.fromPath('file', imagePath));
    try {
      final response = await formData.send();

      if (response.statusCode == 200) {
        debugPrint("==============>request  successful");

        return response;
      } else {
        throw 'Failed to fetch data with status code ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('Error in delete method======> $e');
      throw e;
    }
  }

  static Future<http.Response> get(
      {@required Uri apiUri,
      Duration ttl,
      Map<String, dynamic> headers,
      Map<String, dynamic> body}) async {
    int ttlInMilliSeconds = -1;

    if (ttl != null) {
      ttlInMilliSeconds = ttl.inMilliseconds;
    }
    final ApiObj apiObj =
        ApiObj(url: apiUri.toString(), headers: headers, body: body);
    var contents = await ApiDBHelper.getDataByApiObj(apiObj: apiObj);

    if (contents.isEmpty) {
      try {
        var response = await http.get(apiUri, headers: headers);

        if (response.statusCode == 200) {
          Map<String, dynamic> responseMap = {
            'statusCode': response.statusCode,
            'headers': response.headers,
            'body': response.body,
          };
          contents = jsonEncode(responseMap);

          String key = CryptographyHelper.getEncryptedApiObj(apiObj: apiObj);
          await ApiDBHelper.insert(
              key: key,
              content: contents,
              ttlInMilliSeconds: ttlInMilliSeconds);
          debugPrint("==============>get method successful");
          return response;
        } else {
          throw 'Failed to fetch data with status code ${response.statusCode}';
        }
      } catch (e) {
        debugPrint('Error in get method======> $e');
        throw e;
      }
    } else {
      var data = jsonDecode(contents);

      http.Response response = http.Response(
        data['body'],
        data['statusCode'],
        headers: convertToHeaders(
          data['headers'],
        ),
      );
      debugPrint("==============>get method successful");
      return response;
    }
  }
}
