abstract class ChatLocalizations {
  ///  当前聊天为空，不能新建聊天
  String get noMessagesToStartNewChat;

  ///  创建新聊天失败
  String get startNewChatFailed;

  ///  删除会话
  String get deleteSessionTitle;

  ///  确定要删除此会话吗?
  String get deleteSessionConfirm;

  ///  取消
  String get cancel;

  ///  删除
  String get delete;

  /// 删除会话失败
  String get deleteSessionFailed;

  /// 加载会话失败
  String get loadSessionFailed;

  ///  新聊天
  String get newChat;

  ///  聊天历史
  String get chatHistory;

  ///  我的
  String get mine;

  ///  开始新聊天吧
  String get startNewChatHint;

  /// 输入消息
  String get startNewChatHintInput;

  /// 发送消息失败
  String get sendFailed;

  /// 会话
  String get session;

  String get userLoginExit;

  String get aiIconSpeaking => "packages/kayo_package/assets/chat/ai_icon_speaking.png";

  String get aiIcon => "packages/kayo_package/assets/chat/ai_icon.png";

  bool get showUserProfile => true;

  bool get showCloseButton => false;

  void logout();
}
