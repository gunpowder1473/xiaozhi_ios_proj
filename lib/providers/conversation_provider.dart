import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:ai_xiaozhi/models/conversation.dart';
import 'package:ai_xiaozhi/models/message.dart';
import 'package:path_provider/path_provider.dart';

class ConversationProvider extends ChangeNotifier {
  List<Conversation> _conversations = [];
  Map<String, List<Message>> _messages = {};

  // 保存最后删除的会话及其消息，用于撤销删除
  Conversation? _lastDeletedConversation;
  List<Message>? _lastDeletedMessages;

  List<Conversation> get conversations => _conversations;
  List<Conversation> get pinnedConversations =>
      _conversations.where((conv) => conv.isPinned).toList();
  List<Conversation> get unpinnedConversations =>
      _conversations.where((conv) => !conv.isPinned).toList();

  ConversationProvider() {
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    final prefs = await SharedPreferences.getInstance();

    // Load conversations
    final conversationsJson = prefs.getStringList('conversations') ?? [];
    _conversations =
        conversationsJson
            .map((json) => Conversation.fromJson(jsonDecode(json)))
            .toList();

    // Load messages for each conversation
    for (final conversation in _conversations) {
      final messagesJson =
          prefs.getStringList('messages_${conversation.id}') ?? [];

      try {
        _messages[conversation.id] =
            messagesJson.map((json) {
              final decoded = jsonDecode(json);
              return Message.fromJson(decoded);
            }).toList();

        // 打印图片消息的信息
        for (final message in _messages[conversation.id] ?? []) {
          if (message.isImage) {
            // 检查图片文件是否存在
            if (message.imageLocalPath != null) {
              final imageFile = File(message.imageLocalPath!);
              final exists = await imageFile.exists();
            }
          }
        }

        // 确保每个会话的图片目录存在
        final appDir = await getApplicationDocumentsDirectory();
        final conversationDir = Directory(
          '${appDir.path}/conversations/${conversation.id}/images',
        );
        if (!await conversationDir.exists()) {
          await conversationDir.create(recursive: true);
        }
      } catch (e, stackTrace) {
        print('加载会话 ${conversation.id} 的消息时出错: $e');
        print('堆栈跟踪: $stackTrace');
        // 如果某个会话的消息加载失败，继续加载其他会话
        _messages[conversation.id] = [];
      }
    }

    notifyListeners();
  }

  Future<void> _saveConversations() async {
    final prefs = await SharedPreferences.getInstance();

    // Save conversations
    final conversationsJson =
        _conversations
            .map((conversation) => jsonEncode(conversation.toJson()))
            .toList();
    await prefs.setStringList('conversations', conversationsJson);

    // Save messages for each conversation
    for (final entry in _messages.entries) {
      final messagesJson =
          entry.value.map((message) => jsonEncode(message.toJson())).toList();
      await prefs.setStringList('messages_${entry.key}', messagesJson);

      // 打印图片消息的信息
      for (final message in entry.value) {
        if (message.isImage) {}
      }
    }
  }

  Future<Conversation> createConversation({
    required String title,
    required ConversationType type,
    String configId = '',
  }) async {
    final uuid = const Uuid();
    final conversationId = uuid.v4();

    final newConversation = Conversation(
      id: conversationId,
      title: title,
      type: type,
      configId: configId,
      lastMessageTime: DateTime.now(),
      lastMessage: '',
      unreadCount: 0,
      isPinned: false,
    );

    _conversations.add(newConversation);
    _messages[newConversation.id] = [];

    await _saveConversations();
    notifyListeners();

    print('ConversationProvider: 创建新会话，ID = $conversationId');
    return newConversation;
  }

