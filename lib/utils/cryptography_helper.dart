// import 'package:encrypt/encrypt.dart';
import 'dart:convert';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart' as foundation;
import 'package:igot_http_service/data_models/api_obj_model.dart';

class CryptographyHelper {
  static final key = encrypt.Key.fromUtf8('4f1aaae66406e358');
  static final iv = encrypt.IV.fromUtf8('df1e180949793972');
  static final encrypt.Encrypter encrypterAES =
      encrypt.Encrypter(encrypt.AES(key));

  static String data = "qwertyuiopasdfgg";

  static String getEncryptedApiObj({@foundation.required ApiObj apiObj}) {
    try {
      final encrypted = encrypterAES.encrypt(
        apiObj.url + jsonEncode(apiObj.body) + jsonEncode(apiObj.headers),
        iv: iv,
      );

      return encrypted.base64;
    } catch (e) {
      return '';
    }
  }

  static String getDecryptedApiObj(
      {@foundation.required encrypt.Encrypted key}) {
    final decrypted = encrypterAES.decrypt(key, iv: iv);

    return decrypted;
  }
}
