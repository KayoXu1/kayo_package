import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';

class MessageAdapter extends TypeAdapter<Message> {
  @override
  final int typeId = 0;

  @override
  Message read(BinaryReader reader) {
    final map = reader.readMap().cast<String, dynamic>();
    return Message.fromJson(map);
  }

  @override
  void write(BinaryWriter writer, Message obj) {
    writer.writeMap(obj.toJson());
  }
}