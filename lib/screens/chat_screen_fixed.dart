import 'dart:math';
import 'dart:io';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:xintong_ai/models/conversation.dart';
import 'package:xintong_ai/models/message.dart';
import 'package:xintong_ai/models/xiaozhi_config.dart';
import 'package:xintong_ai/models/user_config.dart';
import 'package:xintong_ai/providers/conversation_provider.dart';
import 'package:xintong_ai/providers/config_provider.dart';
import 'package:xintong_ai/providers/user_provider.dart';
import 'package:xintong_ai/services/xiaozhi_service.dart';
import 'package:xintong_ai/widgets/message_bubble.dart';
import 'package:xintong_ai/screens/voice_call_screen.dart';
import 'package:xintong_ai/utils/image_util.dart';
import 'package:path_provider/path_provider.dart';

class ChatScreenFixed extends StatefulWidget {
  const ChatScreenFixed({super.key});

  @override
  State<ChatScreenFixed> createState() => _ChatScreenFixedState();
}

class _ChatScreenFixedState extends State<ChatScreenFixed> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  XiaozhiService? _xiaozhiService; // 保持XiaozhiService实例
  Timer? _connectionCheckTimer; // 添加定时器检查连接状态
  Timer? _autoReconnectTimer; // 自动重连定时器

  // 语音输入相关
  bool _isVoiceInputMode = false;
  bool _isRecording = false;
  bool _isCancelling = false;
  double _startDragY = 0.0;
  final double _cancelThreshold = 50.0; // 上滑超过这个距离认为是取消
  Timer? _waveAnimationTimer;
  final List<double> _waveHeights = List.filled(20, 0.0);
  final Random _random = Random();
  late final Conversation conversation;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<ConversationProvider>(
        context,
        listen: false,
      ).markConversationAsRead(conversation.id);

      // 如果是小智对话，初始化服务
      if (conversation.type == ConversationType.xiaozhi) {
        _initXiaozhiService();

        // 添加定时器定期检查连接状态
        _connectionCheckTimer = Timer.periodic(const Duration(seconds: 2), (
          timer,
        ) {
          if (mounted && _xiaozhiService != null) {
            final wasConnected = _xiaozhiService!.isConnected;

            // 刷新UI
            setState(() {});

            // 如果状态从连接变为断开，尝试自动重连
            if (wasConnected &&
                !_xiaozhiService!.isConnected &&
                _autoReconnectTimer == null) {
              print('检测到连接断开，准备自动重连');
              _scheduleReconnect();
            }
          }
        });

        // 默认启用语音输入模式 (针对小智对话)
        setState(() {
          _isVoiceInputMode = true;
        });
      }
    });

    try {
      conversation =
          Provider.of<ConversationProvider>(
            context,
            listen: false,
          ).pinnedConversations[0];
    } catch (e) {
      Navigator.of(context).pop();
    }
    print("Ready to jump");
    Future.microtask(() async {
      await _navigateToVoiceCall();
    });
  }

  // 安排自动重连
  void _scheduleReconnect() {
    // 取消现有重连定时器
    _autoReconnectTimer?.cancel();

    // 创建新的重连定时器，5秒后尝试重连
    _autoReconnectTimer = Timer(const Duration(seconds: 5), () async {
      print('正在尝试自动重连...');
      if (_xiaozhiService != null && !_xiaozhiService!.isConnected && mounted) {
        try {
          await _xiaozhiService!.disconnect();
          await _xiaozhiService!.connect();

          setState(() {});
          print('自动重连 ${_xiaozhiService!.isConnected ? "成功" : "失败"}');

          // 如果重连失败，则继续尝试重连
          if (!_xiaozhiService!.isConnected) {
            _scheduleReconnect();
          } else {
            _autoReconnectTimer = null;
          }
        } catch (e) {
          print('自动重连出错: $e');
          _scheduleReconnect(); // 出错后继续尝试
        }
      } else {
        _autoReconnectTimer = null;
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    // 取消所有定时器
    _connectionCheckTimer?.cancel();
    _autoReconnectTimer?.cancel();
    _waveAnimationTimer?.cancel();

    // 在销毁前确保停止所有音频播放
    if (_xiaozhiService != null) {
      _xiaozhiService!.stopPlayback();
      _xiaozhiService!.disconnect();
      if (_xiaozhiService!.isMuted) {
        _xiaozhiService!.toggleMute();
      }
    }

    super.dispose();
  }

  // 初始化小智服务
  Future<void> _initXiaozhiService() async {
    final configProvider = Provider.of<ConfigProvider>(context, listen: false);
    final xiaozhiConfig = configProvider.xiaozhiConfigs.firstWhere(
      (config) => config.id == conversation.configId,
    );
    _xiaozhiService = XiaozhiService(
      websocketUrl: xiaozhiConfig.websocketUrl,
      otaUrl: xiaozhiConfig.otaUrl,
      macAddress: xiaozhiConfig.macAddress,
      token: xiaozhiConfig.token,
    );

    // 添加消息监听器
    _xiaozhiService!.addListener(_handleXiaozhiMessage);

    // 连接服务
    await _xiaozhiService!.connect();

    // 连接后刷新UI状态
    if (mounted) {
      setState(() {});
    }
  }

  // 处理小智消息
  void _handleXiaozhiMessage(XiaozhiServiceEvent event) {
    if (!mounted) return;

    final conversationProvider = Provider.of<ConversationProvider>(
      context,
      listen: false,
    );

    if (event.type == XiaozhiServiceEventType.textMessage) {
      // 直接使用文本内容
      String content = event.data as String;
      print('收到消息内容: $content');

      // 忽略空消息
      if (content.isNotEmpty) {
        conversationProvider.addMessage(
          conversationId: conversation.id,
          role: MessageRole.assistant,
          content: content,
        );
      }
    } else if (event.type == XiaozhiServiceEventType.userMessage) {
      // 处理用户的语音识别文本
      String content = event.data as String;
      print('收到用户语音识别内容: $content');

      // 只有在语音输入模式下才添加用户消息
      if (content.isNotEmpty && _isVoiceInputMode) {
        // 语音消息可能有延迟，使用Future.microtask确保UI已更新
        Future.microtask(() {
          conversationProvider.addMessage(
            conversationId: conversation.id,
            role: MessageRole.user,
            content: content,
          );
        });
      }
    } else if (event.type == XiaozhiServiceEventType.connected ||
        event.type == XiaozhiServiceEventType.disconnected) {
      // 当连接状态发生变化时，更新UI
      setState(() {});
    }
  }

  Future<void> _navigateToVoiceCall() async {
    final configProvider = Provider.of<ConfigProvider>(context, listen: false);
    final xiaozhiConfig = configProvider.xiaozhiConfigs.firstWhere(
      (config) => config.id == conversation.configId,
    );

    // 导航前停止当前音频播放
    if (_xiaozhiService != null) {
      await _xiaozhiService!.stopPlayback();
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => VoiceCallScreen(
              conversation: conversation,
              xiaozhiConfig: xiaozhiConfig,
            ),
      ),
    ).then((_) async {
      print("back");
      // 页面返回后，确保重新初始化服务以恢复正常对话功能
      if (_xiaozhiService != null &&
          conversation.type == ConversationType.xiaozhi) {
        // 重新连接服务
        await _xiaozhiService!.connect();
      }
      Future.microtask(() {
        Navigator.pop(context);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // final configProvider = Provider.of<ConfigProvider>(context, listen: false);
    // final xiaozhiConfig = configProvider.xiaozhiConfigs.firstWhere(
    //   (config) => config.id == conversation.configId,
    // );
    // print('will read from $imgPath/${xiaozhiConfig.id}.jpeg');
    return SizedBox.shrink();
  }

  Widget _buildXiaozhiInfo() {
    final bool isConnected = _xiaozhiService?.isConnected ?? false;
    return Row(
      children: [
        // 连接状态指示器
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isConnected ? Colors.green : Colors.red,
            boxShadow: [
              BoxShadow(
                color: (isConnected ? Colors.green : Colors.red).withOpacity(
                  0.4,
                ),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          isConnected ? '已连接' : '未连接',
          style: TextStyle(
            fontSize: 13,
            color: isConnected ? Colors.green : Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // 开始录音
  void _startRecording() async {
    if (_xiaozhiService == null) {
      _showCustomSnackbar('语音功能仅适用于小智对话');
      setState(() {
        _isVoiceInputMode = false;
      });
      return;
    }
    try {
      // 震动反馈
      HapticFeedback.mediumImpact();
      _xiaozhiService!.sendAbortMessage();
      // 开始录音
      await _xiaozhiService!.startListening();
    } catch (e) {
      print('开始录音失败: $e');
      _showCustomSnackbar('无法开始录音: ${e.toString()}');
      setState(() {
        _isRecording = false;
        _isVoiceInputMode = false;
      });
    }
  }

  // 停止录音并发送
  void _stopRecording() async {
    try {
      setState(() {
        _isLoading = true;
        _isRecording = false;
        // 不要立即关闭语音输入模式，让用户可以看到识别结果
        // _isVoiceInputMode = false;
      });

      // 震动反馈
      HapticFeedback.mediumImpact();

      // 停止录音
      await _xiaozhiService?.stopListening();

      _scrollToBottom();
    } catch (e) {
      print('停止录音失败: $e');
      _showCustomSnackbar('语音发送失败: ${e.toString()}');

      // 出错时关闭语音输入模式
      setState(() {
        _isVoiceInputMode = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 取消录音
  void _cancelRecording() async {
    try {
      setState(() {
        _isRecording = false;
      });

      // 震动反馈
      HapticFeedback.heavyImpact();

      // 取消录音
      await _xiaozhiService?.abortListening();

      // 使用自定义的拟物化提示，显示在顶部且带有圆角
      _showCustomSnackbar('已取消发送');
    } catch (e) {
      print('取消录音失败: $e');
    }
  }

  // 显示自定义Snackbar
  void _showCustomSnackbar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.black.withOpacity(0.7),
      duration: const Duration(seconds: 2),
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height - 120,
        left: 16,
        right: 16,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // 启动波形动画
  void _startWaveAnimation() {
    _waveAnimationTimer?.cancel();
    _waveAnimationTimer = Timer.periodic(const Duration(milliseconds: 100), (
      timer,
    ) {
      if (_isRecording && !_isCancelling) {
        setState(() {
          for (int i = 0; i < _waveHeights.length; i++) {
            _waveHeights[i] = 0.5 + _random.nextDouble() * 0.5;
          }
        });
      }
    });
  }

  // 停止波形动画
  void _stopWaveAnimation() {
    _waveAnimationTimer?.cancel();
    _waveAnimationTimer = null;
  }

  // 构建波形动画指示器
  Widget _buildWaveAnimationIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          16,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: 3,
            height: 20 * _waveHeights[index],
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.6),
              borderRadius: BorderRadius.circular(1.5),
            ),
            curve: Curves.easeInOut,
          ),
        ),
      ),
    );
  }
}
