import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xintong_ai/models/user_config.dart';

class UserProvider extends ChangeNotifier {
  List<UserConfig> _userConfigs = [];
  bool _isLoaded = false;

  List<UserConfig> get userConfigs => _userConfigs;
  bool get isLoaded => _isLoaded;

  UserProvider() {
    _loadConfigs();
  }

  Future<void> _loadConfigs() async {
    final prefs = await SharedPreferences.getInstance();

    // Load Xiaozhi configs
    final userConfigsJson = prefs.getStringList('userConfigs') ?? [];
    _userConfigs =
        userConfigsJson
            .map((json) => UserConfig.fromJson(jsonDecode(json)))
            .toList();

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _saveConfigs() async {
    final prefs = await SharedPreferences.getInstance();

    // Save Xiaozhi configs
    final userConfigsJson =
        _userConfigs.map((config) => jsonEncode(config.toJson())).toList();
    await prefs.setStringList('userConfigs', userConfigsJson);
  }

  Future<UserConfig> addUserConfig( 
    String id,
    {String? sysIconPath,
    String? backgroundPath,
    String? selfIconPath,}
  ) async {

    final newConfig = UserConfig(
      id: id,
      sysIconPath: sysIconPath,
      backgroundPath: backgroundPath,
      selfIconPath: selfIconPath,
    );

    _userConfigs.add(newConfig);
    await _saveConfigs();
    notifyListeners();
    return newConfig;
  }

  Future<void> updateUserConfig(UserConfig updatedConfig) async {
    final index = _userConfigs.indexWhere(
      (config) => config.id == updatedConfig.id,
    );
    if (index != -1) {
      _userConfigs[index] = updatedConfig;
      await _saveConfigs();
      notifyListeners();
    }
  }

  Future<void> deleteUserConfig(String id) async {
    _userConfigs.removeWhere((config) => config.id == id);
    await _saveConfigs();
    notifyListeners();
  }
}

