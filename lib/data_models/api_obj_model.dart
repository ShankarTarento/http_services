import 'package:flutter/material.dart';

class ApiObj {
  String url;
  Map<dynamic, dynamic> body;
  Map<String, dynamic> headers;
  ApiObj({@required this.url, this.body = const {}, this.headers = const {}});

  // factory ApiObj.fromJson(Map<String, dynamic> json) => ApiObj(
  //       url: json["url"],
  //       body: json["body"],
  //     );

  // Map<String, dynamic> toJson() => {
  //       "url": url,
  //       "body": body,
  //     };
}
