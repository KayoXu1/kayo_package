abstract class ChatLocalizations {
  ///  当前聊天为空，不能新建聊天
  get noMessagesToStartNewChat;

  ///  创建新聊天失败
  get startNewChatFailed;

  ///  删除会话
  get deleteSessionTitle;

  ///  确定要删除此会话吗?
  get deleteSessionConfirm;

  ///  取消
  get cancel;

  ///  删除
  get delete;

  /// 删除会话失败
  get deleteSessionFailed;

  /// 加载会话失败
  get loadSessionFailed;

  ///  新聊天
  get newChat;

  ///  聊天历史
  get chatHistory;

  ///  我的
  get mine;

  ///  开始新聊天吧
  get startNewChatHint;

  /// 输入消息
  get startNewChatHintInput;

  /// 发送消息失败
  get sendFailed;

  /// 会话
  get session;

  get userLoginExit;

  get aiIconSpeaking => "packages/kayo_package/assets/chat/ai_icon_speaking.png";

  get aiIcon => "packages/kayo_package/assets/chat/ai_icon.png";

  bool get showUserProfile => true;

  bool get showCloseButton => false;

  void logout();
}
