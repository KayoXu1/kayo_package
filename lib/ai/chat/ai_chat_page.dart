import 'package:cross_cache/cross_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flyer_chat_image_message/flyer_chat_image_message.dart';
import 'package:flyer_chat_text_message/flyer_chat_text_message.dart';
import 'package:flyer_chat_text_stream_message/flyer_chat_text_stream_message.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kayo_package/utils/base_sys_utils.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'ai_chat_stream_manager.dart';
import 'chat_service.dart';
import 'hive_chat_controller.dart';

// Define the shared animation duration
const Duration _kChunkAnimationDuration = Duration(milliseconds: 350);

class AIChatPage extends StatefulWidget {
  final String title;
  final String apiKey;
  final String apiUrl;
  final String userId;
  final String? hintText;

  const AIChatPage({
    super.key,
    required this.title,
    required this.apiKey,
    required this.apiUrl,
    required this.userId,
    this.hintText,
  });

  @override
  AIChatPageState createState() => AIChatPageState();
}

class AIChatPageState extends State<AIChatPage> {
  final _uuid = const Uuid();
  final _crossCache = CrossCache();
  final _scrollController = ScrollController();
  final _chatController = HiveChatController();

  final _currentUser = const User(id: 'me');
  final _agent = const User(id: 'agent');

  late final AIChatStreamManager _streamManager;

  late final ChatService chatService;

  // Store scroll state per stream ID
  final Map<String, double> _initialScrollExtents = {};
  final Map<String, bool> _reachedTargetScroll = {};

  @override
  void initState() {
    super.initState();
    _streamManager = AIChatStreamManager(
      chatController: _chatController,
      chunkAnimationDuration: _kChunkAnimationDuration,
    );

    chatService = ChatService(
      baseUrl: widget.apiUrl,
      apiKey: widget.apiKey,
      userId: widget.userId,
    );
  }

  @override
  void dispose() {
    _streamManager.dispose();
    _chatController.dispose();
    _scrollController.dispose();
    _crossCache.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            tooltip: '清空记录',
            onPressed: () {
              _chatController.setMessages([]);
            },
          ),
        ],
      ),
      body: ChangeNotifierProvider.value(
        value: _streamManager,
        child: Chat(
          builders: Builders(
            composerBuilder: (context) {
              return Composer(hintText: widget.hintText ?? '输入消息');
            },
            chatAnimatedListBuilder: (context, itemBuilder) {
              return ChatAnimatedList(
                scrollController: _scrollController,
                itemBuilder: itemBuilder,
                shouldScrollToEndWhenAtBottom: false,
              );
            },
            imageMessageBuilder: (context, message, index) =>
                FlyerChatImageMessage(
              message: message,
              index: index,
              showTime: false,
              showStatus: false,
            ),
            textMessageBuilder: (context, message, index) =>
                FlyerChatTextMessage(
              message: message,
              index: index,
              showTime: false,
              showStatus: false,
              receivedBackgroundColor: Colors.transparent,
              padding: message.authorId == _agent.id
                  ? EdgeInsets.zero
                  : const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
            ),
            textStreamMessageBuilder: (context, message, index) {
              final streamState = context.watch<AIChatStreamManager>().getState(
                    message.streamId,
                  );
              return FlyerChatTextStreamMessage(
                message: message,
                index: index,
                streamState: streamState,
                chunkAnimationDuration: _kChunkAnimationDuration,
                showTime: false,
                showStatus: false,
                receivedBackgroundColor: Colors.transparent,
                padding: message.authorId == _agent.id
                    ? const EdgeInsets.symmetric(
                  horizontal: 1,
                  vertical: 1,
                )
                    : const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
              );
            },
          ),
          chatController: _chatController,
          crossCache: _crossCache,
          currentUserId: _currentUser.id,
          onMessageSend: _handleMessageSend,
          resolveUser: (id) => Future.value(switch (id) {
            'me' => _currentUser,
            'agent' => _agent,
            _ => null,
          }),
          theme: ChatTheme.fromThemeData(theme),
        ),
      ),
    );
  }

  void _handleMessageSend(String text) async {
    BaseSysUtils.hideKeyboard(context);

    await _chatController.insertMessage(
      TextMessage(
        id: _uuid.v4(),
        authorId: _currentUser.id,
        createdAt: DateTime.now().toUtc(),
        text: text,
        metadata: isOnlyEmoji(text) ? {'isOnlyEmoji': true} : null,
      ),
    );

    _sendContent(text);
  }

  void _sendContent(String content) async {
    // Generate a unique ID for the stream
    final streamId = _uuid.v4();
    TextStreamMessage? streamMessage;

    // Store scroll state per stream ID
    _reachedTargetScroll[streamId] = false;

    try {
      // Create and insert the stream message immediately to show loading state
      streamMessage = TextStreamMessage(
        id: streamId,
        authorId: _agent.id,
        createdAt: DateTime.now().toUtc(),
        streamId: streamId,
      );
      await _chatController.insertMessage(streamMessage);
      _streamManager.startStream(streamId, streamMessage);

      // Scroll to bottom immediately to show the loading message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients && mounted) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.linearToEaseOut,
          );
        }
      });

      final response = chatService.sendMessageStream(query: content);

      await for (final chunk in response) {
        if (chunk.text != null) {
          final textChunk = chunk.text!;
          if (textChunk.isEmpty) continue; // Skip empty chunks

          // Send chunk to the manager - this triggers notifyListeners
          _streamManager.addChunk(streamId, textChunk);

          // Schedule scroll check after the frame rebuilds
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_scrollController.hasClients || !mounted) return;

            // Retrieve state for this specific stream
            var initialExtent = _initialScrollExtents[streamId];
            final reachedTarget = _reachedTargetScroll[streamId] ?? false;

            if (reachedTarget) return; // Already scrolled to target

            // Store initial extent after first chunk caused rebuild
            initialExtent ??= _initialScrollExtents[streamId] =
                _scrollController.position.maxScrollExtent;

            // Only scroll if the list is scrollable
            if (initialExtent > 0) {
              // Calculate target scroll position
              final targetScroll = initialExtent +
                  _scrollController.position.viewportDimension -
                  MediaQuery.of(context).padding.bottom -
                  168; // height of the composer + height of the app bar + visual buffer of 8

              if (_scrollController.position.maxScrollExtent > targetScroll) {
                _scrollController.animateTo(
                  targetScroll,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.linearToEaseOut,
                );
                // Mark that we've reached the target for this stream
                _reachedTargetScroll[streamId] = true;
              } else {
                // If we haven't reached target position yet, scroll to bottom
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.linearToEaseOut,
                );
              }
            }
          });
        }
      }

      // Stream completed successfully
      if (streamMessage != null) {
        await _streamManager.completeStream(streamId);
      }
    } catch (error) {
      // Catch errors during stream processing
      debugPrint('Unhandled error for stream $streamId: $error');
      if (streamMessage != null) {
        await _streamManager.errorStream(streamId, error);
      }
    } finally {
      // Clean up scroll state for this stream ID when done/errored
      _initialScrollExtents.remove(streamId);
      _reachedTargetScroll.remove(streamId);
    }
  }
}
