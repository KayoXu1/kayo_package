import 'package:flutter/foundation.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart'; // Ensure this import path is correct
import 'package:flyer_chat_text_stream_message/flyer_chat_text_stream_message.dart';

// Assuming ChatController is from flutter_chat_core or a compatible package
// If it's a custom ChatController, ensure it has the updateMessage method.
// import type { ChatController } from 'flutter_chat_core'; // This is conceptual

class AIChatStreamManager extends ChangeNotifier {
  final ChatController _chatController;

  // final Duration _chunkAnimationDuration; // Keep if FlyerChatTextStreamMessage still uses it meaningfully
  final Map<String, StreamState> _streamStates = {};

  // _streamLengthMap is less relevant for per-character, but harmless
  // final Map<String, int> _streamLengthMap = {};
  final Map<String, TextStreamMessage> _originalMessages = {};
  final Map<String, String> _accumulatedTexts = {};

  // chunkAnimationDurationMap is likely not needed for per-character typing effect's main delay
  // final Map<String, int> chunkAnimationDurationMap = {};

  // Define the delay for each character to appear
  static const Duration _kCharacterTypingDelay =
  Duration(milliseconds: 30); // Adjust for typing speed (e.g., 30-80ms)

  AIChatStreamManager({
    required ChatController chatController,
    required Duration
    chunkAnimationDuration, // This is passed to FlyerChatTextStreamMessage
  }) : _chatController = chatController;

  // _chunkAnimationDuration = chunkAnimationDuration;

  StreamState getState(String? streamId) {
    return _streamStates[streamId] ?? const StreamStateLoading();
  }

  void startStream(String streamId, TextStreamMessage originalMessage) {
    _originalMessages[streamId] = originalMessage;
    _streamStates[streamId] = const StreamStateLoading();
    _accumulatedTexts[streamId] = '';
    // _streamLengthMap.clear(); // Not strictly needed if we don't use it heavily
    notifyListeners();
  }

  void _addSingleCharacterOrSmallChunk(String streamId, String charContent) {
    if (!_streamStates.containsKey(streamId) ||
        _originalMessages[streamId] == null) {
      return;
    }

    final current = (_accumulatedTexts[streamId] ?? '') + charContent;

    final normalized = current.replaceAll(RegExp(r'\n{2,}'), '\n');

    _accumulatedTexts[streamId] = normalized;
    _streamStates[streamId] = StreamStateStreaming(normalized);

    notifyListeners();
  }

  // Modify addChunk to be async and process character by character
  Future<void> addChunk(String streamId, String chunk) async {
    if (!_streamStates.containsKey(streamId) ||
        _originalMessages[streamId] == null) {
      debugPrint('AIChatStreamManager: addChunk called for non-existent or completed stream $streamId');
      return;
    }


    String cleanedChunk = chunk.replaceAll(RegExp(r'\n{2,}'), '\n');

    for (int i = 0; i < cleanedChunk.length; i++) {
      if (!_streamStates.containsKey(streamId) ||
          _originalMessages[streamId] == null) {
        debugPrint('AIChatStreamManager: Stream $streamId was cleaned up mid-chunk processing.');
        return;
      }

      final char = cleanedChunk[i];
      _addSingleCharacterOrSmallChunk(streamId, char);

      await Future.delayed(_kCharacterTypingDelay);
    }
  }