  Future<void> deleteConversation(String id) async {
    // 寻找要删除的会话
    final conversationIndex = _conversations.indexWhere(
      (conversation) => conversation.id == id,
    );

    if (conversationIndex != -1) {
      // 保存最后删除的会话和消息用于恢复
      _lastDeletedConversation = _conversations[conversationIndex];
      _lastDeletedMessages = _messages[id]?.toList();

      // 清理图片文件
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final conversationDir = Directory('${appDir.path}/conversations/$id');
        if (await conversationDir.exists()) {
          await conversationDir.delete(recursive: true);
          print('已清理会话相关的图片文件: ${conversationDir.path}');
        }
      } catch (e) {
        print('清理图片文件失败: $e');
      }

      // 从列表中移除
      _conversations.removeAt(conversationIndex);
      _messages.remove(id);

      await _saveConversations();
      notifyListeners();
    }
  }

  // 恢复最后删除的会话
  Future<void> restoreLastDeletedConversation() async {
    if (_lastDeletedConversation != null) {
      // 恢复图片文件
      if (_lastDeletedMessages != null) {
        for (final message in _lastDeletedMessages!) {
          if (message.isImage && message.imageLocalPath != null) {
            try {
              final imageFile = File(message.imageLocalPath!);
              if (!await imageFile.parent.exists()) {
                await imageFile.parent.create(recursive: true);
              }
              // 如果文件不存在，说明已被删除，无法恢复
              print('注意：图片文件 ${message.imageLocalPath} 已被删除，无法恢复');
            } catch (e) {
              print('恢复图片文件失败: $e');
            }
          }
        }
      }

      _conversations.add(_lastDeletedConversation!);
      if (_lastDeletedMessages != null) {
        _messages[_lastDeletedConversation!.id] = _lastDeletedMessages!;
      } else {
        _messages[_lastDeletedConversation!.id] = [];
      }

      // 重置删除记录
      _lastDeletedConversation = null;
      _lastDeletedMessages = null;

      await _saveConversations();
      notifyListeners();
    }
  }

  Future<void> togglePinConversation(String id) async {
    final index = _conversations.indexWhere(
      (conversation) => conversation.id == id,
    );
    if (index != -1) {
      final updatedConversation = _conversations[index].copyWith(
        isPinned: !_conversations[index].isPinned,
      );
      _conversations[index] = updatedConversation;

      await _saveConversations();
      notifyListeners();
    }
  }

  List<Message> getMessages(String conversationId) {
    return _messages[conversationId] ?? [];
  }

  Future<void> addMessage({
    required String conversationId,
    required MessageRole role,
    required String content,
    String? id,
    bool isImage = false,
    String? imageLocalPath,
    String? fileId,
  }) async {
    final messageId = id ?? const Uuid().v4();

    // 如果是图片消息，确保目录存在
    if (isImage && imageLocalPath != null) {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final conversationDir = Directory(
          '${appDir.path}/conversations/$conversationId/images',
        );
        if (!await conversationDir.exists()) {
          await conversationDir.create(recursive: true);
        }

        // 检查图片文件是否存在
        final imageFile = File(imageLocalPath);
        if (!await imageFile.exists()) {
          print('警告：添加图片消息时文件不存在: $imageLocalPath');
        }
      } catch (e) {
        print('创建图片目录失败: $e');
      }
    }

    final newMessage = Message(
      id: messageId,
      conversationId: conversationId,
      role: role,
      content: content,
      timestamp: DateTime.now(),
      isRead: role == MessageRole.user,
      isImage: isImage,
      imageLocalPath: imageLocalPath,
      fileId: fileId,
    );

    _messages[conversationId] = [
      ...(_messages[conversationId] ?? []),
      newMessage,
    ];

    // Update conversation last message
    final index = _conversations.indexWhere(
      (conversation) => conversation.id == conversationId,
    );
    if (index != -1) {
      final updatedConversation = _conversations[index].copyWith(
        lastMessage: content,
        lastMessageTime: DateTime.now(),
        unreadCount:
            role == MessageRole.assistant
                ? _conversations[index].unreadCount + 1
                : _conversations[index].unreadCount,
      );
      _conversations[index] = updatedConversation;
    }

    await _saveConversations();
    notifyListeners();
  }

  // 更新最后一条用户消息，用于图片上传后更新fileId等信息
  Future<void> updateLastUserMessage({
    required String conversationId,
    required String content,
    bool isImage = false,
    String? imageLocalPath,
    String? fileId,
  }) async {
    if (!_messages.containsKey(conversationId) ||
        _messages[conversationId]!.isEmpty) {
      print('警告：找不到会话 $conversationId 或会话为空');
      return;
    }

    // 找到最后一条用户消息
    final messages = _messages[conversationId]!;
    int lastUserMessageIndex = -1;

    // 从后向前找最后一条用户消息
    for (int i = messages.length - 1; i >= 0; i--) {
      if (messages[i].role == MessageRole.user) {
        lastUserMessageIndex = i;
        break;
      }
    }

    // 如果找到了用户消息，则更新它
    if (lastUserMessageIndex != -1) {
      final oldMessage = messages[lastUserMessageIndex];

      // 如果是图片消息，保留原有的图片相关字段
      final updatedMessage = Message(
        id: oldMessage.id,
        conversationId: oldMessage.conversationId,
        role: oldMessage.role,
        content: content,
        timestamp: oldMessage.timestamp,
        isRead: oldMessage.isRead,
        isImage: isImage || oldMessage.isImage,
        imageLocalPath: imageLocalPath ?? oldMessage.imageLocalPath,
        fileId: fileId ?? oldMessage.fileId,
      );

      // 替换消息
      _messages[conversationId]![lastUserMessageIndex] = updatedMessage;

      // 如果这是最后一条消息，也更新会话的lastMessage
      if (lastUserMessageIndex == messages.length - 1) {
        final conversationIndex = _conversations.indexWhere(
          (conversation) => conversation.id == conversationId,
        );

        if (conversationIndex != -1) {
          final updatedConversation = _conversations[conversationIndex]
              .copyWith(lastMessage: content);
          _conversations[conversationIndex] = updatedConversation;
        }
      }

      await _saveConversations();
      notifyListeners();
    } else {
      print('警告：在会话 $conversationId 中找不到用户消息');
    }
  }

  Future<void> updateMessage({
    required String messageId,
    required String content,
  }) async {
    // 查找包含该消息的会话
    String? targetConversationId;
    int messageIndex = -1;

    for (final entry in _messages.entries) {
      final index = entry.value.indexWhere(
        (message) => message.id == messageId,
      );
      if (index != -1) {
        targetConversationId = entry.key;
        messageIndex = index;
        break;
      }
    }

    if (targetConversationId != null && messageIndex != -1) {
      // 更新消息内容
      final oldMessage = _messages[targetConversationId]![messageIndex];
      final updatedMessage = Message(
        id: oldMessage.id,
        conversationId: oldMessage.conversationId,
        role: oldMessage.role,
        content: content,
        timestamp: oldMessage.timestamp,
        isRead: oldMessage.isRead,
        isImage: oldMessage.isImage,
        imageLocalPath: oldMessage.imageLocalPath,
        fileId: oldMessage.fileId,
      );

      _messages[targetConversationId]![messageIndex] = updatedMessage;

      // 更新会话的最后一条消息
      final conversationIndex = _conversations.indexWhere(
        (conversation) => conversation.id == targetConversationId,
      );

      if (conversationIndex != -1) {
        final updatedConversation = _conversations[conversationIndex].copyWith(
          lastMessage: content,
        );
        _conversations[conversationIndex] = updatedConversation;
      }

      await _saveConversations();
      notifyListeners();
    } else {
      print('警告：找不到消息 $messageId');
    }
  }

  Future<void> markConversationAsRead(String conversationId) async {
    final index = _conversations.indexWhere(
      (conversation) => conversation.id == conversationId,
    );
    if (index != -1) {
      final updatedConversation = _conversations[index].copyWith(
        unreadCount: 0,
      );
      _conversations[index] = updatedConversation;

      // Mark all messages as read
      if (_messages.containsKey(conversationId)) {
        _messages[conversationId] =
            _messages[conversationId]!.map((message) {
              return Message(
                id: message.id,
                conversationId: message.conversationId,
                role: message.role,
                content: message.content,
                timestamp: message.timestamp,
                isRead: true,
                isImage: message.isImage,
                imageLocalPath: message.imageLocalPath,
                fileId: message.fileId,
              );
            }).toList();
      }

      await _saveConversations();
      notifyListeners();
    }
  }
}
