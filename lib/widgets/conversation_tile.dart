import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:xintong_ai/models/conversation.dart';
import 'package:xintong_ai/models/xiaozhi_config.dart';
import 'package:xintong_ai/providers/config_provider.dart';
import 'package:xintong_ai/models/user_config.dart';
import 'package:xintong_ai/providers/user_provider.dart';
import 'package:xintong_ai/utils/image_util.dart';

class ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ConversationTile({
    super.key,
    required this.conversation,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                _buildAvatar(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  conversation.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                _buildTypeTag(context),
                              ],
                            ),
                          ),
                          Text(
                            _formatTime(conversation.lastMessageTime),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        conversation.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade300,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeTag(BuildContext context) {
    String label = '语音';

    // 如果有配置ID且不为空，则显示配置名称
    if (conversation.configId.isNotEmpty) {
      final configProvider = Provider.of<ConfigProvider>(
        context,
        listen: false,
      );

        // 尝试查找匹配的小智配置
        final matchingConfig =
            configProvider.xiaozhiConfigs
                .where((config) => config.id == conversation.configId)
                .firstOrNull;
        if (matchingConfig != null) {
          label = '${matchingConfig.name}';
        }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Colors.purple.shade600,
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final userConfig = userProvider.userConfigs.firstWhere(
          (config) => config.id == conversation.configId,      
          orElse:
          () => UserConfig(
            id: conversation.configId,
            backgroundPath: null,
            sysIconPath: null,
            selfIconPath: null,
          ),
        );
        return CircleAvatar(
          radius: 24,
          backgroundImage: dynamicGetImageProvider(
              '${userConfig.sysIconPath}/icon_${conversation.configId}.jpeg'
          ),
          backgroundColor:
              dynamicGetImageProvider(
                          '${userConfig.sysIconPath}/icon_${conversation.configId}.jpeg'
                      ) ==
                      null
                  ? Colors.purple.shade400
                  : null,
          child:
              dynamicGetImageProvider(
                          '${userConfig.sysIconPath}/icon_${userConfig.id}.jpeg'
                      ) ==
                      null
                  ? (const Icon(Icons.mic, color: Colors.white, size: 22))
                  : null,
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0 && difference.inDays <= 1) {
      return '昨天';
    } else if (difference.inDays > 1 && difference.inDays <= 7) {
      return '周${_getWeekday(dateTime.weekday)}';
    } else {
      // 当天显示时间
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
  }

  String _getWeekday(int weekday) {
    switch (weekday) {
      case 1:
        return '一';
      case 2:
        return '二';
      case 3:
        return '三';
      case 4:
        return '四';
      case 5:
        return '五';
      case 6:
        return '六';
      case 7:
        return '日';
      default:
        return '';
    }
  }
}