  Future<void> completeStream(String streamId) async {
    // A short delay to ensure the last character has "typed out"
    // and UI has a chance to render before finalizing.
    await Future.delayed(
        _kCharacterTypingDelay * 2); // e.g., twice the char delay

    final rawFinalText = _accumulatedTexts[streamId];
    final finalText = rawFinalText; //?.replaceAll(RegExp(r'\n{2,}'), '\n');
    final originalMessage = _originalMessages[streamId];

    if (finalText == null || originalMessage == null) {
      debugPrint(
          'AIChatStreamManager: Cannot complete stream $streamId. Missing accumulated text or original message.');
      _cleanupStream(streamId);
      return;
    }

    // Check if the stream was already cleaned up (e.g. by an error)
    // This can happen if an error occurs and errorStream is called, cleaning up,
    // then completeStream is called from a finally block.
    if (!_streamStates.containsKey(streamId) &&
        !_originalMessages.containsKey(streamId)) {
      debugPrint(
          'AIChatStreamManager: Stream $streamId was already cleaned up before completion logic.');
      return;
    }

    final finalTextMessage = TextMessage(
      id: originalMessage.id,
      authorId: originalMessage.authorId,
      createdAt: originalMessage.createdAt,
      text: finalText,
      // Copy other relevant fields from originalMessage if necessary
      // remoteId: originalMessage.remoteId,
      // repliedTo: originalMessage.repliedTo,
      // roomId: originalMessage.roomId,
      // showStatus: originalMessage.showStatus,
      // status: originalMessage.status, // Final status would be 'delivered' or 'seen'
      // type: originalMessage.type, // Should remain MessageType.text
      // uri: originalMessage.uri,
      // metadata: originalMessage.metadata, // Carry over metadata if any
    );

    try {
      // Ensure _chatController can handle TextStreamMessage -> TextMessage update
      await _chatController.updateMessage(finalTextMessage,
          finalTextMessage); // Update with the final TextMessage
    } catch (e) {
      debugPrint(
          'AIChatStreamManager: Failed to update message $streamId to final TextMessage: $e');
      // Optionally, handle this error more gracefully, e.g., by calling errorStream
    } finally {
      _cleanupStream(streamId);
    }
  }

  Future<void> errorStream(String streamId, Object error) async {
    // Small delay for consistency if needed
    // await Future.delayed(_kCharacterTypingDelay);

    final originalMessage = _originalMessages[streamId];
    final rawText = _accumulatedTexts[streamId] ?? '';
    final currentText = rawText; //.replaceAll(RegExp(r'\n{2,}'), '\n');

    if (originalMessage == null) {
      debugPrint(
          'AIChatStreamManager: Cannot error stream, missing original message for $streamId');
      _cleanupStream(streamId);
      return;
    }

    final errorTextMessage = TextMessage(
      id: originalMessage.id,
      authorId: originalMessage.authorId,
      createdAt: originalMessage.createdAt,
      text: '$currentText\n\n[Error generating response: ${error.toString()}]',
      // Consider adding metadata to indicate this message ended in an error
      // metadata: { ...originalMessage.metadata, 'hasError': true },
    );

    try {
      await _chatController.updateMessage(
          errorTextMessage, errorTextMessage); // Update with error TextMessage
    } catch (e) {
      debugPrint(
          'AIChatStreamManager: Failed to update message $streamId to error TextMessage: $e');
    }
    _cleanupStream(streamId);
  }

  void _cleanupStream(String streamId) {
    _streamStates.remove(streamId);
    _originalMessages.remove(streamId);
    _accumulatedTexts.remove(streamId);
    // _streamLengthMap.remove(streamId);
    // chunkAnimationDurationMap.remove(streamId);
    notifyListeners();
  }

  void reset() {
    _streamStates.clear();
    _originalMessages.clear();
    _accumulatedTexts.clear();
    // _streamLengthMap.clear();
    // chunkAnimationDurationMap.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _streamStates.clear();
    _originalMessages.clear();
    _accumulatedTexts.clear();
    // _streamLengthMap.clear();
    // chunkAnimationDurationMap.clear();
    super.dispose();
  }

// The getChunkAnimationDuration_ and getChunkAnimationDuration methods
// are no longer directly used for the per-character typing effect's delay.
// However, FlyerChatTextStreamMessage still takes _kChunkAnimationDuration.
// If that component does its own animation over that duration for each text update,
// you might want it to be very short (e.g., Duration.zero or ~50ms) so it doesn't
// interfere with the character-by-character "typing" illusion.
// The existing _kChunkAnimationDuration in AIChatPage is 350ms.
// This might make each character "animate in" over 350ms, which is not ideal.
// You may need to adjust the `chunkAnimationDuration` prop for `FlyerChatTextStreamMessage`
// in `AIChatPage.build` to a much smaller value or even `Duration.zero`
// if its internal animation is too slow for the character-by-character effect.
}
