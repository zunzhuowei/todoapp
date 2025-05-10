import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_ce/hive.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseProvider extends ChangeNotifier {

  String key = "WEKcdk134+d-/.{}`2@1&()*-=+Baie8";
  late Map<String, BoxCollection> collections = {};

  Future<void> init() async {
    // 设置Hive数据库的存储路径为应用的可写目录
    final appDocumentDir = kIsWeb ? null : await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir?.path);
  }

  Future<BoxCollection> _getCollection(String boxName, {String databaseName = 'databaseBoxs'}) async {
    if(collections[boxName] != null) {
      return collections[boxName]!;
    }
    // Create a box collection
    var collection = await BoxCollection.open(
      // Name of your database
      databaseName,
      // Names of your boxes
      {boxName},
      // Path where to store your boxes (Only used in Flutter / Dart IO)
      //path: './',
      // Key to encrypt your boxes (Only used in Flutter / Dart IO)
      key: HiveAesCipher(key.codeUnits),
    );
    collections[boxName] = collection;
    return collections[boxName]!;
  }

  Future<void> deleteBox(String boxName) async {
    await Hive.deleteBoxFromDisk('databaseboxs_$boxName');
  }

  Future<void> deleteAllBox() async {
    await Hive.deleteFromDisk();
  }

  Future<void> put(String boxName, String key, dynamic value) async {
    BoxCollection boxCollection = await _getCollection(boxName);
    CollectionBox<String> box = await boxCollection.openBox<String>(boxName);
    // Put a value
    var json = jsonEncode(value);
    await box.put(key, json);
  }

  Future<void> delete(String boxName, String key) async {
    BoxCollection boxCollection = await _getCollection(boxName);
    CollectionBox<String> box = await boxCollection.openBox<String>(boxName);
    await box.delete(key);
  }

  Future<String?> get(String boxName, String key) async {
    BoxCollection boxCollection = await _getCollection(boxName);
    CollectionBox<String> box = await boxCollection.openBox<String>(boxName);
    return box.get(key);
  }

  Future<T?> getEntity<T>(String boxName, String key, T Function(Map<String, dynamic> json) fromJson) async {
    var json = await get(boxName, key);
    if (json == null) {
      return null;
    }
    return fromJson(jsonDecode(json));
  }

  Future<Map<String, String>> getAllValues(String boxName) async {
    BoxCollection boxCollection = await _getCollection(boxName);
    CollectionBox<String> box = await boxCollection.openBox<String>(boxName);
    var values = await box.getAllValues();
    return values;
  }

  Future<Map<String,T>> getAllEntity<T>(String boxName, T Function(Map<String, dynamic> json) fromJson) async {
    var values = await getAllValues(boxName);
    return values.map((key, value) => MapEntry(key, fromJson(jsonDecode(value))));
  }

  Future<List<String?>> getValueByKeys(String boxName, List<String> keys) async {
    BoxCollection boxCollection = await _getCollection(boxName);
    CollectionBox<String> box = await boxCollection.openBox<String>(boxName);
    var values = await box.getAll(keys);
    return values;
  }

  Future<List<T?>> getEntityByKeys<T>(String boxName, List<String> keys, T Function(Map<String, dynamic> json) fromJson) async {
    var values = await getValueByKeys(boxName, keys);
    return values.map((e) => e == null ? null : fromJson(jsonDecode(e))).toList();
  }

  Future<void> clear(String boxName) async {
    BoxCollection boxCollection = await _getCollection(boxName);
    CollectionBox<String> box = await boxCollection.openBox<String>(boxName);
    await box.clear();
  }

  Future<void> deleteByKeys(String boxName, List<String> keys) async {
    BoxCollection boxCollection = await _getCollection(boxName);
    CollectionBox<String> box = await boxCollection.openBox<String>(boxName);
    await box.deleteAll(keys);
  }

}