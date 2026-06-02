import 'package:hive_flutter/hive_flutter.dart';
import 'package:ecommerce_app/core/constants/storage_constants.dart';

class LocalStorage {
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(StorageConstants.cartBox);
    await Hive.openBox(StorageConstants.sessionBox);
    await Hive.openBox(StorageConstants.productsBox);
  }

  static Box get cartBox => Hive.box(StorageConstants.cartBox);
  static Box get sessionBox => Hive.box(StorageConstants.sessionBox);
  static Box get productsBox => Hive.box(StorageConstants.productsBox);

  static Future<void> clearAll() async {
    await cartBox.clear();
    await sessionBox.clear();
    await productsBox.clear();
  }
}
