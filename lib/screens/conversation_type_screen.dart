import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xintong_ai/providers/config_provider.dart';
import 'package:xintong_ai/providers/conversation_provider.dart';
import 'package:xintong_ai/models/conversation.dart';
import 'package:xintong_ai/models/xiaozhi_config.dart';
import 'package:xintong_ai/screens/chat_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConversationTypeScreen extends StatefulWidget {
  const ConversationTypeScreen({super.key});

  @override
  State<ConversationTypeScreen> createState() => _ConversationTypeScreenState();
}

class _ConversationTypeScreenState extends State<ConversationTypeScreen> {
  ConversationType? _selectedType;
  XiaozhiConfig? _selectedXiaozhiConfig;
  bool _showXiaozhiSelector = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 26),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '新建对话',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTypeSelectionCard(),
                    if (_showXiaozhiSelector) ...[
                      const SizedBox(height: 16),
                      _buildXiaozhiSelectionCard(),
                    ],
                  ],
                ),
              ),
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildTypeSelectionCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '选择对话类型',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  '请选择您想要创建的对话类型',
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    final xiaozhiConfigs =
                        Provider.of<ConfigProvider>(
                          context,
                          listen: false,
                        ).xiaozhiConfigs;

                    if (xiaozhiConfigs.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('请先在设置中添加小智服务配置')),
                      );
                      return;
                    }

                    setState(() {
                      _selectedType = ConversationType.xiaozhi;
                      _showXiaozhiSelector = true;
                      // 默认选择第一个小智配置
                      _selectedXiaozhiConfig =
                          xiaozhiConfigs.isNotEmpty
                              ? xiaozhiConfigs.first
                              : null;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(
                      left: 10,
                      right: 20,
                      bottom: 20,
                    ),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color:
                          _selectedType == ConversationType.xiaozhi
                              ? const Color(0xFFF5F5F5)
                              : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            _selectedType == ConversationType.xiaozhi
                                ? Colors.black
                                : Colors.grey.shade300,
                        width:
                            _selectedType == ConversationType.xiaozhi ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            _selectedType == ConversationType.xiaozhi
                                ? 0.08
                                : 0.03,
                          ),
                          blurRadius:
                              _selectedType == ConversationType.xiaozhi ? 6 : 3,
                          spreadRadius: 0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purple.withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 0,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 36,
                            backgroundColor: Colors.purple.shade400,
                            child: const Icon(
                              Icons.mic,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          '小智语音对话',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '支持文字和语音交流',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildXiaozhiSelectionCard() {
    final xiaozhiConfigs = Provider.of<ConfigProvider>(context).xiaozhiConfigs;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '选择小智服务',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  '请选择要使用的小智语音服务',
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),
          _buildXiaozhiDropdown(xiaozhiConfigs),
          const SizedBox(height: 16),
          if (_selectedXiaozhiConfig != null)
            _buildXiaozhiDetailsPanel(_selectedXiaozhiConfig!),
        ],
      ),
    );
  }

  Widget _buildXiaozhiDropdown(List<XiaozhiConfig> configs) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.purple.withOpacity(0.04),
            blurRadius: 12,
            spreadRadius: -2,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 8),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<XiaozhiConfig>(
            value: _selectedXiaozhiConfig,
            isExpanded: true,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.purple,
                size: 24,
              ),
            ),
            iconSize: 24,
            itemHeight: 60,
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(16),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            items:
                configs.map((XiaozhiConfig config) {
                  return DropdownMenuItem<XiaozhiConfig>(
                    value: config,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.mic,
                              color: Colors.purple,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                config.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                config.websocketUrl.split('/').last,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
            onChanged: (XiaozhiConfig? newValue) {
              setState(() {
                _selectedXiaozhiConfig = newValue;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildXiaozhiDetailsPanel(XiaozhiConfig config) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.purple.withOpacity(0.04),
            blurRadius: 12,
            spreadRadius: -2,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.info_outline,
                  color: Colors.purple.shade400,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                '服务详情',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDetailItemXiaozhi('WebSocket', config.websocketUrl),
          const SizedBox(height: 12),
          _buildDetailItemXiaozhi(
            'MAC地址',
            config.macAddress.isEmpty ? '自动生成' : config.macAddress,
          ),
          const SizedBox(height: 12),
          _buildDetailItemXiaozhi(
            'Token',
            config.token.isEmpty ? 'test-token' : config.token,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItemXiaozhi(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.purple.shade700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 20,
        top: 20,
        right: 20,
        bottom: 20 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _selectedType == null ? null : _createConversation,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: _selectedType == null ? 0 : 4,
          shadowColor:
              _selectedType == null
                  ? Colors.transparent
                  : Colors.black.withOpacity(0.3),
        ),
        child: const Text(
          '创建对话',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _createConversation() async {
    if (_selectedType == ConversationType.xiaozhi &&
        _selectedXiaozhiConfig != null) {
      _createXiaozhiConversation(_selectedXiaozhiConfig!);
    }
  }

  void _createXiaozhiConversation(XiaozhiConfig config) async {
    final otaUrl = config.otaUrl;
    final macAddress = config.macAddress;
    print('connct OTA url: $otaUrl');
    if (otaUrl != '') {
      final ota_post_data = {
        "flash_size": 16777216,
        "minimum_free_heap_size": 8318916,
        "mac_address": macAddress,
        "chip_model_name": "esp32s3",
        "chip_info": {"model": 9, "cores": 2, "revision": 2, "features": 18},
        "application": {"name": "xiaozhi", "version": "1.8.2"},
        "partition_table": [],
        "ota": {"label": "factory"},
        "board": {
          "type": "bread-compact-wifi",
          "ip": "192.168.124.38",
          "mac": macAddress,
        },
      };
      final requestBody = jsonEncode(ota_post_data);
      final response = await http.post(
        Uri.parse(otaUrl),
        headers: {"Device-Id": macAddress, "Content-Type": "application/json"},
        body: requestBody,
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("OTA 成功， 固件版本：${data['firmware']['version']}");
      } else {
        // 特殊处理404 Conversation Not Exists错误
        print('OTA 请求失败: ${response.statusCode}, 响应: ${response.body}');
      }
    }
    final conversation = await Provider.of<ConversationProvider>(
      context,
      listen: false,
    ).createConversation(
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
