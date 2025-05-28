import 'dart:async';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';

import 'ai_chat_utils.dart';
import 'chat_localizations.dart';

class HiveChatController
    with UploadProgressMixin, ScrollToMessageMixin
    implements ChatController {
  String? _currentSessionId;
    ChatLocalizations? localizations;
  final Map<String, Box> _sessionBoxes = {};
  final _operationsController = StreamController<ChatOperation>.broadcast();
  final _uuid = const Uuid();

  // Initialize the controller with a default session
  HiveChatController() {
    var cSessionId = AIChatUtils.loadCurrentSessionId();
    _currentSessionId = cSessionId ?? _uuid.v4();
    _openBox(_currentSessionId!);
    if (cSessionId == null) {
      _addSessionToMetadata(_currentSessionId!,
          '${localizations?.session??'会话'} ${DateTime.now().toString().substring(0, 10)}');
    }
  }

  // Open or get a Hive box for a specific session
  Future<Box> _openBox(String sessionId) async {
    if (!_sessionBoxes.containsKey(sessionId)) {
      _sessionBoxes[sessionId] = await Hive.openBox('${AIChatUtils.currentApiKey}_chat_$sessionId');
    }
    return _sessionBoxes[sessionId]!;
  }

  // Add session metadata to the sessions box
  Future<void> _addSessionToMetadata(String sessionId, String title) async {
    final sessionsBox = await Hive.openBox('${AIChatUtils.currentApiKey}_sessions');
    await sessionsBox.put(sessionId, {
      'id': sessionId,
      'title': title,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    });
  }

  // Start a new session
  String startNewSession({String? title}) {
    _currentSessionId = _uuid.v4();
    AIChatUtils.saveCurrentSessionId(_currentSessionId);
    _openBox(_currentSessionId!);
    _addSessionToMetadata(
      _currentSessionId!,
      title ?? '${localizations?.session??'会话'} ${DateTime.now().toString().substring(0, 10)}',
    );
    _operationsController.add(ChatOperation.set([]));
    return _currentSessionId!;
  }

  // Save current session (optional, as messages are saved in real-time)
  Future<void> saveSession(String sessionId) async {
    final box = await _openBox(sessionId);
    await box.flush(); // Ensure all data is written to disk
  }

  // Load a specific session
  Future<void> loadSession(String sessionId) async {
    if (_currentSessionId != sessionId) {
      _currentSessionId = sessionId;
      AIChatUtils.saveCurrentSessionId(sessionId);
      await _openBox(sessionId);
      _operationsController.add(ChatOperation.set(messages));
    }
  } // Load a specific session

  Future<void> loadCurrentSession() async {
    if (_currentSessionId != null) {
      await _openBox(_currentSessionId!);
      _operationsController.add(ChatOperation.set(messages));
    }
  }

  // Get all session IDs and metadata
  List<Map<String, dynamic>> getSessions() {
    final sessionsBox = Hive.box('${AIChatUtils.currentApiKey}_sessions');
    return sessionsBox.values
        .whereType<Map>()
        .map((map) => map.map((key, value) => MapEntry(key.toString(), value)))
        .toList()
      ..sort((a, b) =>
          DateTime.parse(b['createdAt'])
              .compareTo(DateTime.parse(a['createdAt'])));
  }

  // Get current session ID
  String? get currentSessionId => _currentSessionId;

  set setCurrentSessionId(String? value) {
    _currentSessionId = value;
  }

  @override
  Future<void> insertMessage(Message message, {int? index}) async {
    if (_currentSessionId == null) return;
    final box = await _openBox(_currentSessionId!);
    if (box.containsKey(message.id)) return;

    await box.put(message.id, message.toJson());
    _operationsController
        .add(ChatOperation.insert(message, messages.length - 1));
  }

  @override
  Future<void> removeMessage(Message message) async {
    if (_currentSessionId == null) return;
    final box = await _openBox(_currentSessionId!);
    final sortedMessages = List.from(messages);
    final index = sortedMessages.indexWhere((m) => m.id == message.id);

    if (index != -1) {
      final messageToRemove = sortedMessages[index];
      await box.delete(messageToRemove.id);
      _operationsController.add(ChatOperation.remove(messageToRemove, index));
    }
  }

  @override
  Future<void> updateMessage(Message oldMessage, Message newMessage) async {
    if (_currentSessionId == null) return;
    final box = await _openBox(_currentSessionId!);
    final sortedMessages = List.from(messages);
    final index = sortedMessages.indexWhere((m) => m.id == oldMessage.id);

    if (index != -1) {
      final actualOldMessage = sortedMessages[index];
      if (actualOldMessage == newMessage) return;

      await box.put(actualOldMessage.id, newMessage.toJson());
      _operationsController.add(
        ChatOperation.update(actualOldMessage, newMessage, index),
      );
    }
  }

  @override
  Future<void> setMessages(List<Message> messages) async {
    if (_currentSessionId == null) return;
    final box = await _openBox(_currentSessionId!);
    await box.clear();
    if (messages.isEmpty) {
      _operationsController.add(ChatOperation.set([]));
      return;
    } else {
      await box.putAll(
        messages
            .map((message) => {message.id: message.toJson()})
            .toList()
            .reduce((acc, map) => {...acc, ...map}),
      );
      _operationsController.add(ChatOperation.set(messages));
    }
  }

  @override
  Future<void> insertAllMessages(List<Message> messages, {int? index}) async {
    if (_currentSessionId == null || messages.isEmpty) return;
    final box = await _openBox(_currentSessionId!);
    final originalLength = box.length;
    await box.putAll(
      messages
          .map((message) => {message.id: message.toJson()})
          .toList()
          .reduce((acc, map) => {...acc, ...map}),
    );
    _operationsController.add(
      ChatOperation.insertAll(messages, originalLength),
    );
  }

  @override
  List<Message> get messages {
    if (_currentSessionId == null) return [];
    final box = _sessionBoxes[_currentSessionId!];
    if (box == null) return [];

    var boxValues = box.values;
    List<Message> m = [];
    try {
      m = boxValues
          .map((json) {
        if (json is Map) {
          final convertedMap =
          json.map((key, value) => MapEntry(key.toString(), value));
          return Message.fromJson(convertedMap);
        }
        return null;
      })
          .whereType<Message>()
          .toList()
        ..sort(
              (a, b) =>
              (a.createdAt?.millisecondsSinceEpoch ?? 0).compareTo(
                b.createdAt?.millisecondsSinceEpoch ?? 0,
              ),
        );
    } catch (e) {
      print('Error in messages getter: $e');
    }
    return m;
  }

  @override
  Stream<ChatOperation> get operationsStream => _operationsController.stream;

  @override
  Future<void> clearMessages() async {
    if (_currentSessionId == null) return;
    final box = await _openBox(_currentSessionId!);
    await box.clear();
    _operationsController.add(ChatOperation.set([]));
  }

  // Delete a specific session
  Future<void> deleteSession(String sessionId) async {
    if (_sessionBoxes.containsKey(sessionId)) {
      final box = _sessionBoxes[sessionId]!;
      await box.clear();
      await box.deleteFromDisk();
      _sessionBoxes.remove(sessionId);
    }
    final sessionsBox = await Hive.openBox('${AIChatUtils.currentApiKey}_sessions');
    await sessionsBox.delete(sessionId);
    if (_currentSessionId == sessionId) {
      if (_sessionBoxes.isNotEmpty) {
        _currentSessionId = _sessionBoxes.keys.last;
        if (null == _currentSessionId) {
          startNewSession();
        } else {
          loadCurrentSession();
        }
      } else {
        _currentSessionId = null;
        startNewSession();
      }
    } else {
      AIChatUtils.saveCurrentSessionId(_currentSessionId);
    }
  }

  @override
  void dispose() {
    _operationsController.close();
    for (var box in _sessionBoxes.values) {
      box.close();
    }
    _sessionBoxes.clear();
    Hive.box('${AIChatUtils.currentApiKey}_sessions').close();
    disposeUploadProgress();
    disposeScrollMethods();
  }
}
