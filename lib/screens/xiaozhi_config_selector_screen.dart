import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xintong_ai/providers/config_provider.dart';
import 'package:xintong_ai/providers/conversation_provider.dart';
import 'package:xintong_ai/models/conversation.dart';
import 'package:xintong_ai/models/xiaozhi_config.dart';
import 'package:xintong_ai/screens/chat_screen.dart';

class XiaozhiConfigSelectorScreen extends StatelessWidget {
  const XiaozhiConfigSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final xiaozhiConfigs = Provider.of<ConfigProvider>(context).xiaozhiConfigs;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择小智服务'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: xiaozhiConfigs.length,
        itemBuilder: (context, index) {
          final config = xiaozhiConfigs[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(
                config.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('WebSocket: ${config.websocketUrl}'),
                  Text('OTA: ${config.otaUrl}'),
                  Text('MAC: ${config.macAddress}'),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _createXiaozhiConversation(context, config),
            ),
          );
        },
      ),
    );
  }
  
  void _createXiaozhiConversation(BuildContext context, XiaozhiConfig config) async {
    final conversation = await Provider.of<ConversationProvider>(context, listen: false)
        .createConversation(
          title: '与 ${config.name} 的对话',
          type: ConversationType.xiaozhi,
          configId: config.id,
        );
    
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(conversation: conversation),
        ),
      );
    }
  }
}

