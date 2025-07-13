import 'dart:io';
import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// 设备工具类
class DeviceUtil {
  static const String TAG = "DeviceUtil";
  static const String DEVICE_ID_KEY = "device_id";

  /// 获取设备ID，优先从缓存获取，没有则生成新的
  static Future<String> getDeviceId() async {
    // 尝试从缓存获取设备ID
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(DEVICE_ID_KEY);

    // 如果已有设备ID，直接返回
    if (deviceId != null && deviceId.isNotEmpty) {
      print('$TAG: 从缓存获取设备ID: $deviceId');
      return deviceId;
    }

    // 根据平台获取设备信息
    final deviceInfo = DeviceInfoPlugin();
    // iOS设备
    final iosInfo = await deviceInfo.iosInfo;
    deviceId = _formatDeviceName(iosInfo.name);

    // 如果无法获取设备信息，生成一个随机UUID
    if (deviceId == null || deviceId.isEmpty) {
      deviceId = const Uuid().v4();
      print('$TAG: 生成随机设备ID: $deviceId');
    } else {
      print('$TAG: 从设备获取名称: $deviceId');
    }

    // 保存设备ID到缓存
    await prefs.setString(DEVICE_ID_KEY, deviceId);

    return deviceId;
  }

  /// 格式化设备名称，移除特殊字符并规范化格式
  static String _formatDeviceName(String name) {
    if (name.isEmpty) return 'unknown_device';

    // 1. 转换为小写
    String formatted = name.toLowerCase();

    // 2. 替换空格和特殊字符为下划线
    formatted = formatted.replaceAll(RegExp(r'[^a-z0-9]'), '_');

    // 3. 替换连续的下划线为单个下划线
    formatted = formatted.replaceAll(RegExp(r'_+'), '_');

    // 4. 移除开头和结尾的下划线
    formatted = formatted.replaceAll(RegExp(r'^_+|_+$'), '');

    // 5. 如果处理后为空，返回默认值
    if (formatted.isEmpty) return 'unknown_device';

    // 6. 限制长度（可选）
    if (formatted.length > 32) {
      formatted = formatted.substring(0, 32);
      // 确保不以下划线结尾
      formatted = formatted.replaceAll(RegExp(r'_+$'), '');
    }

    return formatted;
  }

  /// 获取设备型号
  static Future<String> getDeviceModel() async {
    final deviceInfo = DeviceInfoPlugin();
    final iosInfo = await deviceInfo.iosInfo;
    return iosInfo.model;
  }

  /// 获取操作系统版本
  static Future<String> getOsVersion() async {
    final deviceInfo = DeviceInfoPlugin();
    final iosInfo = await deviceInfo.iosInfo;
    return 'iOS ${iosInfo.systemVersion}';

  }

  // 生成唯一的会话ID
  static String generateConversationId() {
    return const Uuid().v4();
  }
}
