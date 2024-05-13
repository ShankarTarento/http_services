import 'package:flutter/foundation.dart';
import 'package:igot_http_service/data_models/api_obj_model.dart';
import 'package:igot_http_service/utils/constants.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqlite_api.dart';

import 'cryptography_helper.dart';

mixin ApiDBHelper {
  // ignore: non_constant_identifier_names
  static String get _API_TABLE => AppDatabase.apiDataTable;
  // ignore: non_constant_identifier_names
  static String get _KEY_APIKEY => 'api_key';
  // ignore: non_constant_identifier_names
  static String get _KEY_TTL => 'api_ttl';
  // ignore: non_constant_identifier_names
  static String get _KEY_API_DATA => 'api_data';
  // ignore: non_constant_identifier_names
  static String get _KEY_API_DATE_TIME => 'api_date_time';

  static sql.Database _db;
  static String createApiTable =
      'CREATE TABLE $_API_TABLE ($_KEY_APIKEY TEXT PRIMARY KEY, $_KEY_TTL INTEGER, $_KEY_API_DATA TEXT, $_KEY_API_DATE_TIME TEXT)';

// Create and open data base
  static Future<Database> _database() async {
    if (_db != null) {
      return _db;
    }
    final dbPath = await sql.getDatabasesPath();
    final mPath = path.join(dbPath, AppDatabase.name);

    _db = await sql.openDatabase(mPath, onCreate: (db, version) async {
      await db.execute(createApiTable);
    }, singleInstance: true, version: 1);
    return _db;
  }

  static Future<bool> insert(
      {String key, Object content, int ttlInHours}) async {
    Map<String, Object> data = {
      _KEY_APIKEY: key,
      _KEY_API_DATA: content,
      _KEY_TTL: ttlInHours ?? -1,
      _KEY_API_DATE_TIME: DateTime.now().toString()
    };

    var db = await _database();
    try {
      var status = await db.insert(
        _API_TABLE,
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return status is int && status != 0;
    } catch (e) {}
    return false;
  }

  static Future<String> getDataByApiObj({@required ApiObj apiObj}) async {
    String key = CryptographyHelper.getEncryptedApiObj(apiObj: apiObj);

    if (key.isEmpty) return '';

    var db = await _database();

    var row = await db.query(_API_TABLE, where: '$_KEY_APIKEY = "$key"');

    if (row != null && row.isNotEmpty) {
      var entryDateTime = row.first[_KEY_API_DATE_TIME];
      var diffInHours =
          DateTime.now().difference(DateTime.parse(entryDateTime)).inHours;
      if (diffInHours <= row.first[_KEY_TTL] && diffInHours >= 0) {
        return row.first[_KEY_API_DATA];
      }
    }
    return '';
  }
}
