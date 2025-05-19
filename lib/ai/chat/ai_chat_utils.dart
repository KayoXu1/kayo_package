import 'package:hive_ce_flutter/hive_flutter.dart';

class AIChatUtils {
  static init() async {
    await Hive.initFlutter();
    await Hive.openBox('chat');
  }
}
