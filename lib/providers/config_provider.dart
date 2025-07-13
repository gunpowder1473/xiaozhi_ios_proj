import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import 'package:ai_xiaozhi/models/xiaozhi_config.dart';

class ConfigProvider extends ChangeNotifier {
  List<XiaozhiConfig> _xiaozhiConfigs = [];
  bool _isLoaded = false;

  List<XiaozhiConfig> get xiaozhiConfigs => _xiaozhiConfigs;
  bool get isLoaded => _isLoaded;

  ConfigProvider() {
    _loadConfigs();
  }

  Future<void> _loadConfigs() async {
    final prefs = await SharedPreferences.getInstance();

    // Load Xiaozhi configs
    final xiaozhiConfigsJson = prefs.getStringList('xiaozhiConfigs') ?? [];
    _xiaozhiConfigs =
        xiaozhiConfigsJson
            .map((json) => XiaozhiConfig.fromJson(jsonDecode(json)))
            .toList();

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _saveConfigs() async {
    final prefs = await SharedPreferences.getInstance();

    // Save Xiaozhi configs
    final xiaozhiConfigsJson =
        _xiaozhiConfigs.map((config) => jsonEncode(config.toJson())).toList();
    await prefs.setStringList('xiaozhiConfigs', xiaozhiConfigsJson);
  }

  Future<void> addXiaozhiConfig(
    String name,
    {String? customWebsocketUrl,
    String? customOtaUrl,
    String? customMacAddress,}
  ) async {
    // 如果提供了自定义MAC地址，直接使用；否则使用设备ID生成
    final macAddress;
    final otaUrl;
    final websocketUrl;
  
    websocketUrl = customWebsocketUrl ?? 'wss://api.tenclass.net/xiaozhi/v1/';
    otaUrl = customOtaUrl ?? 'https://api.tenclass.net/xiaozhi/ota/';
    macAddress = customMacAddress ?? await _getDeviceMacAddress();

    final newConfig = XiaozhiConfig(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      websocketUrl: websocketUrl,
      otaUrl: otaUrl,
      macAddress: macAddress,
      token: 'test-token',
    );

    _xiaozhiConfigs.add(newConfig);
    await _saveConfigs();
    notifyListeners();
  }

  Future<void> updateXiaozhiConfig(XiaozhiConfig updatedConfig) async {
    final index = _xiaozhiConfigs.indexWhere(
      (config) => config.id == updatedConfig.id,
    );
    if (index != -1) {
      _xiaozhiConfigs[index] = updatedConfig;
      await _saveConfigs();
      notifyListeners();
    }
  }

  Future<void> deleteXiaozhiConfig(String id) async {
    _xiaozhiConfigs.removeWhere((config) => config.id == id);
    await _saveConfigs();
    notifyListeners();
  }

  // 简化版的设备ID获取方法，不依赖上下文
  Future<String> _getSimpleDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    String deviceId = '';

    try {
      // 简单地尝试获取Android或iOS设备ID，不依赖平台判断
      try {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } catch (_) {
        try {
          final iosInfo = await deviceInfo.iosInfo;
          deviceId = iosInfo.identifierForVendor ?? '';
        } catch (_) {
          final webInfo = await deviceInfo.webBrowserInfo;
          deviceId = webInfo.userAgent ?? '';
        }
      }
    } catch (e) {
      // 出现任何错误，使用时间戳
      deviceId = DateTime.now().millisecondsSinceEpoch.toString();
    }

    // 如果ID为空，使用时间戳
    if (deviceId.isEmpty) {
      deviceId = DateTime.now().millisecondsSinceEpoch.toString();
    }

    return deviceId;
  }

  String _generateMacFromDeviceId(String deviceId) {
    final bytes = utf8.encode(deviceId);
    final digest = md5.convert(bytes);
    final hash = digest.toString();

    // Format as MAC address (XX:XX:XX:XX:XX:XX)
    final List<String> macParts = [];
    for (int i = 0; i < 6; i++) {
      macParts.add(hash.substring(i * 2, i * 2 + 2));
    }

    return macParts.join(':');
  }

  // 获取设备MAC地址
  Future<String> _getDeviceMacAddress() async {
    final deviceId = await _getSimpleDeviceId();

    // 如果设备ID本身就是MAC地址格式，直接使用
    if (_isMacAddress(deviceId)) {
      return deviceId;
    }

    // 否则生成一个MAC地址
    return _generateMacFromDeviceId(deviceId);
  }

  // 检查字符串是否是MAC地址格式
  bool _isMacAddress(String str) {
    final macRegex = RegExp(r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$');
    return macRegex.hasMatch(str);
  }
}
