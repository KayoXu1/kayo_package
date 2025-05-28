import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'messageAdapter.dart';

class AIChatUtils {
  static const _sessionKey = 'current_session_id';
  static SharedPreferences? _prefs;

  static String currentApiKey = '';

  static init() async {
    await initShared();
    await Hive.initFlutter();
    Hive.registerAdapter(MessageAdapter());
    // await Hive.openBox('sessions');
  }

  static openBox(String apiKey) async {
    currentApiKey = apiKey;
    await Hive.openBox('${currentApiKey}_sessions');
  }

  
  static initShared() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String? loadCurrentSessionId() {
    final savedId = _prefs?.getString(_sessionKey);
    return savedId;
  }

  static saveCurrentSessionId(String? currentSessionId) {
    if (currentSessionId != null) {
      _prefs?.setString(_sessionKey, currentSessionId!);
    } else {
      _prefs?.remove(_sessionKey);
    }
  }
}
