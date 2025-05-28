import 'package:flutter/foundation.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flyer_chat_text_stream_message/flyer_chat_text_stream_message.dart';

class AIChatStreamManager extends ChangeNotifier {
  final ChatController _chatController;
  final Duration _chunkAnimationDuration;
  final Map<String, StreamState> _streamStates = {};
  final Map<String, TextStreamMessage> _originalMessages = {};
  final Map<String, String> _accumulatedTexts = {};

  AIChatStreamManager({
    required ChatController chatController,
    required Duration chunkAnimationDuration,
  })  : _chatController = chatController,
        _chunkAnimationDuration = chunkAnimationDuration;

  StreamState getState(String? streamId) {
    return _streamStates[streamId] ?? const StreamStateLoading();
  }

  void startStream(String streamId, TextStreamMessage originalMessage) {
    _originalMessages[streamId] = originalMessage;
    _streamStates[streamId] = const StreamStateLoading();
    _accumulatedTexts[streamId] = '';
    notifyListeners();
  }

  void addChunk(String streamId, String chunk) {
    if (!_streamStates.containsKey(streamId)) {
      return;
    }

    var processedChunk = chunk;
    if (processedChunk.endsWith('\n') && !processedChunk.endsWith('\n\n')) {
      processedChunk = processedChunk.substring(0, processedChunk.length - 1);
    }

    _accumulatedTexts[streamId] = (_accumulatedTexts[streamId] ?? '') + processedChunk;
    _streamStates[streamId] = StreamStateStreaming(_accumulatedTexts[streamId]!);
    notifyListeners();
  }

  Future<void> completeStream(String streamId) async {
    final finalText = _accumulatedTexts[streamId];
    if (finalText == null) {
      debugPrint('AIChatStreamManager: Cannot complete stream, missing accumulated text for $streamId');
      _cleanupStream(streamId);
      return;
    }

    await Future.delayed(_chunkAnimationDuration);
    final originalMessage = _originalMessages[streamId];
    if (originalMessage == null) {
      debugPrint('AIChatStreamManager: State for $streamId was cleaned up during delay. Skipping update.');
      return;
    }

    final finalTextMessage = TextMessage(
      id: originalMessage.id,
      authorId: originalMessage.authorId,
      createdAt: originalMessage.createdAt,
      text: finalText,
    );

    try {
      await _chatController.updateMessage(originalMessage, finalTextMessage);
    } catch (e) {
      debugPrint('AIChatStreamManager: Failed to update message $streamId after delay: $e');
    } finally {
      _cleanupStream(streamId);
    }
  }

  Future<void> errorStream(String streamId, Object error) async {
    final originalMessage = _originalMessages[streamId];
    final currentText = _accumulatedTexts[streamId] ?? '';

    if (originalMessage == null) {
      debugPrint('AIChatStreamManager: Cannot error stream, missing original message for $streamId');
      _cleanupStream(streamId);
      return;
    }

    final errorTextMessage = TextMessage(
      id: originalMessage.id,
      authorId: originalMessage.authorId,
      createdAt: originalMessage.createdAt,
      text: '$currentText\n\n[Error generating response]',
    );

    try {
      await _chatController.updateMessage(originalMessage, errorTextMessage);
    } catch (e) {
      debugPrint('AIChatStreamManager: Failed to update message $streamId after error: $e');
    }

    _cleanupStream(streamId);
  }

  void _cleanupStream(String streamId) {
    _streamStates.remove(streamId);
    _originalMessages.remove(streamId);
    _accumulatedTexts.remove(streamId);
    notifyListeners();
  }

  // Added reset method to clear all stream states
  void reset() {
    _streamStates.clear();
    _originalMessages.clear();
    _accumulatedTexts.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _streamStates.clear();
    _originalMessages.clear();
    _accumulatedTexts.clear();
    super.dispose();
  }
}