import 'package:cross_cache/cross_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flyer_chat_image_message/flyer_chat_image_message.dart';
import 'package:flyer_chat_text_message/flyer_chat_text_message.dart';
import 'package:flyer_chat_text_stream_message/flyer_chat_text_stream_message.dart';
import 'package:kayo_package/kayo_package.dart';
import 'package:kayo_package/utils/base_sys_utils.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:hive_ce/hive.dart';
import 'ai_chat_stream_manager.dart';
import 'chat_localizations.dart';
import 'chat_service.dart';
import 'hive_chat_controller.dart';
import 'package:package_info_plus/package_info_plus.dart';

const Duration _kChunkAnimationDuration = Duration(milliseconds: 350);

class AIChatPage extends StatefulWidget {
  final String title;
  final String apiKey;
  final String apiUrl;
  final String userId;
  final String? hintText;
  final ChatLocalizations? localizations;

  const AIChatPage({
    super.key,
    required this.title,
    required this.apiKey,
    required this.apiUrl,
    required this.userId,
    this.hintText,
    this.localizations,
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
  final Map<String, double> _initialScrollExtents = {};
  final Map<String, bool> _reachedTargetScroll = {};

  @override
  void initState() {
    super.initState();
    _chatController.localizations = widget.localizations;
    _streamManager = AIChatStreamManager(
      chatController: _chatController,
      chunkAnimationDuration: _kChunkAnimationDuration,
    );
    chatService = ChatService(
      baseUrl: widget.apiUrl,
      apiKey: widget.apiKey,
      userId: widget.userId,
    );
    Future.delayed(Duration.zero, () async {
      await _chatController.loadCurrentSession();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _streamManager.dispose();
    _chatController.dispose();
    _scrollController.dispose();
    _crossCache.dispose();
    super.dispose();
  }

  void _startNewChat() async {
    try {
      final messages = _chatController.messages;
      if (messages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.localizations?.noMessagesToStartNewChat ??
                '当前聊天为空，不能新建聊天'),
          ),
        );
        return;
      }

      if (_chatController.currentSessionId != null) {
        await _chatController.saveSession(_chatController.currentSessionId!);
      }

      _chatController.startNewSession();
      _streamManager.reset();
      _initialScrollExtents.clear();
      _reachedTargetScroll.clear();
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${widget.localizations?.startNewChatFailed ?? '创建新聊天失败'}: $e',
          ),
        ),
      );
    }
  }

  List<Widget> _buildHistoryItems() {
    final sessions = _chatController.getSessions();
    return sessions.map((session) {
      final sessionId = session['id'] as String;
      final title = session['title'] as String;
      final createdAt = DateTime.parse(session['createdAt'] as String);
      return ListTile(
        title: Text(title),
        subtitle: Text(
          createdAt.toLocal().toString().substring(0, 16),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(widget.localizations?.deleteSessionTitle ?? '删除会话'),
                content: Text(
                    widget.localizations?.deleteSessionConfirm ?? '确定要删除此会话吗？'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(widget.localizations?.cancel ?? '取消'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(widget.localizations?.delete ?? '删除'),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              try {
                await _chatController.deleteSession(sessionId);
                setState(() {});
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${widget.localizations?.deleteSessionFailed ?? '删除会话失败'}: $e',
                    ),
                  ),
                );
              }
            }
          },
        ),
        onTap: () async {
          try {
            await _chatController.loadSession(sessionId);
            if (_scrollController.hasClients) {
              _scrollController
                  .jumpTo(_scrollController.position.maxScrollExtent);
            }
            Navigator.pop(context);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${widget.localizations?.loadSessionFailed ?? '加载会话失败'}: $e',
                ),
              ),
            );
          }
        },
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        title: Text(widget.title),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: widget.localizations?.newChat ?? '新聊天',
            onPressed: _startNewChat,
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: theme.primaryColor,
              ),
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.localizations?.chatHistory ?? '聊天历史',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: _buildHistoryItems(),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(widget.localizations?.mine ?? '我的'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyProfilePage(
                      userId: widget.userId,
                      localizations: widget.localizations,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: ChangeNotifierProvider.value(
        value: _streamManager,
        child: Chat(
          builders: Builders(
            composerBuilder: (context) {
              return Composer(
                hintText: widget.hintText ??
                    widget.localizations?.startNewChatHintInput ??
                    '输入消息',
              );
            },
            chatAnimatedListBuilder: (context, itemBuilder) {
              return ChatAnimatedList(
                scrollController: _scrollController,
                itemBuilder: itemBuilder,
                shouldScrollToEndWhenAtBottom: false,
              );
            },
            emptyChatListBuilder: (context) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 150),
                  child: Text(
                    widget.localizations?.startNewChatHint ?? '开始新聊天吧！',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),
                ),
              );
            },
            imageMessageBuilder: (context, message, index) =>
                FlyerChatImageMessage(
              message: message,
              index: index,
              showTime: false,
              showStatus: false,
            ),
            textMessageBuilder: (context, message, index) {
              final isAgent = message.authorId == _agent.id;
              final textMessage = FlyerChatTextMessage(
                message: message,
                index: index,
                showTime: false,
                showStatus: false,
                receivedBackgroundColor: Colors.transparent,
                padding: isAgent
                    ? EdgeInsets.zero
                    : const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
              );

              if (isAgent) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    aiIcon(false),
                    Expanded(child: textMessage),
                  ],
                );
              } else {
                return textMessage;
              }
            },
            textStreamMessageBuilder: (context, message, index) {
              final streamState = context
                  .watch<AIChatStreamManager>()
                  .getState(message.streamId);
              final isFromAI = message.authorId == _agent.id;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isFromAI) aiIcon(true),
                  Flexible(
                    child: FlyerChatTextStreamMessage(
                      message: message,
                      index: index,
                      streamState: streamState,
                      chunkAnimationDuration: _kChunkAnimationDuration,
                      showTime: false,
                      showStatus: false,
                      receivedBackgroundColor: Colors.transparent,
                      padding: isFromAI
                          ? const EdgeInsets.symmetric(
                              horizontal: 1, vertical: 1)
                          : const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                    ),
                  ),
                ],
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

  Padding aiIcon(bool speaking) {
    return Padding(
      padding: EdgeInsets.only(left: 4.0, right: 8.0, top: 0),
      child: widget.localizations?.aiIcon != null
          ? ImageView(
              height: 20,
              width: 20,
              src: speaking
                  ? (widget.localizations?.aiIconSpeaking ??
                      widget.localizations?.aiIcon)
                  : widget.localizations!.aiIcon,
            )
          : Icon(Icons.smart_toy,
              size: 20, color: speaking ? Colors.blue : Colors.blueGrey),
    );
  }

  void _handleMessageSend(String text) async {
    BaseSysUtils.hideKeyboard(context);
    final message = TextMessage(
      id: _uuid.v4(),
      authorId: _currentUser.id,
      createdAt: DateTime.now().toUtc(),
      text: text,
      metadata: isOnlyEmoji(text) ? {'isOnlyEmoji': true} : null,
    );
    try {
      await _chatController.insertMessage(message);
      if (_chatController.messages.length == 1) {
        final sessionsBox =
            await Hive.openBox('${AIChatUtils.currentApiKey}_sessions');
        await sessionsBox.put(_chatController.currentSessionId, {
          'id': _chatController.currentSessionId,
          'title': text.length > 20 ? '${text.substring(0, 20)}...' : text,
          'createdAt': DateTime.now().toUtc().toIso8601String(),
          'lastConversationId': null, // Initialize for new session
        });
      }
      _sendContent(text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.localizations?.sendFailed ?? '发送消息失败'}: $e'),
        ),
      );
    }
  }

  void _sendContent(String content) async {
    final streamId = _uuid.v4();
    TextStreamMessage? streamMessage;
    _reachedTargetScroll[streamId] = false;

    try {
      streamMessage = TextStreamMessage(
        id: streamId,
        authorId: _agent.id,
        createdAt: DateTime.now().toUtc(),
        streamId: streamId,
      );
      await _chatController.insertMessage(streamMessage);
      _streamManager.startStream(streamId, streamMessage);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients && mounted) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.linearToEaseOut,
          );
        }
      });

      final response = chatService.sendMessageStream(
        query: content,
        conversationId: _chatController.lastConversationId,
        // Use controller's lastConversationId
        onConversationId: (d) {
          _chatController.lastConversationId = d; // Update lastConversationId
          if (_chatController.currentSessionId != null) {
            _chatController
                .saveSession(_chatController.currentSessionId!); // Save session
          }
        },
      );

      await for (final chunk in response) {
        if (chunk.text != null) {
          final textChunk = chunk.text!;
          if (textChunk.isEmpty) continue;

          _streamManager.addChunk(streamId, textChunk);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_scrollController.hasClients || !mounted) return;

            var initialExtent = _initialScrollExtents[streamId];
            final reachedTarget = _reachedTargetScroll[streamId] ?? false;

            if (reachedTarget) return;

            initialExtent ??= _initialScrollExtents[streamId] =
                _scrollController.position.maxScrollExtent;

            if (initialExtent > 0) {
              final targetScroll = initialExtent +
                  _scrollController.position.viewportDimension -
                  MediaQuery.of(context).padding.bottom -
                  168;

              if (_scrollController.position.maxScrollExtent > targetScroll) {
                _scrollController.animateTo(
                  targetScroll,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.linearToEaseOut,
                );
                _reachedTargetScroll[streamId] = true;
              } else {
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

      if (streamMessage != null) {
        await _streamManager.completeStream(streamId);
      }
    } catch (error) {
      debugPrint('Unhandled error for stream $streamId: $error');
      if (streamMessage != null) {
        await _streamManager.errorStream(streamId, error);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('${widget.localizations?.sendFailed ?? '发送消息失败'}: $error'),
        ),
      );
    } finally {
      _initialScrollExtents.remove(streamId);
      _reachedTargetScroll.remove(streamId);
    }
  }
}

class MyProfilePage extends StatefulWidget {
  final String userId;
  final ChatLocalizations? localizations;

  const MyProfilePage({super.key, required this.userId, this.localizations});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = info.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.localizations?.mine ?? '我的'),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Version: $_version',
              style: TextStyle(fontSize: 18, color: BaseColorUtils.colorAccent),
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: () {
                widget.localizations?.logout();
              },
              child: Text(widget.localizations?.userLoginExit ?? '退出登录'),
            ),
          ],
        ),
      ),
    );
  }
}
