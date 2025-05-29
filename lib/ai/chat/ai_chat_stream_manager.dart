import 'package:flutter/foundation.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flyer_chat_text_stream_message/flyer_chat_text_stream_message.dart';

class AIChatStreamManager extends ChangeNotifier {
  final ChatController _chatController;
  final Duration _chunkAnimationDuration;
  final Map<String, StreamState> _streamStates = {};
  final Map<String, int> _streamLengthMap = {};
  final Map<String, TextStreamMessage> _originalMessages = {};
  final Map<String, String> _accumulatedTexts = {};
  final Map<String, int> chunkAnimationDurationMap = {};

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
    _streamLengthMap.clear();
    notifyListeners();
  }

  void addChunk(String streamId, String chunk) {
    chunkAnimationDurationMap[streamId] = 0;
    const int maxChunkSize = 20;
    if (chunk.length <= maxChunkSize) {
      addChunk_(streamId, chunk);
      chunkAnimationDurationMap[streamId] =
          getChunkAnimationDuration_(chunk.length).inMilliseconds;
      return;
    }

    for (int index = 0; index < chunk.length; index += maxChunkSize) {
      final endIndex = (index + maxChunkSize).clamp(0, chunk.length);
      final subChunk = chunk.substring(index, endIndex);

      debugPrint('AIChatStreamManager: addChunk_ $streamId _ ${index}');
      addChunk_(streamId, subChunk);

      var subDuration =
          getChunkAnimationDuration_(subChunk.length).inMilliseconds;
      if (chunkAnimationDurationMap.containsKey(streamId)) {
        chunkAnimationDurationMap[streamId] =
            chunkAnimationDurationMap[streamId]! + subDuration;
      } else {
        chunkAnimationDurationMap[streamId] = subDuration;
      }
    }
  }

  void addChunk_(String streamId, String chunk) {
    if (!_streamStates.containsKey(streamId)) {
      return;
    }
    _streamLengthMap[streamId] = chunk.length;

    var processedChunk = chunk;
    if (processedChunk.endsWith('\n') && !processedChunk.endsWith('\n\n')) {
      processedChunk = processedChunk.substring(0, processedChunk.length - 1);
    }

    _accumulatedTexts[streamId] =
        (_accumulatedTexts[streamId] ?? '') + processedChunk;
    _streamStates[streamId] =
        StreamStateStreaming(_accumulatedTexts[streamId]!);
    notifyListeners();
  }

  Future<void> completeStream(String streamId) async {
    final finalText = _accumulatedTexts[streamId];
    if (finalText == null) {
      debugPrint(
          'AIChatStreamManager: Cannot complete stream, missing accumulated text for $streamId');
      _cleanupStream(streamId);
      return;
    }

// await Future.delayed(getChunkAnimationDuration(streamId));

    var sleepDuration = chunkAnimationDurationMap[streamId] ??
        getChunkAnimationDuration(streamId).inMilliseconds;

    await Future.delayed(Duration(milliseconds: sleepDuration));

    debugPrint(
        'AIChatStreamManager: addChunk_ $streamId _ sleep: $sleepDuration');

    final originalMessage = _originalMessages[streamId];
    if (originalMessage == null) {
      debugPrint(
          'AIChatStreamManager: State for $streamId was cleaned up during delay. Skipping update.');
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
      debugPrint(
          'AIChatStreamManager: Failed to update message $streamId after delay: $e');
    } finally {
      _cleanupStream(streamId);
    }
  }

  Future<void> errorStream(String streamId, Object error) async {
    final originalMessage = _originalMessages[streamId];
    final currentText = _accumulatedTexts[streamId] ?? '';

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
      text: '$currentText\n\n[Error generating response]',
    );

    try {
      await _chatController.updateMessage(originalMessage, errorTextMessage);
    } catch (e) {
      debugPrint(
          'AIChatStreamManager: Failed to update message $streamId after error: $e');
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

  Duration getChunkAnimationDuration(String streamId) {
    const defaultDuration = Duration(milliseconds: 350);

    if (_streamLengthMap.containsKey(streamId)) {
      final sl = _streamLengthMap[streamId] ?? 0;
      return getChunkAnimationDuration_(sl);
    } else {
      debugPrint(
          'AIChatStreamManager: Calculated duration for $streamId: ${defaultDuration.inMicroseconds}  --  001');
      return defaultDuration;
    }
  }

  Duration getChunkAnimationDuration_(int truckLength) {
    const defaultDuration = Duration(milliseconds: 350); // 默认动画时长
    const minDuration = Duration(milliseconds: 200); // 最小动画时长
    const maxDuration = Duration(milliseconds: 800); // 最大动画时长
    const baseLength = 20; // 基准文本长度
    const scalingFactor = 15.0; // 每增加 baseLength 字符，增加 15ms

    final sl = truckLength;
    if (sl <= baseLength) {
      debugPrint(
          'AIChatStreamManager: Calculated duration for  ${defaultDuration.inMilliseconds} -- 000');
      return defaultDuration;
    } else {
// 线性增长，但限制在 minDuration 和 maxDuration 之间
      final calculatedDuration =
          defaultDuration.inMilliseconds + (sl / baseLength) * scalingFactor;
      final clampedDuration = calculatedDuration.clamp(
        minDuration.inMilliseconds,
        maxDuration.inMilliseconds,
      );
      debugPrint(
          'AIChatStreamManager: Calculated duration for $clampedDuration -- ${sl}');
      return Duration(milliseconds: clampedDuration.toInt());
    }
  }
}
